import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app_database.dart';

/// Riverpod provider for the singleton AppDatabase instance.
final appDatabaseProvider = Provider<AppDatabase>((ref) {
  final database = AppDatabase.defaults();
  ref.onDispose(() => database.close());
  return database;
});
