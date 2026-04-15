import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:waternode/features/dashboard/application/dashboard_controller.dart';
import 'package:waternode/features/dashboard/presentation/widgets/log_panel.dart';

class TaskCenterPage extends GetView<DashboardController> {
  const TaskCenterPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('批量任务', style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: 8),
                  Text(
                    '统一执行账号批量打卡和积分抽取，首页只保留信息展示与取水入口。',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 16),
                  Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: [
                      FilledButton.icon(
                        onPressed:
                            controller.isSigningIn.value ||
                                controller.isDrawing.value
                            ? null
                            : controller.runBatchSignIn,
                        icon: const Icon(Icons.fact_check_rounded),
                        label: Text(
                          controller.isSigningIn.value ? '打卡执行中' : '执行批量打卡',
                        ),
                      ),
                      FilledButton.icon(
                        onPressed:
                            controller.isSigningIn.value ||
                                controller.isDrawing.value
                            ? null
                            : controller.runBatchLuckDraw,
                        icon: const Icon(Icons.casino_rounded),
                        label: Text(
                          controller.isDrawing.value ? '抽取执行中' : '执行批量积分抽取',
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '任务执行日志',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '最近一次日志会同步显示在首页快照，这里保留完整执行记录。',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 12),
                    Expanded(child: LogPanel(logs: controller.logs)),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
