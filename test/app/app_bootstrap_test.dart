import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:waternode/app/dependencies/app_dependencies.dart';
import 'package:waternode/app/app.dart';

void main() {
  testWidgets('boots into compact workbench home', (tester) async {
    await tester.pumpWidget(
      WaterNodeApp(dependencies: AppDependencies.inMemory()),
    );

    await tester.pumpAndSettle();

    expect(find.text('首页工作台'), findsWidgets);
    expect(find.text('取水控制台'), findsOneWidget);
    expect(find.text('当 前 账 号'), findsOneWidget);
    expect(find.text('目标水站终端'), findsOneWidget);
    expect(find.text('设备列表'), findsNothing);
    expect(find.text('7.5L'), findsOneWidget);
    expect(find.byIcon(Icons.water_drop_outlined), findsOneWidget);
    expect(find.text('登录授权'), findsNothing);
  });
}
