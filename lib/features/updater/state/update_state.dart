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

  const UpdateState({
    this.status = UpdateStatus.idle,
    this.release,
    this.currentVersion,
    this.errorMessage,
  });

  UpdateState copyWith({
    UpdateStatus? status,
    AppRelease? release,
    String? currentVersion,
    String? errorMessage,
  }) {
    return UpdateState(
      status: status ?? this.status,
      release: release ?? this.release,
      currentVersion: currentVersion ?? this.currentVersion,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}
