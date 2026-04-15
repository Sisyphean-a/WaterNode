import 'package:flutter_test/flutter_test.dart';
import 'package:waternode/app/dependencies/app_dependencies.dart';
import 'package:waternode/app/app.dart';

void main() {
  testWidgets('boots into dashboard shell', (tester) async {
    await tester.pumpWidget(
      WaterNodeApp(dependencies: AppDependencies.inMemory()),
    );

    expect(find.text('控制台首页'), findsOneWidget);
  });
}
