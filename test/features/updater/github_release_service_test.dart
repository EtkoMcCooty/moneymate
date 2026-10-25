import 'package:flutter_test/flutter_test.dart';
import 'package:moneymate/features/updater/models/app_release.dart';
import 'package:moneymate/features/updater/services/github_release_service.dart';

void main() {
  group('GitHubReleaseService & AppRelease', () {
    test('parses AppRelease from GitHub API json response', () {
      final jsonResponse = {
        'tag_name': 'release-v0.2.0',
        'name': 'Release v0.2.0 - New Features',
        'body': 'Here is what changed:\n- Added database support\n- Better performance',
        'published_at': '2026-10-25T18:00:00Z',
        'html_url': 'https://github.com/EtkoMcCooty/moneymate/releases/tag/release-v0.2.0',
        'assets': [
          {
            'name': 'app-release.apk',
            'browser_download_url': 'https://github.com/EtkoMcCooty/moneymate/releases/download/release-v0.2.0/app-release.apk',
            'size': 45123992,
          },
          {
            'name': 'source.tar.gz',
            'browser_download_url': 'https://github.com/EtkoMcCooty/moneymate/archive/refs/tags/release-v0.2.0.tar.gz',
            'size': 120400,
          }
        ]
      };

      final release = AppRelease.fromJson(jsonResponse);

      expect(release.tagName, equals('release-v0.2.0'));
      expect(release.version, equals('0.2.0'));
      expect(release.title, equals('Release v0.2.0 - New Features'));
      expect(release.notes, contains('Added database support'));
      expect(release.apkUrl, equals('https://github.com/EtkoMcCooty/moneymate/releases/download/release-v0.2.0/app-release.apk'));
    });

    test('isUpdateAvailable correctly compares semantic versions', () {
      // Newer versions available
      expect(GitHubReleaseService.isUpdateAvailable('0.1.0', '0.2.0'), isTrue);
      expect(GitHubReleaseService.isUpdateAvailable('0.1.0', 'release-v0.1.1'), isTrue);
      expect(GitHubReleaseService.isUpdateAvailable('1.0.0', 'v2.0.0'), isTrue);
      expect(GitHubReleaseService.isUpdateAvailable('0.1.0+1', '0.1.0+2'), isTrue);

      // Same or older versions
      expect(GitHubReleaseService.isUpdateAvailable('0.2.0', '0.2.0'), isFalse);
      expect(GitHubReleaseService.isUpdateAvailable('1.5.0', '1.4.9'), isFalse);
      expect(GitHubReleaseService.isUpdateAvailable('2.0.0', 'release-v1.9.9'), isFalse);
    });

    test('cleanVersion strips prefixes and metadata', () {
      expect(GitHubReleaseService.cleanVersion('release-v1.2.3'), equals('1.2.3'));
      expect(GitHubReleaseService.cleanVersion('v2.0.1'), equals('2.0.1'));
      expect(GitHubReleaseService.cleanVersion('3.4.5'), equals('3.4.5'));
    });
  });
}
