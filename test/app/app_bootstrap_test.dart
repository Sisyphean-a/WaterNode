import 'package:flutter_test/flutter_test.dart';
import 'package:waternode/app/dependencies/app_dependencies.dart';
import 'package:waternode/app/app.dart';

void main() {
  testWidgets('boots into compact workbench home', (tester) async {
    await tester.pumpWidget(
      WaterNodeApp(dependencies: AppDependencies.inMemory()),
    );

    await tester.pumpAndSettle();

    expect(find.text('系统快照'), findsOneWidget);
    expect(find.text('快捷操作'), findsOneWidget);
    expect(find.text('进入终端大厅'), findsOneWidget);
  });
}
