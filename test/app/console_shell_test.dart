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

    await tester.tap(find.text('终端大厅'));
    await tester.pumpAndSettle();

    expect(Get.currentRoute, AppRoutes.dashboard);
    expect(find.text('终端管理大厅'), findsOneWidget);
    expect(find.text('免费配置'), findsOneWidget);
    expect(find.text('立即取水 7.5L'), findsWidgets);
  });

  testWidgets('shows compact credential workspace actions', (tester) async {
    await tester.pumpWidget(
      WaterNodeApp(dependencies: AppDependencies.inMemory()),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('open-drawer')));
    await tester.pumpAndSettle();

    await tester.tap(find.text('凭证管理'));
    await tester.pumpAndSettle();

    expect(find.text('凭证库'), findsWidgets);
    expect(find.text('刷新积分'), findsOneWidget);
    expect(find.text('新增凭证'), findsOneWidget);

    Get.find<ConsoleShellController>().selectRoute(AppRoutes.auth);
    await tester.pumpAndSettle();

    expect(find.text('登录授权'), findsWidgets);
    expect(find.text('获取验证码'), findsOneWidget);
  });

  testWidgets('moves batch actions into sidebar task page', (tester) async {
    await tester.pumpWidget(
      WaterNodeApp(dependencies: AppDependencies.inMemory()),
    );
    await tester.pumpAndSettle();

    expect(find.text('批量签到'), findsNothing);
    expect(find.text('批量抽奖'), findsNothing);

    await tester.tap(find.byKey(const Key('open-drawer')));
    await tester.pumpAndSettle();

    await tester.tap(find.text('批量任务'));
    await tester.pumpAndSettle();

    expect(find.text('批量任务'), findsWidgets);
    expect(find.text('批量签到'), findsOneWidget);
    expect(find.text('批量抽奖'), findsOneWidget);
  });

  testWidgets('navigates to device station when tapping home water action', (
    tester,
  ) async {
    await tester.pumpWidget(
      WaterNodeApp(dependencies: AppDependencies.inMemory()),
    );
    await tester.pumpAndSettle();

    expect(find.text('终端管理大厅'), findsNothing);

    await tester.tap(find.text('进入终端大厅').first);
    await tester.pumpAndSettle();

    expect(find.text('终端管理大厅'), findsOneWidget);
    expect(find.text('立即取水 7.5L'), findsWidgets);
  });

  testWidgets('navigates to auth page when tapping add credential action', (
    tester,
  ) async {
    await tester.pumpWidget(
      WaterNodeApp(dependencies: AppDependencies.inMemory()),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('open-drawer')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('凭证管理'));
    await tester.pumpAndSettle();

    expect(find.text('凭证库'), findsWidgets);
    expect(find.text('保存凭证'), findsNothing);
    expect(find.byKey(const Key('open-auth-workspace')), findsOneWidget);

    Get.find<ConsoleShellController>().selectRoute(AppRoutes.auth);
    await tester.pumpAndSettle();

    expect(find.text('保存凭证'), findsOneWidget);
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

    expect(find.text('设备中心'), findsNothing);
    expect(find.byTooltip('首页概览'), findsOneWidget);
    expect(find.byTooltip('终端大厅'), findsOneWidget);
    expect(find.byTooltip('凭证管理'), findsOneWidget);
    expect(find.byTooltip('登录授权'), findsOneWidget);
  });
}
