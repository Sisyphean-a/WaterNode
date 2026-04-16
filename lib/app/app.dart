import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:waternode/app/bindings/app_binding.dart';
import 'package:waternode/app/dependencies/app_dependencies.dart';
import 'package:waternode/app/routes/app_pages.dart';
import 'package:waternode/app/routes/app_routes.dart';
import 'package:waternode/app/theme/app_theme.dart';

class WaterNodeApp extends StatelessWidget {
  WaterNodeApp({super.key, AppDependencies? dependencies})
    : _dependencies = dependencies ?? AppDependencies.inMemory();

  final AppDependencies _dependencies;

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'WaterNode',
      debugShowCheckedModeBanner: false,
      initialRoute: AppRoutes.dashboard,
      getPages: AppPages.routes,
      initialBinding: AppBinding(_dependencies),
      theme: AppTheme.build(),
    );
  }
}
