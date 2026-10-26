import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:package_info_plus/package_info_plus.dart';
import '../services/github_release_service.dart';
import 'update_state.dart';

/// Notifier managing checking for and applying updates from GitHub Releases.
class UpdateNotifier extends StateNotifier<UpdateState> {
  final GitHubReleaseService _service;

  UpdateNotifier({GitHubReleaseService? service})
      : _service = service ?? GitHubReleaseService(),
        super(const UpdateState());

  /// Checks for available updates on GitHub Releases.
  Future<void> checkForUpdate({String? customCurrentVersion}) async {
    state = state.copyWith(status: UpdateStatus.checking, errorMessage: null);

    try {
      final currentVersion = customCurrentVersion ?? await _getCurrentAppVersion();
      final latestRelease = await _service.fetchLatestRelease();

      if (latestRelease == null) {
        state = state.copyWith(
          status: UpdateStatus.upToDate,
          currentVersion: currentVersion,
        );
        return;
      }

      final isAvailable = GitHubReleaseService.isUpdateAvailable(
        currentVersion,
        latestRelease.version,
      );

      if (isAvailable) {
        state = state.copyWith(
          status: UpdateStatus.available,
          release: latestRelease,
          currentVersion: currentVersion,
        );
      } else {
        state = state.copyWith(
          status: UpdateStatus.upToDate,
          currentVersion: currentVersion,
        );
      }
    } catch (e) {
      state = state.copyWith(
        status: UpdateStatus.error,
        errorMessage: e.toString(),
      );
    }
  }

  Future<String> _getCurrentAppVersion() async {
    try {
      final info = await PackageInfo.fromPlatform();
      return '${info.version}+${info.buildNumber}';
    } catch (_) {
      return '0.1.0+1';
    }
  }
}

/// Provider for the update check workflow.
final updateNotifierProvider = StateNotifierProvider<UpdateNotifier, UpdateState>((ref) {
  return UpdateNotifier();
});
