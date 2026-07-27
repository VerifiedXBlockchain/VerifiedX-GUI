import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/env.dart';
import '../../../core/models/snapshot_info.dart';
import '../../../core/providers/session_provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/services/base_service.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../../l10n/l10n_helper.dart';
import '../../../utils/files.dart';
import '../../../utils/formatting.dart';

class SnapshotDownloader extends StatefulWidget {
  final SnapshotInfo snapshotInfo;
  final Ref ref;

  const SnapshotDownloader({
    Key? key,
    required this.snapshotInfo,
    required this.ref,
  }) : super(key: key);

  @override
  State<SnapshotDownloader> createState() => _SnapshotDownloaderState();
}

class _SnapshotDownloaderState extends State<SnapshotDownloader> {
  static const int _maxRetries = 3;
  static const Duration _retryDelay = Duration(seconds: 3);

  int bytesDownloaded = 0;
  int totalBytes = 0;
  bool isInitializing = true;
  bool isDownloading = false;
  bool isReady = false;
  bool hasFailed = false;
  String? currentFile;
  String? errorMessage;
  int filesDownloaded = 0;
  int totalFiles = 0;
  DateTime _lastProgressUpdate = DateTime.now();

  @override
  void initState() {
    super.initState();
    totalBytes = widget.snapshotInfo.totalSizeBytes ?? 0;
    totalFiles = widget.snapshotInfo.urls?.length ?? 0;

    Future.delayed(const Duration(milliseconds: 300)).then((_) {
      _start();
    });
  }

  Future<void> _start() async {
    BaseService.suppressErrors = true;
    print('[Snapshot] === STEP 1: SHUTTING DOWN CLI ===');
    await widget.ref.read(sessionProvider.notifier).stopCli();
    print('[Snapshot] CLI stopped');
    _download();
  }

  Future<void> _download() async {
    setState(() {
      isInitializing = false;
      isDownloading = true;
    });

    final _dbPath = await dbPath();
    final sep = Platform.isWindows ? '\\' : '/';
    final dbFolder =
        "$_dbPath${sep}Databases${Env.isTestNet || Env.isDevnet ? 'TestNet' : ''}";

    try {
      // --- Step 2: Delete existing folder ---
      print('[Snapshot] === STEP 2: DELETE ~/rbx ===');
      print('[Snapshot] dbPath: $_dbPath');
      final dir = Directory(_dbPath);

      if (await dir.exists()) {
        await dir.delete(recursive: true);
        print('[Snapshot] Deleted $_dbPath');
      }

      if (await Directory(_dbPath).exists()) {
        _fail(globalL10n.r3eFailedDeleteDb(_dbPath));
        return;
      }

      // --- Step 3: Create fresh folders ---
      print('[Snapshot] === STEP 3: CREATE FRESH FOLDERS ===');
      await Directory(dbFolder).create(recursive: true);
      print('[Snapshot] Created $dbFolder');

      // --- Step 4: Download files ---
      final urls = widget.snapshotInfo.urls ?? [];
      print('[Snapshot] === STEP 4: DOWNLOAD ${urls.length} FILES ===');

      if (urls.isEmpty) {
        _fail(globalL10n.r3eSnapshotNoUrls);
        return;
      }

      final dio = Dio(BaseOptions(
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: Duration.zero, // No receive timeout for large files
      ));
      int cumulativeBytes = 0;

      for (int i = 0; i < urls.length; i++) {
        final url = urls[i];
        final filename = url.split('/').last;
        final filePath = "$dbFolder$sep$filename";

        setState(() {
          currentFile = filename;
        });

        final fileSize = await _downloadFileWithRetry(
          dio: dio,
          url: url,
          filePath: filePath,
          fileIndex: i + 1,
          fileCount: urls.length,
          cumulativeBytes: cumulativeBytes,
        );

        if (fileSize == null) {
          _fail(globalL10n.r3eFailedDownloadFile(
              filename, _maxRetries.toString()));
          return;
        }

        cumulativeBytes += fileSize;
        setState(() {
          bytesDownloaded = cumulativeBytes;
        });
        filesDownloaded++;
      }

      // --- Verification ---
      print('[Snapshot] === DOWNLOAD COMPLETE ===');
      print('[Snapshot] All ${urls.length} files downloaded');

      final entries = Directory(dbFolder).listSync();
      int totalDiskBytes = 0;
      for (final f in entries) {
        if (f is File) {
          final size = await f.length();
          totalDiskBytes += size;
          print(
              '[Snapshot]   ${f.path.split(sep).last} — ${(size / 1048576).toStringAsFixed(1)} MB');
        }
      }
      print(
          '[Snapshot] Total on disk: ${(totalDiskBytes / 1073741824).toStringAsFixed(2)} GB (expected: ${(totalBytes / 1073741824).toStringAsFixed(2)} GB)');

      if (entries.length < urls.length) {
        _fail(globalL10n.r3eFilesOnDiskMismatch(
            entries.length.toString(), urls.length.toString()));
        return;
      }

      // --- Step 5: Restart CLI ---
      print('[Snapshot] === STEP 5: STARTING CLI ===');
      await _completeImport(dbFolder, sep);
    } catch (e, st) {
      print('[Snapshot] FATAL: $e\n$st');
      _fail(globalL10n.r3eUnexpectedError(e.toString()));
    }
  }

