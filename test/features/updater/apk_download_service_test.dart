import 'dart:convert';
import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:open_filex/open_filex.dart';
import 'package:moneymate/features/updater/services/apk_download_service.dart';

void main() {
  group('ApkDownloadService', () {
    late Directory tempDir;

    setUp(() async {
      tempDir = await Directory.systemTemp.createTemp('apk_download_test_');
    });

    tearDown(() async {
      if (await tempDir.exists()) {
        await tempDir.delete(recursive: true);
      }
    });

    test('downloads APK stream, reports progress, and calls openFileHandler', () async {
      final fakeApkBytes = utf8.encode('Fake APK Binary Content');
      String? openedPath;

      final mockClient = MockClient((request) async {
        return http.Response.bytes(
          fakeApkBytes,
          200,
          headers: {'content-length': fakeApkBytes.length.toString()},
        );
      });

      final progressUpdates = <DownloadProgress>[];

      final service = ApkDownloadService(
        client: mockClient,
        tempDirProvider: () async => tempDir,
        openFileHandler: (path) async {
          openedPath = path;
          return OpenResult(type: ResultType.done, message: 'done');
        },
      );

      final result = await service.downloadAndInstall(
        url: 'https://example.com/app.apk',
        onProgress: (p) => progressUpdates.add(p),
      );

      expect(result.type, equals(ResultType.done));
      expect(openedPath, isNotNull);
      expect(openedPath, contains('moneymate-update.apk'));

      // Verify file content on disk
      final savedFile = File(openedPath!);
      expect(await savedFile.exists(), isTrue);
      expect(await savedFile.readAsBytes(), equals(fakeApkBytes));

      // Verify progress reporting
      expect(progressUpdates, isNotEmpty);
      expect(progressUpdates.last.progress, equals(1.0));
      expect(progressUpdates.last.receivedBytes, equals(fakeApkBytes.length));
    });

    test('throws exception when HTTP status is not 200', () async {
      final mockClient = MockClient((request) async {
        return http.Response('Not Found', 404);
      });

      final service = ApkDownloadService(
        client: mockClient,
        tempDirProvider: () async => tempDir,
      );

      expect(
        () => service.downloadAndInstall(
          url: 'https://example.com/missing.apk',
          onProgress: (_) {},
        ),
        throwsA(isA<Exception>()),
      );
    });

    test('DownloadProgress format helper handles byte formatting', () {
      const p1 = DownloadProgress(receivedBytes: 500 * 1024, totalBytes: 1000 * 1024, progress: 0.5);
      expect(p1.receivedFormatted, equals('500.0 KB'));
      expect(p1.totalFormatted, equals('1000.0 KB'));
      expect(p1.percentString, equals('50%'));

      const p2 = DownloadProgress(receivedBytes: 15 * 1024 * 1024, totalBytes: 30 * 1024 * 1024, progress: 0.5);
      expect(p2.receivedFormatted, equals('15.0 MB'));
      expect(p2.totalFormatted, equals('30.0 MB'));

      const p3 = DownloadProgress(receivedBytes: 1024, totalBytes: -1);
      expect(p3.totalFormatted, equals('Unknown size'));
      expect(p3.percentString, equals(''));
    });
  });
}
