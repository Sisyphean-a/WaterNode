import 'package:flutter_test/flutter_test.dart';
import 'package:waternode/app/dependencies/app_dependencies.dart';
import 'package:waternode/app/app.dart';

void main() {
  testWidgets('boots into compact workbench home', (tester) async {
    await tester.pumpWidget(
      WaterNodeApp(dependencies: AppDependencies.inMemory()),
    );

    await tester.pumpAndSettle();

    expect(find.text('首页工作台'), findsWidgets);
    expect(find.text('选择账号'), findsOneWidget);
    expect(find.text('立即取水 7.5L'), findsOneWidget);
  });
}
