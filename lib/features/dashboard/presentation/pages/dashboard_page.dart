import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:waternode/app/routes/app_routes.dart';
import 'package:waternode/features/dashboard/application/dashboard_controller.dart';
import 'package:waternode/features/dashboard/presentation/widgets/summary_panel.dart';

class DashboardPage extends GetView<DashboardController> {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => ListView(
        children: [
          LayoutBuilder(
            builder: (context, constraints) {
              final cardWidth = constraints.maxWidth >= 980
                  ? (constraints.maxWidth - 24) / 3
                  : constraints.maxWidth >= 640
                  ? (constraints.maxWidth - 12) / 2
                  : constraints.maxWidth;

              return Wrap(
                spacing: 12,
                runSpacing: 12,
                children: [
                  SizedBox(
                    width: cardWidth,
                    child: SummaryPanel(
                      label: '总账号数',
                      value: '${controller.totalCount}',
                    ),
                  ),
                  SizedBox(
                    width: cardWidth,
                    child: SummaryPanel(
                      label: '在线账号',
                      value: '${controller.validCount}',
                    ),
                  ),
                  SizedBox(
                    width: cardWidth,
                    child: SummaryPanel(
                      label: '总积分池',
                      value: '${controller.totalPoints}',
                    ),
                  ),
                ],
              );
            },
          ),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '取水操作',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '进入终端大厅后，可按区域选择设备并直接下发取水指令。',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  FilledButton.icon(
                    onPressed: () => Get.offNamed<dynamic>(AppRoutes.devices),
                    icon: const Icon(Icons.water_drop_rounded),
                    label: const Text('立即取水'),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('运行快照', style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: 8),
                  Text(
                    '当前已载入 ${controller.totalCount} 个账号，可用 '
                    '${controller.validCount} 个，待处理失效账号 '
                    '${controller.invalidCount} 个。',
                  ),
                  const SizedBox(height: 8),
                  Text(
                    controller.logs.isEmpty
                        ? '暂无批处理日志，首页仅保留状态展示与取水入口。'
                        : controller.logs.first.message,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
