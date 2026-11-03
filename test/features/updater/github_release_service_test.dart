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

    test('cleanReleaseNotes removes automated generic boilerplate', () {
      const genericBody = '''
Automated MoneyMate build for official release.

### 📱 Download & Sideload
Direct APK download: [app-release.apk](app-release.apk)
''';
      final cleaned = AppRelease.cleanReleaseNotes(genericBody);
      expect(cleaned, equals('• General performance improvements and bug fixes.'));
      expect(cleaned, isNot(contains('Automated MoneyMate build')));
      expect(cleaned, isNot(contains('Download & Sideload')));
    });

    test('cleanReleaseNotes formats commits into user-friendly bullet points and preserves hotfix prefix', () {
      const mixedChangelog = '''
### 🚀 What's New
* feat(tracker): add category color coding (#12)
* fix(dialog): correct due date ordinal
* hotfix: resolve crash when opening settings (#15)
* docs(rules): enforce zero-guesswork defect elimination
* chore(deps): bump flutter packages
* ci(actions): update workflow permissions
- Users can now delete items directly from the tracker

**Full Changelog**: https://github.com/EtkoMcCooty/moneymate/commits/v0.2.0
''';
      final cleaned = AppRelease.cleanReleaseNotes(mixedChangelog);
      expect(cleaned, contains('🚀 What\'s New'));
      expect(cleaned, contains('• Add category color coding'));
      expect(cleaned, contains('• Correct due date ordinal'));
      expect(cleaned, contains('• hotfix: Resolve crash when opening settings'));
      expect(cleaned, contains('• Users can now delete items directly from the tracker'));
      expect(cleaned, isNot(contains('docs(rules)')));
      expect(cleaned, isNot(contains('chore(deps)')));
      expect(cleaned, isNot(contains('ci(actions)')));
      expect(cleaned, isNot(contains('Full Changelog')));
    });

    test('default repo points to moneymate', () {
      final service = GitHubReleaseService();
      expect(service.owner, equals('EtkoMcCooty'));
      expect(service.repo, equals('moneymate'));
    });

    test('isUpdateAvailable correctly compares semantic versions and build numbers', () {
      // Newer versions available
      expect(GitHubReleaseService.isUpdateAvailable('0.1.0', '0.2.0'), isTrue);
      expect(GitHubReleaseService.isUpdateAvailable('0.1.0', 'release-v0.1.1'), isTrue);
      expect(GitHubReleaseService.isUpdateAvailable('1.0.0', 'v2.0.0'), isTrue);
      expect(GitHubReleaseService.isUpdateAvailable('0.1.0+1', '0.1.0+2'), isTrue);
      expect(GitHubReleaseService.isUpdateAvailable('0.1.0+14', '0.1.0+16'), isTrue);
      expect(GitHubReleaseService.isUpdateAvailable('0.1.0+14', 'release-v16'), isTrue);
      expect(GitHubReleaseService.isUpdateAvailable('0.1.0+14', '16'), isTrue);

      // Same or older versions
      expect(GitHubReleaseService.isUpdateAvailable('0.2.0', '0.2.0'), isFalse);
      expect(GitHubReleaseService.isUpdateAvailable('1.5.0', '1.4.9'), isFalse);
      expect(GitHubReleaseService.isUpdateAvailable('2.0.0', 'release-v1.9.9'), isFalse);
      expect(GitHubReleaseService.isUpdateAvailable('0.1.0+16', '0.1.0+14'), isFalse);
      expect(GitHubReleaseService.isUpdateAvailable('0.1.0+16', 'release-v14'), isFalse);
      expect(GitHubReleaseService.isUpdateAvailable('0.1.0+16', '0.1.0+16'), isFalse);
    });

    test('cleanVersion strips prefixes and metadata', () {
      expect(GitHubReleaseService.cleanVersion('release-v1.2.3'), equals('1.2.3'));
      expect(GitHubReleaseService.cleanVersion('v2.0.1'), equals('2.0.1'));
      expect(GitHubReleaseService.cleanVersion('3.4.5'), equals('3.4.5'));
    });
  });
}
