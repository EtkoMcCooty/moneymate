import 'package:flutter/material.dart';
import 'app_theme.dart';

/// Artisanal surface, lighting, and typographic design tokens for MoneyMate.
class CraftDecorations {
  CraftDecorations._();

  /// Surface background color corresponding to theme mode.
  static Color surfaceColor(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return isDark ? AppTheme.darkSurfaceColor : AppTheme.surfaceColor;
  }

  /// Surface border side with physical rim highlight.
  static BorderSide borderSide(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return BorderSide(
      color: isDark
          ? Colors.white.withValues(alpha: 0.08)
          : Colors.black.withValues(alpha: 0.06),
      width: 1,
    );
  }

  /// Surface card shape with rounded corners and rim border.
  static ShapeBorder cardShape(
    BuildContext context, {
    BorderRadius? borderRadius,
    BorderSide? side,
  }) {
    return RoundedRectangleBorder(
      borderRadius: borderRadius ?? BorderRadius.circular(20),
      side: side ?? borderSide(context),
    );
  }

  /// Soft ambient drop shadow decoration for wrapping Material cards.
  static BoxDecoration cardShadowDecoration(
    BuildContext context, {
    BorderRadius? borderRadius,
    bool elevated = true,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final radius = borderRadius ?? BorderRadius.circular(20);

    return BoxDecoration(
      borderRadius: radius,
      boxShadow: elevated
          ? [
              BoxShadow(
                color: isDark
                    ? Colors.black.withValues(alpha: 0.45)
                    : Colors.black.withValues(alpha: 0.04),
                blurRadius: 16,
                offset: const Offset(0, 4),
              ),
              BoxShadow(
                color: isDark
                    ? Colors.white.withValues(alpha: 0.02)
                    : Colors.black.withValues(alpha: 0.02),
                blurRadius: 4,
                offset: const Offset(0, 1),
              ),
            ]
          : null,
    );
  }

  /// High-impact hero cockpit card decoration with ambient gradient illumination
  /// and glowing rim border.
  static BoxDecoration heroCardDecoration(
    BuildContext context, {
    required Color accentColor,
    BorderRadius? borderRadius,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final radius = borderRadius ?? BorderRadius.circular(24);

    return BoxDecoration(
      borderRadius: radius,
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: isDark
            ? [
                accentColor.withValues(alpha: 0.16),
                AppTheme.darkSurfaceColor,
                AppTheme.darkSurfaceRaised,
              ]
            : [
                accentColor.withValues(alpha: 0.10),
                Colors.white,
                Colors.white,
              ],
        stops: const [0.0, 0.55, 1.0],
      ),
      border: Border.all(
        color: accentColor.withValues(alpha: isDark ? 0.35 : 0.28),
        width: 1.5,
      ),
      boxShadow: [
        BoxShadow(
          color: accentColor.withValues(alpha: isDark ? 0.12 : 0.06),
          blurRadius: 24,
          offset: const Offset(0, 8),
        ),
        BoxShadow(
          color: isDark
              ? Colors.black.withValues(alpha: 0.5)
              : Colors.black.withValues(alpha: 0.04),
          blurRadius: 12,
          offset: const Offset(0, 2),
        ),
      ],
    );
  }

  /// Compact status capsule decoration for tags, timeframes, and chips.
  static BoxDecoration pillDecoration(
    BuildContext context, {
    Color? backgroundColor,
    Color? borderColor,
    BorderRadius? borderRadius,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final radius = borderRadius ?? BorderRadius.circular(100);

    return BoxDecoration(
      color: backgroundColor ??
          (isDark
              ? Colors.white.withValues(alpha: 0.08)
              : Colors.black.withValues(alpha: 0.05)),
      borderRadius: radius,
      border: Border.all(
        color: borderColor ??
            (isDark
                ? Colors.white.withValues(alpha: 0.12)
                : Colors.black.withValues(alpha: 0.08)),
        width: 1,
      ),
    );
  }

  /// Typographic style for uppercase tracked micro-labels.
  static TextStyle microLabelStyle(
    BuildContext context, {
    Color? color,
    double fontSize = 11,
    FontWeight fontWeight = FontWeight.w700,
  }) {
    final theme = Theme.of(context);
    return TextStyle(
      fontSize: fontSize,
      fontWeight: fontWeight,
      letterSpacing: 1.1,
      color: color ?? theme.colorScheme.onSurfaceVariant,
    );
  }

  /// TextStyle configured with OpenType tabular figures for currency and stats.
  static TextStyle tabularStyle({
    required TextStyle baseStyle,
    FontWeight? fontWeight,
    double? letterSpacing,
  }) {
    return baseStyle.copyWith(
      fontWeight: fontWeight ?? baseStyle.fontWeight,
      letterSpacing: letterSpacing ?? -0.3,
      fontFeatures: const [
        FontFeature.tabularFigures(),
      ],
    );
  }
}