  /// Downloads a single file with retry + resume logic.
  /// Returns file size on success, null on failure after all retries.
  Future<int?> _downloadFileWithRetry({
    required Dio dio,
    required String url,
    required String filePath,
    required int fileIndex,
    required int fileCount,
    required int cumulativeBytes,
  }) async {
    final filename = url.split('/').last;

    // Get expected file size via HEAD request
    int? expectedSize;
    try {
      final head = await dio.head<void>(url);
      expectedSize = int.tryParse(
          head.headers.value(HttpHeaders.contentLengthHeader) ?? '');
      if (expectedSize != null) {
        print('[Snapshot] [$fileIndex/$fileCount] $filename — expected ${(expectedSize / 1048576).toStringAsFixed(1)} MB');
      }
    } catch (_) {
      // HEAD failed — we can still download, just can't verify size
    }

    for (int attempt = 1; attempt <= _maxRetries; attempt++) {
      if (attempt > 1) {
        await Future.delayed(_retryDelay);
      }

      final file = File(filePath);
      int existingBytes = 0;
      if (await file.exists()) {
        existingBytes = await file.length();
      }

      // If we already have the complete file from a previous attempt, skip
      if (expectedSize != null && existingBytes == expectedSize && existingBytes > 0) {
        print('[Snapshot] [$fileIndex/$fileCount] $filename — already complete on disk');
        return existingBytes;
      }

      // Decide whether to resume or start fresh
      final bool resuming = existingBytes > 0;
      if (resuming) {
        print('[Snapshot] [$fileIndex/$fileCount] Resuming $filename at ${(existingBytes / 1048576).toStringAsFixed(1)} MB (attempt $attempt)');
      } else {
        print('[Snapshot] [$fileIndex/$fileCount] Downloading: $filename'
            '${attempt > 1 ? " (attempt $attempt)" : ""}');
      }

      try {
        if (resuming) {
          // Resume: request remaining bytes, append to existing file
          final response = await dio.get<ResponseBody>(
            url,
            options: Options(
              responseType: ResponseType.stream,
              headers: {HttpHeaders.rangeHeader: 'bytes=$existingBytes-'},
            ),
          );

          // If server doesn't support range (200 instead of 206), start over
          if (response.statusCode == 200) {
            print('[Snapshot]   Server returned 200 — restarting from scratch');
            await file.delete();
            existingBytes = 0;
            // Fall through to fresh download below
          } else if (response.statusCode == 206) {
            final sink = file.openWrite(mode: FileMode.append);
            int received = existingBytes;
            try {
              await for (final chunk in response.data!.stream) {
                sink.add(chunk);
                received += chunk.length;
                final now = DateTime.now();
                if (now.difference(_lastProgressUpdate).inMilliseconds > 250) {
                  _lastProgressUpdate = now;
                  setState(() {
                    bytesDownloaded = cumulativeBytes + received;
                  });
                }
              }
            } finally {
              await sink.flush();
              await sink.close();
            }

            final finalSize = await file.length();
            if (expectedSize != null && finalSize != expectedSize) {
              print('[Snapshot]   Size mismatch: got $finalSize, expected $expectedSize — will retry');
              await file.delete();
              continue;
            }
            if (finalSize == 0) {
              print('[Snapshot]   File is 0 bytes — will retry');
              continue;
            }

            print('[Snapshot]   OK: $filename — ${(finalSize / 1048576).toStringAsFixed(1)} MB (resumed)');
            return finalSize;
          }
        }

        // Fresh download (no partial file, or resume wasn't possible)
        if (await file.exists()) {
          await file.delete();
        }

        await dio.download(
          url,
          filePath,
          onReceiveProgress: (received, fileTotal) {
            final now = DateTime.now();
            if (now.difference(_lastProgressUpdate).inMilliseconds > 250) {
              _lastProgressUpdate = now;
              setState(() {
                bytesDownloaded = cumulativeBytes + received;
              });
            }
          },
        );

        final finalSize = await file.length();
        if (expectedSize != null && finalSize != expectedSize) {
          print('[Snapshot]   Size mismatch: got $finalSize, expected $expectedSize — will retry');
          // Keep the partial file for resume on next attempt
          continue;
        }
        if (finalSize == 0) {
          print('[Snapshot]   File is 0 bytes — will retry');
          continue;
        }

        print('[Snapshot]   OK: $filename — ${(finalSize / 1048576).toStringAsFixed(1)} MB');
        return finalSize;
      } catch (e) {
        print('[Snapshot]   Error on attempt $attempt: $e');
        // Keep partial file on disk for resume on next attempt
        if (attempt == _maxRetries) {
          print('[Snapshot]   All retries exhausted for $filename');
          return null;
        }
      }
    }

    return null;
  }

