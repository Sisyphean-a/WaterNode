import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:waternode/app/presentation/widgets/workbench_section.dart';
import 'package:waternode/features/dashboard/application/dashboard_controller.dart';
import 'package:waternode/features/dashboard/presentation/widgets/log_panel.dart';
import 'package:waternode/features/dashboard/presentation/widgets/summary_panel.dart';

class TaskCenterPage extends GetView<DashboardController> {
  const TaskCenterPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          WorkbenchSection(
            title: '批量任务',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    SizedBox(
                      width: 140,
                      child: SummaryPanel(
                        label: '在线账号',
                        value: '${controller.validCount}',
                      ),
                    ),
                    SizedBox(
                      width: 140,
                      child: SummaryPanel(
                        label: '积分池',
                        value: '${controller.totalPoints}',
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    FilledButton.icon(
                      onPressed:
                          controller.isSigningIn.value ||
                              controller.isDrawing.value
                          ? null
                          : controller.runBatchSignIn,
                      icon: const Icon(Icons.fact_check_rounded),
                      label: Text(
                        controller.isSigningIn.value ? '签到执行中' : '批量签到',
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
                        controller.isDrawing.value ? '抽奖执行中' : '批量抽奖',
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          Expanded(
            child: WorkbenchSection(
              title: '执行日志',
              expandChild: true,
              child: LogPanel(logs: controller.logs),
            ),
          ),
        ],
      ),
    );
  }
}
