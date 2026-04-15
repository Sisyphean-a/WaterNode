import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:waternode/app/routes/app_routes.dart';
import 'package:waternode/features/auth/presentation/pages/auth_page.dart';
import 'package:waternode/features/credentials/presentation/pages/credential_page.dart';
import 'package:waternode/features/dashboard/presentation/pages/dashboard_page.dart';
import 'package:waternode/features/devices/presentation/pages/device_station_page.dart';

class ConsoleShellPage extends StatefulWidget {
  const ConsoleShellPage({super.key, required this.activeRoute});

  final String activeRoute;

  @override
  State<ConsoleShellPage> createState() => _ConsoleShellPageState();
}

class _ConsoleShellPageState extends State<ConsoleShellPage> {
  bool _isSidebarExpanded = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final activeItem = _ConsoleNavigationCatalog.find(widget.activeRoute);
    final isWideLayout = MediaQuery.sizeOf(context).width >= 980;

    return Scaffold(
      drawer: isWideLayout
          ? null
          : Drawer(
              child: SafeArea(
                child: _ConsoleSidebar(
                  activeRoute: widget.activeRoute,
                  isExpanded: true,
                  onSelectRoute: _handleRouteChange,
                ),
              ),
            ),
      body: SafeArea(
        child: Row(
          children: [
            if (isWideLayout)
              AnimatedContainer(
                duration: const Duration(milliseconds: 220),
                curve: Curves.easeOutCubic,
                width: _isSidebarExpanded ? 280 : 92,
                child: _ConsoleSidebar(
                  activeRoute: widget.activeRoute,
                  isExpanded: _isSidebarExpanded,
                  onSelectRoute: _handleRouteChange,
                ),
              ),
            Expanded(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: Color.alphaBlend(
                    theme.colorScheme.primary.withValues(alpha: 0.04),
                    theme.colorScheme.surface,
                  ),
                ),
                child: Column(
                  children: [
                    _ConsoleHeader(
                      title: activeItem.headerTitle,
                      section: activeItem.groupTitle,
                      isWideLayout: isWideLayout,
                      isSidebarExpanded: _isSidebarExpanded,
                      onToggleSidebar: () {
                        if (!isWideLayout) {
                          return;
                        }
                        setState(() {
                          _isSidebarExpanded = !_isSidebarExpanded;
                        });
                      },
                    ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(28),
                          child: DecoratedBox(
                            decoration: BoxDecoration(
                              color: theme.colorScheme.surface,
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(20),
                              child: _buildContent(),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent() {
    return switch (widget.activeRoute) {
      AppRoutes.dashboard => const DashboardPage(),
      AppRoutes.devices => const DeviceStationPage(),
      AppRoutes.credentials => const CredentialPage(),
      AppRoutes.auth => const AuthPage(),
      _ => const DashboardPage(),
    };
  }

  void _handleRouteChange(String route) {
    if (route == widget.activeRoute) {
      Navigator.of(context).maybePop();
      return;
    }

    Navigator.of(context).maybePop();
    Get.offNamed<dynamic>(route);
  }
}

class _ConsoleHeader extends StatelessWidget {
  const _ConsoleHeader({
    required this.title,
    required this.section,
    required this.isWideLayout,
    required this.isSidebarExpanded,
    required this.onToggleSidebar,
  });

  final String title;
  final String section;
  final bool isWideLayout;
  final bool isSidebarExpanded;
  final VoidCallback onToggleSidebar;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
      child: Row(
        children: [
          Builder(
            builder: (buttonContext) => IconButton.filledTonal(
              onPressed: isWideLayout
                  ? onToggleSidebar
                  : Scaffold.of(buttonContext).openDrawer,
              tooltip: isWideLayout && isSidebarExpanded ? '收起导航' : '展开导航',
              icon: Icon(
                isWideLayout && isSidebarExpanded
                    ? Icons.menu_open_rounded
                    : Icons.menu_rounded,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  section,
                  style: theme.textTheme.labelLarge?.copyWith(
                    color: theme.colorScheme.primary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(title, style: theme.textTheme.headlineSmall),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ConsoleSidebar extends StatelessWidget {
  const _ConsoleSidebar({
    required this.activeRoute,
    required this.isExpanded,
    required this.onSelectRoute,
  });

  final String activeRoute;
  final bool isExpanded;
  final ValueChanged<String> onSelectRoute;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return DecoratedBox(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        border: Border(
          right: BorderSide(color: theme.dividerColor.withValues(alpha: 0.15)),
        ),
      ),
      child: ListView(
        padding: EdgeInsets.fromLTRB(isExpanded ? 16 : 12, 20, 12, 20),
        children: [
          _SidebarBrand(isExpanded: isExpanded),
          const SizedBox(height: 24),
          for (final group in _ConsoleNavigationCatalog.groups) ...[
            if (isExpanded) ...[
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 0, 12, 10),
                child: Text(
                  group.title,
                  style: theme.textTheme.labelLarge?.copyWith(
                    color: theme.colorScheme.primary,
                  ),
                ),
              ),
            ],
            for (final item in group.items)
              _SidebarItem(
                item: item,
                isExpanded: isExpanded,
                isActive: item.route == activeRoute,
                onTap: () => onSelectRoute(item.route),
              ),
            const SizedBox(height: 12),
          ],
        ],
      ),
    );
  }
}

class _SidebarBrand extends StatelessWidget {
  const _SidebarBrand({required this.isExpanded});

  final bool isExpanded;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: theme.colorScheme.primary,
            borderRadius: BorderRadius.circular(16),
          ),
          alignment: Alignment.center,
          child: Text(
            'W',
            style: theme.textTheme.titleLarge?.copyWith(
              color: theme.colorScheme.onPrimary,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        if (isExpanded) ...[
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'WaterNode',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '取水调度控制台',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}

class _SidebarItem extends StatelessWidget {
  const _SidebarItem({
    required this.item,
    required this.isExpanded,
    required this.isActive,
    required this.onTap,
  });

  final _ConsoleNavigationItem item;
  final bool isExpanded;
  final bool isActive;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final selectedColor = theme.colorScheme.primary;
    final backgroundColor = isActive
        ? selectedColor.withValues(alpha: 0.12)
        : Colors.transparent;

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Material(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(18),
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: onTap,
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: isExpanded ? 14 : 10,
              vertical: 12,
            ),
            child: Row(
              children: [
                Icon(
                  item.icon,
                  color: isActive
                      ? selectedColor
                      : theme.colorScheme.onSurfaceVariant,
                ),
                if (isExpanded) ...[
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.title,
                          style: theme.textTheme.titleSmall?.copyWith(
                            color: isActive ? selectedColor : null,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          item.subtitle,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ConsoleNavigationCatalog {
  static const groups = <_ConsoleNavigationGroup>[
    _ConsoleNavigationGroup(
      title: '总览中心',
      items: <_ConsoleNavigationItem>[
        _ConsoleNavigationItem(
          route: AppRoutes.dashboard,
          title: '首页概览',
          headerTitle: '首页概览',
          subtitle: '查看统计与取水入口',
          groupTitle: '总览中心',
          icon: Icons.dashboard_customize_rounded,
        ),
      ],
    ),
    _ConsoleNavigationGroup(
      title: '设备中心',
      items: <_ConsoleNavigationItem>[
        _ConsoleNavigationItem(
          route: AppRoutes.devices,
          title: '终端大厅',
          headerTitle: '终端管理大厅',
          subtitle: '选择区域并下发取水指令',
          groupTitle: '设备中心',
          icon: Icons.water_drop_rounded,
        ),
      ],
    ),
    _ConsoleNavigationGroup(
      title: '账号中心',
      items: <_ConsoleNavigationItem>[
        _ConsoleNavigationItem(
          route: AppRoutes.credentials,
          title: '凭证管理',
          headerTitle: '凭证管理',
          subtitle: '查看测试账号状态',
          groupTitle: '账号中心',
          icon: Icons.badge_rounded,
        ),
        _ConsoleNavigationItem(
          route: AppRoutes.auth,
          title: '登录授权',
          headerTitle: '登录授权',
          subtitle: '新增短信登录凭证',
          groupTitle: '账号中心',
          icon: Icons.login_rounded,
        ),
      ],
    ),
  ];

  static _ConsoleNavigationItem find(String route) {
    return groups
        .expand((group) => group.items)
        .firstWhere(
          (item) => item.route == route,
          orElse: () => groups.first.items.first,
        );
  }
}

class _ConsoleNavigationGroup {
  const _ConsoleNavigationGroup({required this.title, required this.items});

  final String title;
  final List<_ConsoleNavigationItem> items;
}

class _ConsoleNavigationItem {
  const _ConsoleNavigationItem({
    required this.route,
    required this.title,
    required this.headerTitle,
    required this.subtitle,
    required this.groupTitle,
    required this.icon,
  });

  final String route;
  final String title;
  final String headerTitle;
  final String subtitle;
  final String groupTitle;
  final IconData icon;
}
