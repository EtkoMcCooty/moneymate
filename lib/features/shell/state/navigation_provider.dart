import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Provider holding the currently selected bottom navigation index.
final navigationIndexProvider = StateProvider<int>((ref) => 0);
