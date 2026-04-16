import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:waternode/app/application/console_shell_controller.dart';
import 'package:waternode/app/presentation/widgets/console_navigation_catalog.dart';
import 'package:waternode/app/presentation/widgets/console_sidebar.dart';
import 'package:waternode/app/presentation/widgets/console_workspace_shell.dart';
import 'package:waternode/features/credentials/presentation/pages/credential_page.dart';
import 'package:waternode/features/dashboard/presentation/pages/dashboard_page.dart';
import 'package:waternode/features/dashboard/presentation/pages/task_center_page.dart';

class ConsoleShellPage extends GetView<ConsoleShellController> {
  const ConsoleShellPage({super.key});

  static const _pages = <Widget>[
    DashboardPage(),
    TaskCenterPage(),
    CredentialPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final activeItem = ConsoleNavigationCatalog.find(
        controller.activeRoute.value,
      );
      final viewportWidth = MediaQuery.sizeOf(context).width;
      final isWideLayout = viewportWidth >= 980;
      final currentIndex = ConsoleNavigationCatalog.indexOf(
        controller.activeRoute.value,
      );

      final content = ConsoleWorkspaceShell(
        isWideLayout: isWideLayout,
        activeItem: activeItem,
        isSidebarExpanded: controller.isSidebarExpanded.value,
        onToggleSidebar: controller.toggleSidebar,
        child: IndexedStack(index: currentIndex, children: _pages),
      );

      return Scaffold(
        body: isWideLayout
            ? Row(
                children: [
                  ConsoleSidebar(
                    activeRoute: controller.activeRoute.value,
                    isExpanded: controller.isSidebarExpanded.value,
                    onSelectRoute: (route) =>
                        controller.selectRoute(route, collapseSidebar: true),
                  ),
                  Expanded(child: content),
                ],
              )
            : content,
        bottomNavigationBar: isWideLayout
            ? null
            : viewportWidth < 360
            ? _CompactBottomBar(
                currentIndex: currentIndex,
                items: ConsoleNavigationCatalog.items,
                onSelectRoute: controller.selectRoute,
                labelBuilder: _navigationLabel,
              )
            : NavigationBar(
                labelBehavior:
                    NavigationDestinationLabelBehavior.onlyShowSelected,
                selectedIndex: currentIndex,
                onDestinationSelected: (index) {
                  final item = ConsoleNavigationCatalog.items[index];
                  controller.selectRoute(item.route);
                },
                destinations: [
                  for (final item in ConsoleNavigationCatalog.items)
                    NavigationDestination(
                      icon: Icon(item.icon),
                      label: _navigationLabel(item.route),
                    ),
                ],
              ),
      );
    });
  }

  String _navigationLabel(String route) {
    switch (route) {
      case ConsoleNavigationCatalog.homeRoute:
        return '首页';
      case ConsoleNavigationCatalog.logsRoute:
        return '日志';
      case ConsoleNavigationCatalog.credentialsRoute:
        return '账号';
      default:
        return '工作台';
    }
  }
}

class _CompactBottomBar extends StatelessWidget {
  const _CompactBottomBar({
    required this.currentIndex,
    required this.items,
    required this.onSelectRoute,
    required this.labelBuilder,
  });

  final int currentIndex;
  final List<ConsoleNavigationItem> items;
  final ValueChanged<String> onSelectRoute;
  final String Function(String route) labelBuilder;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Material(
      color: theme.colorScheme.surface,
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 72,
          child: Row(
            children: [
              for (var index = 0; index < items.length; index++)
                Expanded(
                  child: InkWell(
                    onTap: () => onSelectRoute(items[index].route),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          items[index].icon,
                          color: index == currentIndex
                              ? theme.colorScheme.primary
                              : theme.colorScheme.onSurfaceVariant,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          labelBuilder(items[index].route),
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: index == currentIndex
                                ? theme.colorScheme.primary
                                : theme.colorScheme.onSurfaceVariant,
                            fontWeight: index == currentIndex
                                ? FontWeight.w700
                                : FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
