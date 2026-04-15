import 'package:get/get.dart';
import 'package:waternode/app/routes/app_routes.dart';

class ConsoleShellController extends GetxController {
  final activeRoute = AppRoutes.dashboard.obs;
  final isSidebarExpanded = false.obs;

  void reset() {
    activeRoute.value = AppRoutes.dashboard;
    isSidebarExpanded.value = false;
  }

  void toggleSidebar() {
    isSidebarExpanded.value = !isSidebarExpanded.value;
  }

  void selectRoute(
    String route, {
    bool closeDrawer = false,
    bool collapseSidebar = false,
  }) {
    activeRoute.value = route;
    if (collapseSidebar) {
      isSidebarExpanded.value = false;
    }
    if (closeDrawer && Get.isOverlaysOpen) {
      Get.back<void>();
    }
  }
}
