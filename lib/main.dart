import 'package:flutter/widgets.dart';
import 'package:waternode/app/dependencies/app_dependencies.dart';
import 'package:waternode/app/app.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final dependencies = await AppDependencies.createDefault();
  runApp(WaterNodeApp(dependencies: dependencies));
}
