import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:waternode/app/app.dart';
import 'package:waternode/app/application/console_shell_controller.dart';
import 'package:waternode/app/dependencies/app_dependencies.dart';
import 'package:waternode/app/routes/app_routes.dart';

void main() {
  testWidgets('keeps single route while switching workbench modules', (
    tester,
  ) async {
    await tester.pumpWidget(
      WaterNodeApp(dependencies: AppDependencies.inMemory()),
    );
    await tester.pumpAndSettle();

    expect(Get.currentRoute, AppRoutes.dashboard);

    await tester.tap(find.byKey(const Key('open-drawer')));
    await tester.pumpAndSettle();

    await tester.tap(find.text('结果日志'));
    await tester.pumpAndSettle();

    expect(Get.currentRoute, AppRoutes.dashboard);
    expect(find.text('结果追踪'), findsWidgets);
    expect(find.text('最近操作记录'), findsOneWidget);
  });

  testWidgets('shows water workbench and batch actions on home page', (
    tester,
  ) async {
    await tester.pumpWidget(
      WaterNodeApp(dependencies: AppDependencies.inMemory()),
    );
    await tester.pumpAndSettle();

    expect(find.text('账号总数'), findsOneWidget);
    expect(find.text('总积分'), findsOneWidget);
    expect(find.text('选择账号'), findsOneWidget);
    expect(find.text('选择区域'), findsOneWidget);
    expect(find.text('立即取水 7.5L'), findsOneWidget);
    expect(find.text('立即取水 15L'), findsOneWidget);
    expect(find.text('批量操作'), findsOneWidget);
    expect(find.text('批量签到'), findsOneWidget);
    expect(find.text('批量抽奖'), findsOneWidget);

    expect(find.text('快捷操作'), findsNothing);
    expect(find.text('最新日志'), findsNothing);
    expect(find.text('在线账号'), findsNothing);
  });

  testWidgets('shows account management and can open auth page', (
    tester,
  ) async {
    await tester.pumpWidget(
      WaterNodeApp(dependencies: AppDependencies.inMemory()),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('open-drawer')));
    await tester.pumpAndSettle();

    await tester.tap(find.text('账号管理'));
    await tester.pumpAndSettle();

    expect(find.text('账号管理'), findsWidgets);
    expect(find.text('刷新积分'), findsOneWidget);
    expect(find.text('新增账号'), findsOneWidget);
    expect(find.text('备注'), findsWidgets);

    Get.find<ConsoleShellController>().selectRoute(AppRoutes.auth);
    await tester.pumpAndSettle();

    expect(find.text('登录授权'), findsWidgets);
    expect(find.text('获取验证码'), findsOneWidget);
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
    expect(find.byTooltip('登录授权'), findsOneWidget);
    expect(find.byTooltip('终端大厅'), findsNothing);
    expect(find.byTooltip('批量任务'), findsNothing);
  });
}
