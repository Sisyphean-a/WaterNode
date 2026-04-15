import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:waternode/app/app.dart';
import 'package:waternode/app/dependencies/app_dependencies.dart';

void main() {
  testWidgets('renders home water action without overflow on narrow screens', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      WaterNodeApp(dependencies: AppDependencies.inMemory()),
    );
    await tester.pumpAndSettle();

    expect(find.text('取水操作'), findsOneWidget);
    expect(find.widgetWithText(FilledButton, '立即取水'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('renders device filters without overflow on narrow screens', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      WaterNodeApp(dependencies: AppDependencies.inMemory()),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byTooltip('展开导航'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('终端大厅'));
    await tester.pumpAndSettle();

    expect(find.text('终端管理大厅'), findsOneWidget);
    expect(find.text('大区'), findsOneWidget);
    expect(find.text('区域'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('keeps sidebar expanded after wide-layout route changes', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1440, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      WaterNodeApp(dependencies: AppDependencies.inMemory()),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byTooltip('展开导航'));
    await tester.pumpAndSettle();

    expect(find.text('设备中心'), findsOneWidget);
    expect(find.byTooltip('收起导航'), findsOneWidget);

    await tester.tap(find.text('终端大厅'));
    await tester.pumpAndSettle();

    expect(find.text('终端管理大厅'), findsOneWidget);
    expect(find.text('设备中心'), findsWidgets);
    expect(find.byTooltip('收起导航'), findsOneWidget);
  });
}
