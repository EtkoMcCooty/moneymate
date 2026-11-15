import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:package_info_plus/package_info_plus.dart';
import '../services/github_release_service.dart';
import 'update_state.dart';

/// Provider for the GitHub Releases API service.
final githubReleaseServiceProvider = Provider<GitHubReleaseService>((ref) {
  return GitHubReleaseService();
});

/// Notifier managing checking for and applying updates from GitHub Releases.
class UpdateNotifier extends StateNotifier<UpdateState> {
  final GitHubReleaseService _service;
  final Future<String> Function()? _versionProvider;

  UpdateNotifier({
    GitHubReleaseService? service,
    Future<String> Function()? versionProvider,
  })  : _service = service ?? GitHubReleaseService(),
        _versionProvider = versionProvider,
        super(const UpdateState());

  /// Performs a non-intrusive background update check once per app launch session.
  /// Returns `true` if a newer update is available and should prompt the user.
  Future<bool> checkForStartupUpdate({String? customCurrentVersion}) async {
    if (state.hasCheckedOnStartup) {
      return false;
    }

    state = state.copyWith(
      hasCheckedOnStartup: true,
      clearError: true,
    );

    final currentVersion =
        customCurrentVersion ?? await _getCurrentAppVersion();

    try {
      final latestRelease = await _service.fetchLatestRelease();

      if (latestRelease == null) {
        state = state.copyWith(
          status: UpdateStatus.upToDate,
          currentVersion: currentVersion,
          clearError: true,
        );
        return false;
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
          clearError: true,
        );
        return state.shouldShowStartupPrompt;
      } else {
        state = state.copyWith(
          status: UpdateStatus.upToDate,
          currentVersion: currentVersion,
          clearError: true,
        );
        return false;
      }
    } catch (_) {
      // Fail silently on startup so offline launches are never interrupted.
      state = state.copyWith(
        status: UpdateStatus.idle,
        currentVersion: currentVersion,
        clearError: true,
      );
      return false;
    }
  }

  /// Marks that the automatic startup update dialog has been presented this session.
  void markStartupPromptShown() {
    state = state.copyWith(hasPromptedOnStartup: true);
  }

  /// Records that the user dismissed the update prompt for [version] in this session.
  void dismissUpdate([String? version]) {
    final targetVersion = version ?? state.release?.version;
    state = state.copyWith(
      hasPromptedOnStartup: true,
      dismissedVersion: targetVersion,
    );
  }

  /// Checks for available updates on GitHub Releases (manual user trigger).
  Future<void> checkForUpdate({String? customCurrentVersion}) async {
    state = state.copyWith(status: UpdateStatus.checking, clearError: true);

    try {
      final currentVersion =
          customCurrentVersion ?? await _getCurrentAppVersion();
      final latestRelease = await _service.fetchLatestRelease();

      if (latestRelease == null) {
        state = state.copyWith(
          status: UpdateStatus.upToDate,
          currentVersion: currentVersion,
          clearError: true,
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
          clearError: true,
        );
      } else {
        state = state.copyWith(
          status: UpdateStatus.upToDate,
          currentVersion: currentVersion,
          clearError: true,
        );
      }
    } catch (e) {
      state = state.copyWith(
        status: UpdateStatus.error,
        errorMessage: e.toString().replaceFirst(RegExp(r'^Exception:\s*'), ''),
      );
    }
  }

  Future<String> _getCurrentAppVersion() async {
    final versionProvider = _versionProvider;
    if (versionProvider != null) {
      return await versionProvider();
    }
    try {
      final info = await PackageInfo.fromPlatform();
      final version = info.version.trim();
      if (version.isEmpty) {
        return '0.1.0+1';
      }
      final buildNumber = info.buildNumber.trim();
      return buildNumber.isNotEmpty ? '$version+$buildNumber' : version;
    } catch (_) {
      return '0.1.0+1';
    }
  }
}

/// Optional provider for overriding the current app version resolver in tests.
final appVersionProvider = Provider<Future<String> Function()?>((ref) {
  return null;
});

/// Provider for the update check workflow.
final updateNotifierProvider =
    StateNotifierProvider<UpdateNotifier, UpdateState>((ref) {
  final service = ref.watch(githubReleaseServiceProvider);
  final versionProvider = ref.watch(appVersionProvider);
  return UpdateNotifier(
    service: service,
    versionProvider: versionProvider,
  );
});
