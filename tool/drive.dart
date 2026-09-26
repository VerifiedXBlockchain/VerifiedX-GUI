// Drives a VFX GUI started from lib/main_automation.dart through Flutter
// Driver. Run it with the pinned SDK from the project root:
//
//   $HOME/fvm/versions/3.7.12/bin/dart run tool/drive.dart \
//       --vm-service-url http://127.0.0.1:PORT/TOKEN=/ <command> [args]
//
// Each invocation connects, runs one command, and exits. See
// docs/automation.md for the flow and `--help` for the command table.

import 'dart:async';
import 'dart:io';

import 'package:flutter_driver/flutter_driver.dart';

const vmServiceUrlOption = '--vm-service-url';
const timeoutOption = '--timeout';
const verboseFlag = '--verbose';

/// Budget for every driver command, including how long `wait-for-text`
/// waits; `--timeout <seconds>` overrides it.
const defaultTimeout = Duration(seconds: 30);

/// How long to wait for the driver extension to answer on connect.
const connectTimeout = Duration(seconds: 30);

const exitCommandFailed = 1;
const exitUsage = 2;

/// Mirrors `ByLabel` in lib/core/automation/driver_label_finder.dart: the
/// app deserializes `{finderType: 'ByLabel', label: ...}` into a widget-tree
/// search for a Semantics label or a Tooltip message.
class ByLabel extends SerializableFinder {
  const ByLabel(this.label);

  final String label;

  @override
  String get finderType => 'ByLabel';

  @override
  Map<String, String> serialize() =>
      super.serialize()..addAll(<String, String>{'label': label});
}

class UsageException implements Exception {
  UsageException(this.message);

  final String message;
}

typedef CommandBody = Future<String> Function(
  FlutterDriver driver,
  List<String> args,
  Duration timeout,
);

class DriveCommand {
  const DriveCommand(
    this.name,
    this.argsUsage,
    this.help,
    this.run, {
    this.argCount = 1,
  });

  final String name;
  final String argsUsage;
  final String help;
  final int argCount;
  final CommandBody run;

  String get usage => '$name $argsUsage'.trim();
}

final commands = <DriveCommand>[
  DriveCommand(
    'health',
    '',
    'Report the driver extension health.',
    argCount: 0,
    (driver, args, timeout) async {
      final health = await driver.checkHealth(timeout: timeout);
      return 'health: ${health.status.name}';
    },
  ),
  DriveCommand(
    'tap-text',
    '<text>',
    'Tap the widget whose text is exactly <text>.',
    (driver, args, timeout) =>
        _tap(driver, find.text(args[0]), 'text "${args[0]}"', timeout),
  ),
  DriveCommand(
    'tap-key',
    '<key>',
    'Tap the widget with the string ValueKey <key>.',
    (driver, args, timeout) =>
        _tap(driver, find.byValueKey(args[0]), 'key "${args[0]}"', timeout),
  ),
  DriveCommand(
    'tap-label',
    '<label>',
    'Tap the control labelled <label>: a Semantics label or a tooltip.',
    (driver, args, timeout) =>
        _tap(driver, ByLabel(args[0]), 'label "${args[0]}"', timeout),
  ),
  DriveCommand(
    'type',
    '<text>',
    'Enter <text> into the focused text field (tap the field first).',
    (driver, args, timeout) async {
      await driver.enterText(args[0], timeout: timeout);
      return 'typed ${args[0].length} characters into the focused field';
    },
  ),
  DriveCommand(
    'get-text',
    '<finder>',
    'Print the text of the Text, RichText or text field matched by <finder>: '
        'text:<text>, key:<key>, label:<label> (the Text inside the widget '
        'carrying that label or tooltip) or type:<WidgetType>.',
    (driver, args, timeout) =>
        driver.getText(parseFinder(args[0]), timeout: timeout),
  ),
  DriveCommand(
    'wait-for-text',
    '<text>',
    'Wait until a widget whose text is exactly <text> exists.',
    (driver, args, timeout) async {
      await driver.waitFor(find.text(args[0]), timeout: timeout);
      return 'found text "${args[0]}"';
    },
  ),
  DriveCommand(
    'screenshot',
    '<path>',
    'Write a PNG of the current frame to <path>.',
    (driver, args, timeout) async {
      final bytes = await driver.screenshot();
      final file = File(args[0]);
      await file.writeAsBytes(bytes, flush: true);
      return 'screenshot: ${file.path} (${bytes.length} bytes)';
    },
  ),
];

