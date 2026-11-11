import 'package:material_ui/material_ui.dart';

/// App-wide artisanal theme configuration for MoneyMate.
/// Implements a 5-layer surface depth model, typographic tension, and high-contrast palette.
class AppTheme {
  AppTheme._();

  // Brand Colors - Executive Pine & Emerald Palette
  static const Color primaryColor = Color(0xFF0D9488); // Teal 600
  static const Color primaryVariant = Color(0xFF0F766E); // Teal 700
  static const Color secondaryColor = Color(0xFF0284C7); // Sky 600
  static const Color accentColor = Color(0xFF10B981); // Emerald 500

  // Neutral Light Colors (Soft warm off-white surface model)
  static const Color backgroundColor = Color(0xFFF8FAFC); // Slate 50
  static const Color surfaceColor = Color(0xFFFFFFFF);
  static const Color surfaceContainerLowest = Color(0xFFFFFFFF);
  static const Color surfaceContainerLow = Color(0xFFF8FAFC);
  static const Color surfaceContainer = Color(0xFFF1F5F9);
  static const Color surfaceContainerHigh = Color(0xFFE2E8F0);
  static const Color surfaceContainerHighest = Color(0xFFCBD5E1);

  static const Color textPrimaryColor = Color(0xFF0F172A); // Slate 900
  static const Color textSecondaryColor = Color(0xFF64748B); // Slate 500
  static const Color dividerColor = Color(0xFFE2E8F0); // Slate 200

  // Neutral Dark Colors (Obsidian charcoal surface model)
  static const Color darkBackgroundColor = Color(0xFF0B0F15); // Obsidian 950
  static const Color darkSurfaceColor = Color(0xFF131922); // Obsidian 900
  static const Color darkSurfaceRaised = Color(0xFF1B2430); // Obsidian 800
  static const Color darkSurfaceContainerLowest = Color(0xFF070A0E);
  static const Color darkSurfaceContainerLow = Color(0xFF0E131A);
  static const Color darkSurfaceContainer = Color(0xFF141C24);
  static const Color darkSurfaceContainerHigh = Color(0xFF1D2633);
  static const Color darkSurfaceContainerHighest = Color(0xFF283547);

  static const Color darkTextPrimaryColor = Color(0xFFF8FAFC); // Slate 50
  static const Color darkTextSecondaryColor = Color(0xFF94A3B8); // Slate 400
  static const Color darkDividerColor = Color(0xFF1E293B);

  // Semantic Status Colors
  static const Color incomeColor = Color(0xFF16A34A); // Green 600
  static const Color expenseColor = Color(0xFFDC2626); // Red 600
  static const Color debtColor = Color(0xFFEA580C); // Orange 600
  static const Color savingsColor = Color(0xFF2563EB); // Blue 600

