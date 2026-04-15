import 'package:get/get.dart';
import 'package:waternode/app/presentation/pages/console_shell_page.dart';
import 'package:waternode/app/routes/app_routes.dart';

abstract final class AppPages {
  static final routes = <GetPage<dynamic>>[
    GetPage<dynamic>(
      name: AppRoutes.dashboard,
      page: () => const ConsoleShellPage(),
    ),
  ];
}
