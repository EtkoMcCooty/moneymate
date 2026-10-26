import 'package:flutter/foundation.dart' hide Category;
import '../../../core/database/app_database.dart';

@immutable
class SettingsState {
  final Tracker? tracker;
  final List<Category> categories;
  final bool isLoading;
  final String? errorMessage;

  const SettingsState({
    this.tracker,
    this.categories = const [],
    this.isLoading = false,
    this.errorMessage,
  });

  SettingsState copyWith({
    Tracker? tracker,
    List<Category>? categories,
    bool? isLoading,
    String? errorMessage,
  }) {
    return SettingsState(
      tracker: tracker ?? this.tracker,
      categories: categories ?? this.categories,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
    );
  }

  int get cycleStartDay => tracker?.cycleStartDay ?? 15;
  String get currencySymbol => tracker?.currencySymbol ?? '£';
}