  /// Light Theme Configuration
  static ThemeData get lightTheme {
    final colorScheme = ColorScheme.light(
      primary: primaryColor,
      onPrimary: Colors.white,
      primaryContainer: accentColor.withValues(alpha: 0.12),
      onPrimaryContainer: primaryVariant,
      secondary: secondaryColor,
      onSecondary: Colors.white,
      surface: surfaceColor,
      onSurface: textPrimaryColor,
      onSurfaceVariant: textSecondaryColor,
      surfaceContainerLowest: surfaceContainerLowest,
      surfaceContainerLow: surfaceContainerLow,
      surfaceContainer: surfaceContainer,
      surfaceContainerHigh: surfaceContainerHigh,
      surfaceContainerHighest: surfaceContainerHighest,
      error: expenseColor,
      onError: Colors.white,
      outline: dividerColor,
      outlineVariant: dividerColor.withValues(alpha: 0.6),
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: backgroundColor,
      cardTheme: CardThemeData(
        color: surfaceColor,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: dividerColor, width: 1),
        ),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: backgroundColor,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          color: textPrimaryColor,
          fontSize: 22,
          fontWeight: FontWeight.w800,
          letterSpacing: -0.5,
        ),
        iconTheme: IconThemeData(color: textPrimaryColor),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: surfaceColor,
        elevation: 8,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
          side: const BorderSide(color: dividerColor, width: 1),
        ),
        titleTextStyle: const TextStyle(
          color: textPrimaryColor,
          fontSize: 20,
          fontWeight: FontWeight.w800,
          letterSpacing: -0.4,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surfaceContainerLow,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: dividerColor),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: dividerColor),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: primaryColor, width: 2),
        ),
        labelStyle: const TextStyle(
          color: textSecondaryColor,
          fontWeight: FontWeight.w500,
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          textStyle: const TextStyle(fontWeight: FontWeight.w700, letterSpacing: -0.2),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          side: const BorderSide(color: dividerColor),
          textStyle: const TextStyle(fontWeight: FontWeight.w700, letterSpacing: -0.2),
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: surfaceColor,
        elevation: 0,
        height: 68,
        indicatorColor: primaryColor.withValues(alpha: 0.12),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.2,
              color: primaryColor,
            );
          }
          return const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: textSecondaryColor,
          );
        }),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const IconThemeData(color: primaryColor, size: 24);
          }
          return const IconThemeData(color: textSecondaryColor, size: 24);
        }),
      ),
    );
  }

  /// Dark Theme Configuration
  static ThemeData get darkTheme {
    final colorScheme = ColorScheme.dark(
      primary: primaryColor,
      onPrimary: Colors.white,
      primaryContainer: primaryColor.withValues(alpha: 0.22),
      onPrimaryContainer: const Color(0xFF6EE7B7),
      secondary: secondaryColor,
      onSecondary: Colors.white,
      surface: darkSurfaceColor,
      onSurface: darkTextPrimaryColor,
      onSurfaceVariant: darkTextSecondaryColor,
      surfaceContainerLowest: darkSurfaceContainerLowest,
      surfaceContainerLow: darkSurfaceContainerLow,
      surfaceContainer: darkSurfaceContainer,
      surfaceContainerHigh: darkSurfaceContainerHigh,
      surfaceContainerHighest: darkSurfaceContainerHighest,
      error: expenseColor,
      onError: Colors.white,
      outline: darkDividerColor,
      outlineVariant: darkDividerColor.withValues(alpha: 0.6),
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: darkBackgroundColor,
      cardTheme: CardThemeData(
        color: darkSurfaceColor,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(
            color: Colors.white.withValues(alpha: 0.08),
            width: 1,
          ),
        ),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: darkBackgroundColor,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          color: darkTextPrimaryColor,
          fontSize: 22,
          fontWeight: FontWeight.w800,
          letterSpacing: -0.5,
        ),
        iconTheme: IconThemeData(color: darkTextPrimaryColor),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: darkSurfaceColor,
        elevation: 8,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
          side: BorderSide(color: Colors.white.withValues(alpha: 0.1), width: 1),
        ),
        titleTextStyle: const TextStyle(
          color: darkTextPrimaryColor,
          fontSize: 20,
          fontWeight: FontWeight.w800,
          letterSpacing: -0.4,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: darkSurfaceContainerLow,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.1)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.1)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: primaryColor, width: 2),
        ),
        labelStyle: const TextStyle(
          color: darkTextSecondaryColor,
          fontWeight: FontWeight.w500,
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          textStyle: const TextStyle(fontWeight: FontWeight.w700, letterSpacing: -0.2),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          side: BorderSide(color: Colors.white.withValues(alpha: 0.12)),
          textStyle: const TextStyle(fontWeight: FontWeight.w700, letterSpacing: -0.2),
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: darkSurfaceColor,
        elevation: 0,
        height: 68,
        indicatorColor: primaryColor.withValues(alpha: 0.22),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.2,
              color: primaryColor,
            );
          }
          return const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: darkTextSecondaryColor,
          );
        }),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const IconThemeData(color: primaryColor, size: 24);
          }
          return const IconThemeData(color: darkTextSecondaryColor, size: 24);
        }),
      ),
    );
  }
}
