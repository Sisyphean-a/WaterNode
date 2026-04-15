import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:waternode/app/app.dart';
import 'package:waternode/app/dependencies/app_dependencies.dart';

void main() {
  testWidgets('renders water workbench without overflow on narrow screens', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      WaterNodeApp(dependencies: AppDependencies.inMemory()),
    );
    await tester.pumpAndSettle();

    expect(find.text('选择账号'), findsOneWidget);
    expect(find.text('选择区域'), findsOneWidget);
    expect(find.widgetWithText(FilledButton, '立即取水 7.5L'), findsOneWidget);
    expect(find.widgetWithText(FilledButton, '立即取水 15L'), findsOneWidget);
    expect(find.text('批量操作'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('closes drawer after selecting a route on narrow screens', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      WaterNodeApp(dependencies: AppDependencies.inMemory()),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('open-drawer')));
    await tester.pumpAndSettle();
    expect(find.byType(Drawer), findsOneWidget);

    await tester.tap(find.text('结果日志'));
    await tester.pumpAndSettle();

    expect(find.byType(Drawer), findsNothing);
    expect(find.text('结果追踪'), findsWidgets);
  });

  testWidgets('auto-collapses wide sidebar after selecting a route', (
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

    expect(find.text('工作台'), findsWidgets);
    expect(find.byTooltip('收起导航'), findsOneWidget);

    await tester.tap(find.text('结果日志'));
    await tester.pumpAndSettle();

    expect(find.text('结果追踪'), findsWidgets);
    expect(find.byTooltip('展开导航'), findsOneWidget);
  });
}
