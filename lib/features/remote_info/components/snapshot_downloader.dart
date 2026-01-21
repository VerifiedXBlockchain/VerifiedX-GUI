import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/env.dart';
import '../../../core/models/snapshot_info.dart';
import '../../../core/providers/session_provider.dart';
import '../../../core/theme/app_theme.dart';
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
  int bytesDownloaded = 0;
  int totalBytes = 0;
  bool isInitializing = true;
  bool isDownloading = false;
  bool isReady = false;
  String? currentFile;
  int filesDownloaded = 0;
  int totalFiles = 0;

  @override
  void initState() {
    super.initState();
    totalBytes = widget.snapshotInfo.totalSizeBytes ?? 0;
    totalFiles = widget.snapshotInfo.urls?.length ?? 0;

    print('[SnapshotDownloader] initState - totalSizeBytes from API: ${widget.snapshotInfo.totalSizeBytes}');
    print('[SnapshotDownloader] initState - totalBytes set to: $totalBytes');

    Future.delayed(const Duration(milliseconds: 300)).then((_) {
      init();
    });
  }

  Future<void> init() async {
    await widget.ref.read(sessionProvider.notifier).stopCli();
    download();
  }

  Future<void> download() async {
    setState(() {
      isInitializing = false;
      isDownloading = true;
    });

    print('[SnapshotDownloader] Starting download...');
    print('[SnapshotDownloader] snapshotInfo: ${widget.snapshotInfo}');
    print('[SnapshotDownloader] urls: ${widget.snapshotInfo.urls}');
    print('[SnapshotDownloader] totalBytes: $totalBytes, totalFiles: $totalFiles');

    try {
      final _dbPath = await dbPath();
      print('[SnapshotDownloader] dbPath: $_dbPath');
      final dir = Directory(_dbPath);

      // Delete existing DB folder if it exists
      if (await dir.exists()) {
        print('[SnapshotDownloader] Deleting existing folder: $_dbPath');
        try {
          await dir.delete(recursive: true);
          print('[SnapshotDownloader] Deleted successfully');
        } catch (e) {
          print('[SnapshotDownloader] Delete failed: $e');
          // Try to at least delete the Databases subfolder
          try {
            final fallbackSep = Platform.isWindows ? '\\' : '/';
            final dbSubfolder = Directory("$_dbPath${fallbackSep}Databases${Env.isTestNet || Env.isDevnet ? 'TestNet' : ''}");
            if (await dbSubfolder.exists()) {
              await dbSubfolder.delete(recursive: true);
              print('[SnapshotDownloader] Deleted Databases subfolder');
            }
          } catch (e2) {
            print('[SnapshotDownloader] Subfolder delete also failed: $e2');
          }
        }
      } else {
        print('[SnapshotDownloader] No existing dir: $_dbPath');
      }

      // Create new DB folder
      await Directory(_dbPath).create(recursive: true);
      final sep = Platform.isWindows ? '\\' : '/';
      final dbFolder = "$_dbPath${sep}Databases${Env.isTestNet || Env.isDevnet ? 'TestNet' : ''}";
      await Directory(dbFolder).create(recursive: true);
      print('[SnapshotDownloader] Created dbFolder: $dbFolder');

      final urls = widget.snapshotInfo.urls ?? [];
      print('[SnapshotDownloader] Downloading ${urls.length} files');

      if (urls.isEmpty) {
        print('[SnapshotDownloader] ERROR: No URLs to download!');
        return;
      }

      final dio = Dio();
      int cumulativeBytes = 0;

      for (final url in urls) {
        final filename = url.split('/').last;
        final filePath = "$dbFolder$sep$filename";

        print('[SnapshotDownloader] Downloading: $url -> $filePath');

        setState(() {
          currentFile = filename;
        });

        try {
          await dio.download(
            url,
            filePath,
            onReceiveProgress: (received, fileTotal) {
              setState(() {
                bytesDownloaded = cumulativeBytes + received;
              });
            },
          );

          // Get actual file size after download
          final file = File(filePath);
          if (await file.exists()) {
            final fileSize = await file.length();
            cumulativeBytes += fileSize;
            setState(() {
              bytesDownloaded = cumulativeBytes;
            });
          }

          print('[SnapshotDownloader] Completed: $filename');
        } catch (e) {
          print('[SnapshotDownloader] Failed to download $filename: $e (skipping)');
          // Continue to next file on error (404, network issue, etc)
        }

        filesDownloaded++;
      }

      // Adjust final bytesDownloaded to match totalBytes
      setState(() {
        bytesDownloaded = totalBytes;
      });

      print('[SnapshotDownloader] All downloads complete');
      downloadComplete();
    } catch (e, st) {
      print('[SnapshotDownloader] ERROR: $e');
      print('[SnapshotDownloader] Stack: $st');
    }
  }

  Future<void> downloadComplete() async {
    setState(() {
      isDownloading = false;
      isReady = true;
    });

    await widget.ref.read(sessionProvider.notifier).init(false);
    await widget.ref.read(sessionProvider.notifier).fetchConfig();
  }

  @override
  Widget build(BuildContext context) {
    final double percent =
        totalBytes > 0 ? (bytesDownloaded / totalBytes).clamp(0.0, 1.0) : 0;

    String title = "Initializing...";
    if (isDownloading) {
      title = "Downloading...";
    }
    if (isReady) {
      title = "All done!";
    }

    return AlertDialog(
      title: Text(title),
      content: SizedBox(
        width: 600,
        child: Builder(builder: (context) {
          if (isInitializing) {
            return const Text("Shutting down CLI...");
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
                      "Downloading: $currentFile",
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colors.white54,
                          ),
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
                const Text("Database Snapshot Imported."),
                const SizedBox(height: 4),
                const Text(
                  "Starting up CLI now...",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 16),
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text(
                    "Close",
                    style: TextStyle(color: Colors.white70),
                  ),
                ),
              ],
            );
          }

          return const Text("An error occurred. Please restart and try again.");
        }),
      ),
    );
  }
}
