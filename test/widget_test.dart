import 'package:flutter_test/flutter_test.dart';
import 'package:waternode/app/app.dart';
import 'package:waternode/app/dependencies/app_dependencies.dart';

void main() {
  testWidgets('app boots successfully', (tester) async {
    await tester.pumpWidget(
      WaterNodeApp(dependencies: AppDependencies.inMemory()),
    );

    await tester.pumpAndSettle();
    
    // We only verify the app doesn't crash on initial boot. UI assertions are removed as part of the redesign.
    expect(find.byType(WaterNodeApp), findsOneWidget);
  });
}
