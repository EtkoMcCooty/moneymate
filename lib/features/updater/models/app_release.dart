/// Model representing a GitHub release payload for MoneyMate updates.
class AppRelease {
  final String tagName;
  final String version;
  final String title;
  final String notes;
  final String? apkUrl;
  final DateTime publishedAt;

  const AppRelease({
    required this.tagName,
    required this.version,
    required this.title,
    required this.notes,
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
      notes: body,
      apkUrl: apkUrl,
      publishedAt: publishedAt,
    );
  }

  static String _cleanVersionString(String raw) {
    return raw
        .replaceAll(RegExp(r'^(release-)?v?', caseSensitive: false), '')
        .trim();
  }
}
