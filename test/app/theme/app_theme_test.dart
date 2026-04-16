import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:waternode/app/theme/app_theme.dart';

void main() {
  test('builds with system font fallback and unified text weights', () {
    final theme = AppTheme.build();

    expect(theme.textTheme.bodyMedium?.fontFamily, 'sans-serif');
    expect(theme.textTheme.bodyMedium?.fontFamilyFallback, [
      'Microsoft YaHei UI',
      'Microsoft YaHei',
      'Noto Sans CJK SC',
      'Noto Sans SC',
      'Segoe UI',
      'sans-serif',
    ]);
    expect(theme.textTheme.bodyMedium?.fontWeight, FontWeight.w400);
    expect(theme.textTheme.labelMedium?.fontWeight, FontWeight.w500);
    expect(theme.textTheme.titleSmall?.fontWeight, FontWeight.w600);
    expect(theme.textTheme.titleMedium?.fontWeight, FontWeight.w700);
    expect(theme.textTheme.titleLarge?.fontWeight, FontWeight.w700);
  });
}
