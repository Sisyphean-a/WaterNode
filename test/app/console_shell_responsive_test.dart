import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:waternode/app/app.dart';
import 'package:waternode/app/dependencies/app_dependencies.dart';

void main() {
  testWidgets('renders water workbench without overflow on narrow screens', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(320, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      WaterNodeApp(dependencies: AppDependencies.inMemory()),
    );
    await tester.pumpAndSettle();

    expect(find.text('指派账户'), findsOneWidget);
    expect(find.text('设备列表'), findsNothing);
    expect(find.text('设备终端'), findsOneWidget);
    expect(find.byKey(const Key('workbench-source-select')), findsNothing);
    expect(find.textContaining('目标：'), findsNothing);
    expect(find.text('7.5L'), findsOneWidget);
    expect(find.text('15L'), findsOneWidget);
    expect(find.text('取水 7.5L'), findsNothing);
    expect(find.text('取水 15L'), findsNothing);
    expect(find.byIcon(Icons.water_drop_outlined), findsOneWidget);
    expect(find.byIcon(Icons.water_drop_rounded), findsOneWidget);
    final accountFieldWidth = tester
        .getSize(find.byKey(const Key('workbench-account-select')))
        .width;
    final stationFieldWidth = tester
        .getSize(find.byKey(const Key('workbench-station-select')))
        .width;
    expect((accountFieldWidth - stationFieldWidth).abs(), lessThan(2));
    expect(accountFieldWidth, greaterThan(220));
    final smallButtonWidth = tester
        .getSize(find.byKey(const Key('water-action-7.5')))
        .width;
    final largeButtonWidth = tester
        .getSize(find.byKey(const Key('water-action-15')))
        .width;
    expect((smallButtonWidth - largeButtonWidth).abs(), lessThan(2));
    final accountTop = tester.getTopLeft(find.text('有效账号数')).dy;
    final pointsTop = tester.getTopLeft(find.text('总可用积分')).dy;
    expect((accountTop - pointsTop).abs(), lessThan(8));
    expect(find.text('一键自动化'), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('switches route from bottom navigation on narrow screens', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      WaterNodeApp(dependencies: AppDependencies.inMemory()),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.receipt_long_rounded).first);
    await tester.pumpAndSettle();

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

    await tester.tap(find.byTooltip('Nav'));
    await tester.pumpAndSettle();

    expect(find.text('工作台'), findsWidgets);
    expect(find.text('首页工作台'), findsWidgets);

    await tester.tap(find.text('结果日志'));
    await tester.pumpAndSettle();

    expect(find.text('结果追踪'), findsWidgets);
    expect(find.text('工作台'), findsNothing);
  });
}
