import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:waternode/app/app.dart';
import 'package:waternode/app/dependencies/app_dependencies.dart';

void main() {
  testWidgets('opens sidebar and navigates to device station page', (
    tester,
  ) async {
    await tester.pumpWidget(
      WaterNodeApp(dependencies: AppDependencies.inMemory()),
    );
    await tester.pumpAndSettle();

    expect(find.text('首页概览'), findsOneWidget);

    await tester.tap(find.byTooltip('展开导航'));
    await tester.pumpAndSettle();

    expect(find.text('设备中心'), findsOneWidget);
    await tester.tap(find.text('终端大厅'));
    await tester.pumpAndSettle();

    expect(find.text('终端管理大厅'), findsOneWidget);
    expect(find.text('免费接水配置'), findsOneWidget);
    expect(find.text('立即取水 7.5L'), findsWidgets);
  });

  testWidgets('moves account pages into sidebar and keeps home lightweight', (
    tester,
  ) async {
    await tester.pumpWidget(
      WaterNodeApp(dependencies: AppDependencies.inMemory()),
    );
    await tester.pumpAndSettle();

    expect(find.text('执行批量打卡'), findsNothing);
    expect(find.text('执行批量积分抽取'), findsNothing);

    await tester.tap(find.byTooltip('展开导航'));
    await tester.pumpAndSettle();

    expect(find.text('账号中心'), findsOneWidget);
    await tester.tap(find.text('凭证管理'));
    await tester.pumpAndSettle();

    expect(find.text('凭证管理'), findsOneWidget);
    expect(find.text('新增登录凭证'), findsOneWidget);
    expect(find.text('刷新积分'), findsOneWidget);

    await tester.tap(find.byTooltip('展开导航'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('登录授权'));
    await tester.pumpAndSettle();

    expect(find.text('登录授权'), findsOneWidget);
    expect(find.text('获取验证码'), findsOneWidget);
  });

  testWidgets('moves batch actions into sidebar task page', (tester) async {
    await tester.pumpWidget(
      WaterNodeApp(dependencies: AppDependencies.inMemory()),
    );
    await tester.pumpAndSettle();

    expect(find.text('执行批量打卡'), findsNothing);
    expect(find.text('执行批量积分抽取'), findsNothing);

    await tester.tap(find.byTooltip('展开导航'));
    await tester.pumpAndSettle();

    expect(find.text('任务中心'), findsOneWidget);
    await tester.tap(find.text('批量任务'));
    await tester.pumpAndSettle();

    expect(find.text('批量任务'), findsWidgets);
    expect(find.text('执行批量打卡'), findsOneWidget);
    expect(find.text('执行批量积分抽取'), findsOneWidget);
  });

  testWidgets('navigates to device station when tapping home water action', (
    tester,
  ) async {
    await tester.pumpWidget(
      WaterNodeApp(dependencies: AppDependencies.inMemory()),
    );
    await tester.pumpAndSettle();

    expect(find.text('首页概览'), findsOneWidget);
    expect(find.text('终端管理大厅'), findsNothing);

    await tester.tap(find.widgetWithText(FilledButton, '立即取水'));
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

    await tester.tap(find.byTooltip('展开导航'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('凭证管理'));
    await tester.pumpAndSettle();

    expect(find.text('凭证管理'), findsOneWidget);
    expect(find.text('登录授权'), findsNothing);

    await tester.tap(find.widgetWithText(FilledButton, '新增登录凭证'));
    await tester.pumpAndSettle();

    expect(find.text('登录授权'), findsOneWidget);
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
