import 'package:flutter_test/flutter_test.dart';
import 'package:waternode/app/dependencies/app_dependencies.dart';
import 'package:waternode/app/app.dart';

void main() {
  testWidgets('boots into console home with overview and water action', (
    tester,
  ) async {
    await tester.pumpWidget(
      WaterNodeApp(dependencies: AppDependencies.inMemory()),
    );

    await tester.pumpAndSettle();

    expect(find.text('首页概览'), findsOneWidget);
    expect(find.text('取水操作'), findsOneWidget);
    expect(find.text('立即取水'), findsOneWidget);
  });
}
