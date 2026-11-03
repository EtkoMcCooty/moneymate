/// Model representing a GitHub release payload for MoneyMate updates.
class AppRelease {
  final String tagName;
  final String version;
  final String title;
  final String notes;
  final String rawNotes;
  final String? apkUrl;
  final DateTime publishedAt;

  const AppRelease({
    required this.tagName,
    required this.version,
    required this.title,
    required this.notes,
    this.rawNotes = '',
    this.apkUrl,
    required this.publishedAt,
  });

  factory AppRelease.fromJson(Map<String, dynamic> json) {
    final tagName = json['tag_name'] as String? ?? '';
    final name = json['name'] as String? ?? tagName;
    final body = json['body'] as String? ?? '';
    final publishedStr = json['published_at'] as String?;
    final publishedAt = publishedStr != null
        ? DateTime.tryParse(publishedStr) ?? DateTime.now()
        : DateTime.now();

    // Extract clean version (e.g. 'release-v0.2.0' -> '0.2.0')
    final version = _cleanVersionString(tagName);

    // Find the release APK asset in the assets list
    String? apkUrl;
    final assets = json['assets'] as List<dynamic>? ?? [];
    for (final asset in assets) {
      if (asset is Map<String, dynamic>) {
        final assetName = (asset['name'] as String? ?? '').toLowerCase();
        if (assetName.endsWith('.apk')) {
          apkUrl = asset['browser_download_url'] as String?;
          break;
        }
      }
    }

    // Fall back to html_url if direct APK asset is not attached
    apkUrl ??= json['html_url'] as String?;

    return AppRelease(
      tagName: tagName,
      version: version,
      title: name,
      notes: cleanReleaseNotes(body),
      rawNotes: body,
      apkUrl: apkUrl,
      publishedAt: publishedAt,
    );
  }

  /// Sanitizes release notes by removing automated boilerplate, download links,
  /// and technical changelog links, leaving clean bullet points for the user.
  static String cleanReleaseNotes(String raw) {
    if (raw.trim().isEmpty) {
      return '• General performance improvements and bug fixes.';
    }

    final lines = raw.split('\n');
    final cleanedLines = <String>[];

    for (final line in lines) {
      final trimmed = line.trim();
      if (trimmed.isEmpty) continue;

      // Filter out generic automated build lines and download headers
      if (trimmed.startsWith('Automated MoneyMate build') ||
          trimmed.startsWith('### 📱 Download') ||
          trimmed.startsWith('Direct APK download') ||
          trimmed.startsWith('**Full Changelog**') ||
          trimmed.startsWith('* Full Changelog') ||
          trimmed.startsWith('Full Changelog:') ||
          trimmed.startsWith('See full changelog')) {
        continue;
      }

      // Format bullet points cleanly
      if (trimmed.startsWith('* ') || trimmed.startsWith('- ')) {
        cleanedLines.add('• ${trimmed.substring(2).trim()}');
      } else if (trimmed.startsWith('### ') || trimmed.startsWith('## ')) {
        final headerText = trimmed.replaceFirst(RegExp(r'^#+\s*'), '').trim();
        if (!headerText.toLowerCase().contains('download')) {
          cleanedLines.add(headerText);
        }
      } else {
        cleanedLines.add(trimmed);
      }
    }

    if (cleanedLines.isEmpty) {
      return '• General performance improvements and bug fixes.';
    }

    return cleanedLines.join('\n');
  }

  static String _cleanVersionString(String raw) {
    return raw
        .replaceAll(RegExp(r'^(release-)?v?', caseSensitive: false), '')
        .trim();
  }
}
