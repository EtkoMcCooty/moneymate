import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/app_release.dart';

/// Service responsible for querying GitHub Releases API and comparing version numbers.
class GitHubReleaseService {
  final http.Client _client;
  final String owner;
  final String repo;

  GitHubReleaseService({
    http.Client? client,
    this.owner = 'EtkoMcCooty',
    this.repo = 'moneymate',
  }) : _client = client ?? http.Client();

  /// Fetches the latest published release from GitHub.
  Future<AppRelease?> fetchLatestRelease() async {
    final url = Uri.parse('https://api.github.com/repos/$owner/$repo/releases/latest');
    final response = await _client.get(
      url,
      headers: {
        'Accept': 'application/vnd.github.v3+json',
        'User-Agent': 'MoneyMate-App',
      },
    );

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body) as Map<String, dynamic>;
      return AppRelease.fromJson(json);
    } else if (response.statusCode == 404) {
      // No releases published yet
      return null;
    } else {
      throw Exception('Failed to check for updates: GitHub API returned status ${response.statusCode}');
    }
  }

  /// Cleans a version string by removing 'release-v', 'v', and build metadata for base semver comparison.
  static String cleanVersion(String raw) {
    return raw
        .replaceAll(RegExp(r'^(release-)?v?', caseSensitive: false), '')
        .split('+')
        .first
        .trim();
  }

  /// Determines if [remoteVersion] is strictly newer than [currentVersion].
  static bool isUpdateAvailable(String currentVersion, String remoteVersion) {
    final cleanCurrent = cleanVersion(currentVersion);
    final cleanRemote = cleanVersion(remoteVersion);

    final currentParts = cleanCurrent.split('.').map((p) => int.tryParse(p) ?? 0).toList();
    final remoteParts = cleanRemote.split('.').map((p) => int.tryParse(p) ?? 0).toList();

    while (currentParts.length < 3) {
      currentParts.add(0);
    }
    while (remoteParts.length < 3) {
      remoteParts.add(0);
    }

    for (var i = 0; i < 3; i++) {
      if (remoteParts[i] > currentParts[i]) return true;
      if (remoteParts[i] < currentParts[i]) return false;
    }

    // If semver is identical, check build number if present
    final currentBuild = _extractBuildNumber(currentVersion);
    final remoteBuild = _extractBuildNumber(remoteVersion);

    if (remoteBuild != null && currentBuild != null) {
      return remoteBuild > currentBuild;
    }

    return false;
  }

  static int? _extractBuildNumber(String version) {
    if (!version.contains('+')) return null;
    final buildPart = version.split('+').last;
    return int.tryParse(buildPart);
  }
}
