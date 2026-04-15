import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:waternode/app/application/console_shell_controller.dart';
import 'package:waternode/app/presentation/widgets/console_navigation_catalog.dart';
import 'package:waternode/app/presentation/widgets/console_sidebar.dart';
import 'package:waternode/app/presentation/widgets/console_workspace_shell.dart';
import 'package:waternode/features/auth/presentation/pages/auth_page.dart';
import 'package:waternode/features/credentials/presentation/pages/credential_page.dart';
import 'package:waternode/features/dashboard/presentation/pages/dashboard_page.dart';
import 'package:waternode/features/dashboard/presentation/pages/task_center_page.dart';

class ConsoleShellPage extends GetView<ConsoleShellController> {
  const ConsoleShellPage({super.key});

  static const _pages = <Widget>[
    DashboardPage(),
    TaskCenterPage(),
    CredentialPage(),
    AuthPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final activeItem = ConsoleNavigationCatalog.find(
        controller.activeRoute.value,
      );
      final isWideLayout = MediaQuery.sizeOf(context).width >= 980;

      return Scaffold(
        drawer: isWideLayout
            ? null
            : Drawer(
                child: SafeArea(
                  child: ConsoleSidebar(
                    activeRoute: controller.activeRoute.value,
                    isExpanded: true,
                    onSelectRoute: (route) {
                      controller.selectRoute(route);
                      Navigator.of(context).pop();
                    },
                  ),
                ),
              ),
        body: SafeArea(
          child: Row(
            children: [
              if (isWideLayout)
                ConsoleSidebar(
                  activeRoute: controller.activeRoute.value,
                  isExpanded: controller.isSidebarExpanded.value,
                  onSelectRoute: (route) =>
                      controller.selectRoute(route, collapseSidebar: true),
                ),
              Expanded(
                child: ConsoleWorkspaceShell(
                  isWideLayout: isWideLayout,
                  activeItem: activeItem,
                  isSidebarExpanded: controller.isSidebarExpanded.value,
                  onToggleSidebar: controller.toggleSidebar,
                  child: IndexedStack(
                    index: ConsoleNavigationCatalog.indexOf(
                      controller.activeRoute.value,
                    ),
                    children: _pages,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    });
  }
}
