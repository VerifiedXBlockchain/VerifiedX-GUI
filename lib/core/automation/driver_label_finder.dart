import 'package:flutter/material.dart';
import 'package:flutter_driver/driver_extension.dart';
// SerializableFinder lives in the driver-side library only.
import 'package:flutter_driver/flutter_driver.dart' show SerializableFinder;
import 'package:flutter_test/flutter_test.dart';

/// Finder type name shared with `tool/drive.dart`, which builds the same
/// `{finderType: 'ByLabel', label: ...}` map on the driver side.
const byLabelFinderType = 'ByLabel';

/// Whether [widget] carries [label] the way this app labels its controls: as
/// the `label` of a [Semantics] widget (icon-only tap targets,
/// `Icon.semanticLabel`) or as a [Tooltip] message (`IconButton.tooltip`).
///
/// This reads the widget tree, not the platform accessibility tree. The macOS
/// embedder in Flutter 3.7.12 asserts when semantics are forced on without an
/// assistive client, so `find.bySemanticsLabel` cannot be used there.
bool widgetHasLabel(Widget widget, String label) {
  if (widget is Semantics) {
    return widget.properties.label == label;
  }
  if (widget is Tooltip) {
    return widget.message == label;
  }
  return false;
}

/// Driver-side description of a [widgetHasLabel] search.
class ByLabel extends SerializableFinder {
  const ByLabel(this.label);

  final String label;

  @override
  String get finderType => byLabelFinderType;

  @override
  Map<String, String> serialize() =>
      super.serialize()..addAll(<String, String>{'label': label});
}

/// Registers [ByLabel] with the driver extension; see `lib/main_automation.dart`.
class ByLabelFinderExtension extends FinderExtension {
  @override
  String get finderType => byLabelFinderType;

  @override
  SerializableFinder deserialize(
    Map<String, String> params,
    DeserializeFinderFactory finderFactory,
  ) {
    final label = params['label'];
    if (label == null) {
      throw ArgumentError('$byLabelFinderType finder is missing its label');
    }
    return ByLabel(label);
  }

  @override
  Finder createFinder(
    SerializableFinder finder,
    CreateFinderFactory finderFactory,
  ) {
    final label = (finder as ByLabel).label;
    return find.byWidgetPredicate(
      (widget) => widgetHasLabel(widget, label),
      description: 'control labelled "$label"',
    );
  }
}
