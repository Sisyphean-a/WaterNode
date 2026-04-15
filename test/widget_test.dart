import 'package:flutter_test/flutter_test.dart';
import 'package:waternode/app/app.dart';
import 'package:waternode/app/dependencies/app_dependencies.dart';

void main() {
  testWidgets('shows console home overview', (tester) async {
    await tester.pumpWidget(
      WaterNodeApp(dependencies: AppDependencies.inMemory()),
    );

    await tester.pumpAndSettle();

    expect(find.text('首页概览'), findsOneWidget);
    expect(find.text('取水操作'), findsOneWidget);
  });
}
