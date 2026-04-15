import 'package:flutter/material.dart';
import 'package:waternode/app/routes/app_routes.dart';

class ConsoleNavigationCatalog {
  static const groups = <ConsoleNavigationGroup>[
    ConsoleNavigationGroup(
      title: '工作台',
      items: <ConsoleNavigationItem>[
        ConsoleNavigationItem(
          route: AppRoutes.dashboard,
          title: '首页工作台',
          headerTitle: '首页工作台',
          subtitle: '取水入口、核心统计与批量操作',
          groupTitle: '工作台',
          icon: Icons.space_dashboard_rounded,
        ),
        ConsoleNavigationItem(
          route: AppRoutes.logs,
          title: '结果日志',
          headerTitle: '结果追踪',
          subtitle: '操作记录与账单核对',
          groupTitle: '工作台',
          icon: Icons.receipt_long_rounded,
        ),
      ],
    ),
    ConsoleNavigationGroup(
      title: '账号',
      items: <ConsoleNavigationItem>[
        ConsoleNavigationItem(
          route: AppRoutes.credentials,
          title: '账号管理',
          headerTitle: '账号管理',
          subtitle: '账号备注、积分与签到状态',
          groupTitle: '账号',
          icon: Icons.badge_rounded,
        ),
        ConsoleNavigationItem(
          route: AppRoutes.auth,
          title: '登录授权',
          headerTitle: '登录授权',
          subtitle: '新增或更新账号',
          groupTitle: '账号',
          icon: Icons.login_rounded,
        ),
      ],
    ),
  ];

  static List<ConsoleNavigationItem> get items =>
      groups.expand((group) => group.items).toList(growable: false);

  static ConsoleNavigationItem find(String route) {
    return items.firstWhere(
      (item) => item.route == route,
      orElse: () => items.first,
    );
  }

  static int indexOf(String route) {
    final index = items.indexWhere((item) => item.route == route);
    return index < 0 ? 0 : index;
  }
}

class ConsoleNavigationGroup {
  const ConsoleNavigationGroup({required this.title, required this.items});

  final String title;
  final List<ConsoleNavigationItem> items;
}

class ConsoleNavigationItem {
  const ConsoleNavigationItem({
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