  void _fail(String message) {
    print('[Snapshot] FAILED: $message');
    BaseService.suppressErrors = false;
    setState(() {
      isDownloading = false;
      hasFailed = true;
      errorMessage = message;
    });
  }

  Future<void> _completeImport(String dbFolder, String sep) async {
    setState(() {
      isDownloading = false;
      isReady = true;
    });

    BaseService.suppressErrors = false;
    await widget.ref.read(sessionProvider.notifier).init(false);
    await widget.ref.read(sessionProvider.notifier).fetchConfig();

    // Post-startup verification
    final postDir = Directory(dbFolder);
    if (await postDir.exists()) {
      final files = postDir.listSync().whereType<File>().toList();
      print('[Snapshot] Post-startup: ${files.length} files still in $dbFolder');
    } else {
      print(
          '[Snapshot] WARNING: $dbFolder missing after CLI startup');
    }
    print('[Snapshot] === SNAPSHOT IMPORT COMPLETE ===');
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final double percent =
        totalBytes > 0 ? (bytesDownloaded / totalBytes).clamp(0.0, 1.0) : 0;

    String title = l10n.hnavSnapshotInitializing;
    if (isDownloading) {
      title = l10n.hnavSnapshotDownloading;
    }
    if (isReady) {
      title = l10n.hnavSnapshotAllDone;
    }
    if (hasFailed) {
      title = l10n.svcSnapshotImportFailedTitle;
    }

    return AlertDialog(
      title: Text(title),
      content: SizedBox(
        width: 600,
        child: Builder(builder: (context) {
          if (isInitializing) {
            return Text(l10n.hnavSnapshotShuttingDown);
          }

          if (isDownloading) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  "${(percent * 100).round()}%",
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 24,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: LinearProgressIndicator(
                    color: Colors.green,
                    minHeight: 12,
                    backgroundColor: Colors.black45,
                    value: percent,
                  ),
                ),
                Text(
                  "${(bytesDownloaded / 1073741824).toStringAsFixed(2)} GB / ${(totalBytes / 1073741824).toStringAsFixed(2)} GB",
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                if (currentFile != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Text(
                      l10n.hnavSnapshotDownloadingProgress(currentFile!, filesDownloaded, totalFiles),
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colors.white54,
                          ),
                    ),
                  ),
              ],
            );
          }

          if (hasFailed) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.error_outline,
                  size: 40,
                  color: Colors.redAccent,
                ),
                const SizedBox(height: 8),
                Text(l10n.svcSnapshotImportFailedBody),
                if (errorMessage != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Text(
                      errorMessage!,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colors.white54,
                          ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                const SizedBox(height: 8),
                Text(
                  l10n.svcSnapshotRestartTryAgain,
                  style: const TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 16),
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text(
                    l10n.actionClose,
                    style: const TextStyle(color: Colors.white70),
                  ),
                ),
              ],
            );
          }

          if (isReady) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.check,
                  size: 40,
                  color: Theme.of(context).colorScheme.success,
                ),
                const SizedBox(height: 8),
                Text(l10n.hnavSnapshotImported),
                const SizedBox(height: 4),
                Text(
                  l10n.hnavSnapshotStartingUp,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 16),
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text(
                    l10n.actionClose,
                    style: const TextStyle(color: Colors.white70),
                  ),
                ),
              ],
            );
          }

          return Text(l10n.hnavSnapshotError);
        }),
      ),
    );
  }
}
