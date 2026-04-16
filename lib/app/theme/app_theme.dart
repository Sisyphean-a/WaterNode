import 'package:flutter/material.dart';

abstract final class AppTheme {
  static const fontFamily = 'NotoSansSC';

  static ThemeData build() {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: const Color(0xFF4F46E5), // Indigo 600, a modern premium color
      surface: Colors.white,
      surfaceContainerLowest: Colors.white,
    );

    final base = ThemeData(
      useMaterial3: true,
      visualDensity: VisualDensity.standard, // Better touch targets instead of compact
      colorScheme: colorScheme,
      scaffoldBackgroundColor: const Color(0xFFF8FAFC), // Very light cool gray
      dividerTheme: DividerThemeData(
        color: colorScheme.outlineVariant.withValues(alpha: 0.5),
        space: 1,
      ),
      cardTheme: CardThemeData(
        color: Colors.white,
        elevation: 0, // We will use custom shadow or very soft material shadow
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
          side: BorderSide(
            color: colorScheme.outlineVariant.withValues(alpha: 0.3),
          ),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        isDense: true,
        filled: true,
        fillColor: colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: colorScheme.primary, width: 2),
        ),
      ),
    );
    final textTheme = _buildTextTheme(base.textTheme);

    return base.copyWith(
      textTheme: textTheme,
      primaryTextTheme: textTheme,
    );
  }

  static TextTheme _buildTextTheme(TextTheme base) {
    return base.copyWith(
      displayLarge: _style(base.displayLarge, FontWeight.w700),
      displayMedium: _style(base.displayMedium, FontWeight.w700),
      displaySmall: _style(base.displaySmall, FontWeight.w700),
      headlineLarge: _style(base.headlineLarge, FontWeight.w700),
      headlineMedium: _style(base.headlineMedium, FontWeight.w700),
      headlineSmall: _style(base.headlineSmall, FontWeight.w700),
      titleLarge: _style(base.titleLarge, FontWeight.w700),
      titleMedium: _style(base.titleMedium, FontWeight.w700),
      titleSmall: _style(base.titleSmall, FontWeight.w600),
      labelLarge: _style(base.labelLarge, FontWeight.w500),
      labelMedium: _style(base.labelMedium, FontWeight.w500),
      labelSmall: _style(base.labelSmall, FontWeight.w500),
      bodyLarge: _style(base.bodyLarge, FontWeight.w400),
      bodyMedium: _style(base.bodyMedium, FontWeight.w400),
      bodySmall: _style(base.bodySmall, FontWeight.w400),
    );
  }

  static TextStyle? _style(TextStyle? style, FontWeight fontWeight) {
    return style?.copyWith(
      fontFamily: fontFamily,
      fontWeight: fontWeight,
      height: 1.35,
      leadingDistribution: TextLeadingDistribution.even,
    );
  }
}
