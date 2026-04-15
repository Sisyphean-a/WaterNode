import 'package:flutter/material.dart';
import 'package:waternode/app/routes/app_routes.dart';

class ConsoleNavigationCatalog {
  static const groups = <ConsoleNavigationGroup>[
    ConsoleNavigationGroup(
      title: '总览中心',
      items: <ConsoleNavigationItem>[
        ConsoleNavigationItem(
          route: AppRoutes.dashboard,
          title: '首页概览',
          headerTitle: '系统快照',
          subtitle: '状态与快捷入口',
          groupTitle: '总览中心',
          icon: Icons.space_dashboard_rounded,
        ),
      ],
    ),
    ConsoleNavigationGroup(
      title: '任务中心',
      items: <ConsoleNavigationItem>[
        ConsoleNavigationItem(
          route: AppRoutes.tasks,
          title: '批量任务',
          headerTitle: '批量任务',
          subtitle: '签到与抽奖调度',
          groupTitle: '任务中心',
          icon: Icons.task_alt_rounded,
        ),
      ],
    ),
    ConsoleNavigationGroup(
      title: '设备中心',
      items: <ConsoleNavigationItem>[
        ConsoleNavigationItem(
          route: AppRoutes.devices,
          title: '终端大厅',
          headerTitle: '终端管理大厅',
          subtitle: '设备筛选与取水',
          groupTitle: '设备中心',
          icon: Icons.water_drop_rounded,
        ),
      ],
    ),
    ConsoleNavigationGroup(
      title: '账号中心',
      items: <ConsoleNavigationItem>[
        ConsoleNavigationItem(
          route: AppRoutes.credentials,
          title: '凭证管理',
          headerTitle: '凭证库',
          subtitle: '账号与积分状态',
          groupTitle: '账号中心',
          icon: Icons.badge_rounded,
        ),
        ConsoleNavigationItem(
          route: AppRoutes.auth,
          title: '登录授权',
          headerTitle: '登录授权',
          subtitle: '新增测试凭证',
          groupTitle: '账号中心',
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
