import 'dart:async';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:open_filex/open_filex.dart';
import 'package:path_provider/path_provider.dart';

/// Representation of the download progress for an APK update.
class DownloadProgress {
  final int receivedBytes;
  final int totalBytes;
  final double? progress; // 0.0 to 1.0, or null if total is unknown

  const DownloadProgress({
    required this.receivedBytes,
    required this.totalBytes,
    this.progress,
  });

  /// User-friendly formatted string of received bytes (e.g. '12.4 MB').
  String get receivedFormatted => _formatBytes(receivedBytes);

  /// User-friendly formatted string of total bytes (e.g. '35.8 MB' or 'Unknown size').
  String get totalFormatted => totalBytes > 0 ? _formatBytes(totalBytes) : 'Unknown size';

  /// Percentage string (e.g. '42%').
  String get percentString => progress != null ? '${(progress! * 100).toInt()}%' : '';

  static String _formatBytes(int bytes) {
    if (bytes < 1024 * 1024) {
      return '${(bytes / 1024).toStringAsFixed(1)} KB';
    }
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }
}

/// Service handling the in-app download and installation of APK packages.
class ApkDownloadService {
  final http.Client _client;
  final Future<OpenResult> Function(String filePath)? _openFileHandler;
  final Future<Directory> Function()? _tempDirProvider;
  bool _isCancelled = false;

  ApkDownloadService({
    http.Client? client,
    Future<OpenResult> Function(String filePath)? openFileHandler,
    Future<Directory> Function()? tempDirProvider,
  })  : _client = client ?? http.Client(),
        _openFileHandler = openFileHandler,
        _tempDirProvider = tempDirProvider;

  /// Starts downloading the APK from [url] and triggers package installation upon completion.
  Future<OpenResult> downloadAndInstall({
    required String url,
    required void Function(DownloadProgress progress) onProgress,
  }) async {
    _isCancelled = false;

    final tempDirProvider = _tempDirProvider;
    final tempDir = tempDirProvider != null
        ? await tempDirProvider()
        : await getTemporaryDirectory();
    final saveFile = File('${tempDir.path}/moneymate-update.apk');

    if (await saveFile.exists()) {
      try {
        await saveFile.delete();
      } catch (_) {
        // Ignore deletion failures for prior temp files
      }
    }

    final uri = Uri.parse(url);
    final request = http.Request('GET', uri)
      ..headers['User-Agent'] = 'MoneyMate-App';

    final streamedResponse = await _client.send(request);

    if (streamedResponse.statusCode < 200 || streamedResponse.statusCode >= 300) {
      throw Exception('Server returned status code ${streamedResponse.statusCode}');
    }

    final totalBytes = streamedResponse.contentLength ?? -1;
    var receivedBytes = 0;

    final sink = saveFile.openWrite();

    try {
      await for (final chunk in streamedResponse.stream) {
        if (_isCancelled) {
          await sink.close();
          if (await saveFile.exists()) {
            await saveFile.delete();
          }
          throw Exception('Download was cancelled');
        }
        sink.add(chunk);
        receivedBytes += chunk.length;

        final progress = totalBytes > 0
            ? (receivedBytes / totalBytes).clamp(0.0, 1.0)
            : null;

        onProgress(DownloadProgress(
          receivedBytes: receivedBytes,
          totalBytes: totalBytes,
          progress: progress,
        ));
      }
      await sink.flush();
    } finally {
      await sink.close();
    }

    // Launch package installer
    final openFileHandler = _openFileHandler;
    if (openFileHandler != null) {
      return await openFileHandler(saveFile.path);
    }

    return await OpenFilex.open(
      saveFile.path,
      type: 'application/vnd.android.package-archive',
    );
  }

  /// Cancels an in-progress download.
  void cancel() {
    _isCancelled = true;
  }
}
