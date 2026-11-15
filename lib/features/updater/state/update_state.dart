import '../models/app_release.dart';

enum UpdateStatus {
  idle,
  checking,
  available,
  upToDate,
  error,
}

class UpdateState {
  final UpdateStatus status;
  final AppRelease? release;
  final String? currentVersion;
  final String? errorMessage;
  final bool hasCheckedOnStartup;
  final bool hasPromptedOnStartup;
  final String? dismissedVersion;

  const UpdateState({
    this.status = UpdateStatus.idle,
    this.release,
    this.currentVersion,
    this.errorMessage,
    this.hasCheckedOnStartup = false,
    this.hasPromptedOnStartup = false,
    this.dismissedVersion,
  });

  /// Whether the automatic startup prompt should be presented to the user.
  bool get shouldShowStartupPrompt =>
      status == UpdateStatus.available &&
      release != null &&
      !hasPromptedOnStartup &&
      dismissedVersion != release!.version;

  UpdateState copyWith({
    UpdateStatus? status,
    AppRelease? release,
    String? currentVersion,
    String? errorMessage,
    bool clearError = false,
    bool? hasCheckedOnStartup,
    bool? hasPromptedOnStartup,
    String? dismissedVersion,
  }) {
    return UpdateState(
      status: status ?? this.status,
      release: release ?? this.release,
      currentVersion: currentVersion ?? this.currentVersion,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      hasCheckedOnStartup: hasCheckedOnStartup ?? this.hasCheckedOnStartup,
      hasPromptedOnStartup: hasPromptedOnStartup ?? this.hasPromptedOnStartup,
      dismissedVersion: dismissedVersion ?? this.dismissedVersion,
    );
  }
}
