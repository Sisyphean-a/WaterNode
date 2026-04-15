import 'package:get/get.dart';
import 'package:waternode/app/routes/app_routes.dart';
import 'package:waternode/features/auth/presentation/pages/auth_page.dart';
import 'package:waternode/features/credentials/presentation/pages/credential_page.dart';
import 'package:waternode/features/dashboard/presentation/pages/dashboard_page.dart';
import 'package:waternode/features/devices/presentation/pages/device_station_page.dart';

abstract final class AppPages {
  static final routes = <GetPage<dynamic>>[
    GetPage<dynamic>(name: AppRoutes.dashboard, page: DashboardPage.new),
    GetPage<dynamic>(name: AppRoutes.devices, page: DeviceStationPage.new),
    GetPage<dynamic>(name: AppRoutes.credentials, page: CredentialPage.new),
    GetPage<dynamic>(name: AppRoutes.auth, page: AuthPage.new),
  ];
}
