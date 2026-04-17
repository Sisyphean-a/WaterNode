import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:waternode/app/app.dart';
import 'package:waternode/app/dependencies/app_dependencies.dart';
import 'package:waternode/app/routes/app_routes.dart';

void main() {
  testWidgets('keeps single route while switching workbench modules', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      WaterNodeApp(dependencies: AppDependencies.inMemory()),
    );
    await tester.pumpAndSettle();

    expect(Get.currentRoute, AppRoutes.dashboard);

    await tester.tap(find.byIcon(Icons.receipt_long_rounded).first);
    await tester.pumpAndSettle();

    expect(Get.currentRoute, AppRoutes.dashboard);
    expect(find.text('结果追踪'), findsWidgets);
    expect(find.text('🪙 账单核对'), findsOneWidget);
    expect(find.text('💧 取水历史'), findsOneWidget);
    expect(find.text('🤖 系统日志'), findsOneWidget);
  });

  testWidgets('shows water workbench and batch actions on home page', (
    tester,
  ) async {
    await tester.pumpWidget(
      WaterNodeApp(dependencies: AppDependencies.inMemory()),
    );
    await tester.pumpAndSettle();

    expect(find.text('有效账号数'), findsOneWidget);
    expect(find.text('总可用积分'), findsOneWidget);
    expect(find.text('取水控制台'), findsOneWidget);
    expect(find.text('当 前 账 号'), findsOneWidget);
    expect(find.text('设备列表'), findsNothing);
    expect(find.text('目标水站终端'), findsOneWidget);
    expect(find.byKey(const Key('workbench-source-select')), findsNothing);
    expect(find.textContaining('目标：'), findsNothing);
    expect(find.text('7.5L'), findsOneWidget);
    expect(find.text('15L'), findsOneWidget);
    expect(find.text('取水 7.5L'), findsNothing);
    expect(find.text('取水 15L'), findsNothing);
    expect(find.text('一键自动化'), findsNothing);
    expect(find.text('签到'), findsNothing);
    expect(find.text('抽奖'), findsNothing);

    expect(find.text('快捷操作'), findsNothing);
    expect(find.text('最新日志'), findsNothing);
    expect(find.text('在线账号'), findsNothing);
  });

  testWidgets('shows account management with automation and add dialog', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      WaterNodeApp(dependencies: AppDependencies.inMemory()),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.badge_rounded).first);
    await tester.pumpAndSettle();

    expect(find.text('账号管理'), findsWidgets);
    expect(find.byTooltip('刷新数据'), findsOneWidget);
    expect(find.byTooltip('批量签到'), findsOneWidget);
    expect(find.byTooltip('批量抽奖'), findsOneWidget);
    expect(find.text('添加'), findsOneWidget);
    expect(find.text('自动化'), findsNothing);
    expect(find.text('您的通行证'), findsOneWidget);
    expect(find.text('登录授权'), findsNothing);
  });

  testWidgets('shows tooltips for collapsed sidebar items on wide layout', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1440, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      WaterNodeApp(dependencies: AppDependencies.inMemory()),
    );
    await tester.pumpAndSettle();

    expect(find.byTooltip('首页工作台'), findsOneWidget);
    expect(find.byTooltip('结果日志'), findsOneWidget);
    expect(find.byTooltip('账号管理'), findsOneWidget);
    expect(find.byTooltip('登录授权'), findsNothing);
    expect(find.byTooltip('终端大厅'), findsNothing);
    expect(find.byTooltip('批量任务'), findsNothing);
  });
}
