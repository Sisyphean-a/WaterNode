import 'package:flutter/material.dart';

abstract final class AppTheme {
  static const fontFamily = 'NotoSansSC';

  static ThemeData build() {
    final base = ThemeData(
      useMaterial3: true,
      visualDensity: VisualDensity.compact,
      colorScheme: ColorScheme.fromSeed(
        seedColor: const Color(0xFF166534),
        surface: const Color(0xFFF5F7F7),
      ),
      scaffoldBackgroundColor: const Color(0xFFF0F3F4),
      inputDecorationTheme: const InputDecorationTheme(
        isDense: true,
        border: OutlineInputBorder(),
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
