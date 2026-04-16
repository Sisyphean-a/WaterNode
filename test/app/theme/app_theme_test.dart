import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:waternode/app/app.dart';
import 'package:waternode/app/dependencies/app_dependencies.dart';

void main() {
  testWidgets('boots with bundled font family and unified text weights', (
    tester,
  ) async {
    await tester.pumpWidget(
      WaterNodeApp(dependencies: AppDependencies.inMemory()),
    );

    await tester.pumpAndSettle();

    final element = tester.element(find.text('首页工作台').first);
    final theme = Theme.of(element);

    expect(theme.textTheme.bodyMedium?.fontFamily, 'NotoSansSC');
    expect(theme.textTheme.bodyMedium?.fontWeight, FontWeight.w400);
    expect(theme.textTheme.labelMedium?.fontWeight, FontWeight.w500);
    expect(theme.textTheme.titleSmall?.fontWeight, FontWeight.w600);
    expect(theme.textTheme.titleMedium?.fontWeight, FontWeight.w700);
    expect(theme.textTheme.titleLarge?.fontWeight, FontWeight.w700);
  });
}