Future<String> _tap(
  FlutterDriver driver,
  SerializableFinder finder,
  String description,
  Duration timeout,
) async {
  await driver.tap(finder, timeout: timeout);
  return 'tapped $description';
}

/// Finder specs for `get-text`.
SerializableFinder parseFinder(String spec) {
  const kinds = 'text:<text>, key:<key>, label:<label> or type:<WidgetType>';
  final separator = spec.indexOf(':');
  if (separator <= 0 || separator == spec.length - 1) {
    throw UsageException('finder must be $kinds, got "$spec"');
  }
  final kind = spec.substring(0, separator);
  final value = spec.substring(separator + 1);
  switch (kind) {
    case 'text':
      return find.text(value);
    case 'key':
      return find.byValueKey(value);
    case 'label':
      // The driver's getText only reads Text-like widgets, and ByLabel resolves
      // to the Semantics or Tooltip widget itself, so read the Text inside it.
      return find.descendant(
        of: ByLabel(value),
        matching: find.byType('Text'),
        matchRoot: false,
      );
    case 'type':
      return find.byType(value);
  }
  throw UsageException('unknown finder kind "$kind"; use $kinds');
}

class Invocation {
  Invocation({
    required this.command,
    required this.args,
    required this.vmServiceUrl,
    required this.timeout,
    required this.verbose,
  });

  final DriveCommand command;
  final List<String> args;
  final String? vmServiceUrl;
  final Duration timeout;
  final bool verbose;
}

/// Options may appear before or after the command and its arguments.
Invocation parseArgs(List<String> argv) {
  String? vmServiceUrl;
  var timeout = defaultTimeout;
  var verbose = false;
  final positional = <String>[];

  for (var i = 0; i < argv.length; i++) {
    final token = argv[i];
    switch (token) {
      case vmServiceUrlOption:
      case timeoutOption:
        if (i + 1 >= argv.length) {
          throw UsageException('$token needs a value');
        }
        final value = argv[++i];
        if (token == vmServiceUrlOption) {
          vmServiceUrl = value;
        } else {
          final seconds = int.tryParse(value);
          if (seconds == null || seconds <= 0) {
            throw UsageException(
                '$timeoutOption needs a positive number of seconds, got "$value"');
          }
          timeout = Duration(seconds: seconds);
        }
        break;
      case verboseFlag:
        verbose = true;
        break;
      default:
        if (token.startsWith('--')) {
          throw UsageException('unknown option $token');
        }
        positional.add(token);
    }
  }

  if (positional.isEmpty) {
    throw UsageException('missing command');
  }
  final name = positional.first;
  final command = commands.cast<DriveCommand?>().firstWhere(
        (candidate) => candidate!.name == name,
        orElse: () => null,
      );
  if (command == null) {
    throw UsageException('unknown command "$name"');
  }
  final args = positional.sublist(1);
  if (args.length != command.argCount) {
    throw UsageException(
        '${command.name} takes ${command.argCount} argument(s): ${command.usage}');
  }

  return Invocation(
    command: command,
    args: args,
    vmServiceUrl: vmServiceUrl,
    timeout: timeout,
    verbose: verbose,
  );
}

