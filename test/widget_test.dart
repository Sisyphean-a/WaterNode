import 'package:flutter_test/flutter_test.dart';
import 'package:waternode/app/app.dart';
import 'package:waternode/app/dependencies/app_dependencies.dart';

void main() {
  testWidgets('shows tool workbench overview', (tester) async {
    await tester.pumpWidget(
      WaterNodeApp(dependencies: AppDependencies.inMemory()),
    );

    await tester.pumpAndSettle();

    expect(find.text('首页工作台'), findsWidgets);
    expect(find.text('选择账号'), findsOneWidget);
    expect(find.text('批量操作'), findsOneWidget);
  });
}