String usage() {
  final width = commands.map((command) => command.usage.length).reduce(
        (longest, length) => length > longest ? length : longest,
      );
  final table = commands
      .map((command) => '  ${command.usage.padRight(width)}  ${command.help}')
      .join('\n');
  return '''
Usage: dart run tool/drive.dart $vmServiceUrlOption <url> [options] <command> [args]

Drives a VFX GUI started from lib/main_automation.dart (make run_macos_driver).
<url> is the "An Observatory debugger and profiler on macOS is available at:"
line of `flutter run` (newer SDKs say "A Dart VM Service"), token and trailing
slash included; VM_SERVICE_URL in the environment works too.

Commands:
$table

Options:
  $timeoutOption <seconds>  Budget for the command (default ${defaultTimeout.inSeconds}).
  $verboseFlag           Print the driver's connection log and full errors.
  --help, -h          Print this text.

Exit codes: 0 done, $exitCommandFailed the app rejected the command, $exitUsage usage error.''';
}

/// The driver wraps app-side failures in several layers; the first line of
/// the innermost message is what says which widget was missing.
String describeError(Object error, {required bool verbose}) {
  if (verbose) {
    return '$error';
  }
  Object innermost = error;
  while (innermost is DriverError && innermost.originalError != null) {
    innermost = innermost.originalError!;
  }
  final message =
      innermost is DriverError ? innermost.message : innermost.toString();
  final firstLine = message.split('\n').first;
  String hint = '';
  if (firstLine.contains('Bad state: No element')) {
    hint = ' (no widget matched)';
  } else if (firstLine.contains('Too many elements')) {
    hint = ' (more than one widget matched; use a key)';
  } else if (firstLine.contains('Timeout while executing')) {
    hint = ' (no widget matched within the timeout)';
  }
  return '$firstLine$hint';
}

Future<void> main(List<String> argv) async {
  if (argv.isEmpty || argv.contains('--help') || argv.contains('-h')) {
    stdout.writeln(usage());
    return;
  }

  final Invocation invocation;
  try {
    invocation = parseArgs(argv);
  } on UsageException catch (e) {
    stderr.writeln('error: ${e.message}\n');
    stderr.writeln(usage());
    exit(exitUsage);
  }

  final url = invocation.vmServiceUrl ?? Platform.environment['VM_SERVICE_URL'];
  if (url == null || url.isEmpty) {
    stderr.writeln(
        'error: pass $vmServiceUrlOption <url> or set VM_SERVICE_URL\n');
    stderr.writeln(usage());
    exit(exitUsage);
  }

  driverLog = (String source, String message) {
    if (invocation.verbose) {
      stderr.writeln('$source: $message');
    }
  };

  final FlutterDriver driver;
  try {
    driver = await FlutterDriver.connect(
      dartVmServiceUrl: url,
      logCommunicationToFile: false,
    ).timeout(connectTimeout);
  } on TimeoutException {
    stderr.writeln('error: no Flutter Driver extension answered at $url within '
        '${connectTimeout.inSeconds}s. Check the URL (it changes on every '
        'flutter run) and that the app runs from lib/main_automation.dart '
        '(make run_macos_driver).');
    exit(exitCommandFailed);
  } catch (e) {
    stderr.writeln('error: could not connect to $url: '
        '${describeError(e, verbose: invocation.verbose)}');
    exit(exitCommandFailed);
  }

  var exitCode = 0;
  try {
    // The boot screen animates forever, so frame sync would make every
    // command wait for a settled frame that never comes.
    final output = await driver.runUnsynchronized(
      () => invocation.command.run(driver, invocation.args, invocation.timeout),
      timeout: invocation.timeout,
    );
    stdout.writeln(output);
  } on UsageException catch (e) {
    stderr.writeln('error: ${e.message}');
    exitCode = exitUsage;
  } catch (e) {
    stderr.writeln('error: ${invocation.command.name} failed: '
        '${describeError(e, verbose: invocation.verbose)}');
    exitCode = exitCommandFailed;
  } finally {
    await driver.close();
  }
  exit(exitCode);
}
