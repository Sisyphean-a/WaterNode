import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:waternode/app/routes/app_routes.dart';
import 'package:waternode/features/dashboard/application/dashboard_controller.dart';
import 'package:waternode/features/dashboard/presentation/widgets/log_panel.dart';
import 'package:waternode/features/dashboard/presentation/widgets/summary_panel.dart';

class DashboardPage extends GetView<DashboardController> {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('控制台首页'),
        actions: [
          TextButton(
            onPressed: () => Get.toNamed(AppRoutes.devices),
            child: const Text('终端大厅'),
          ),
          TextButton(
            onPressed: () => Get.toNamed(AppRoutes.credentials),
            child: const Text('凭证管理'),
          ),
        ],
      ),
      body: Obx(
        () => Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  SummaryPanel(
                    label: '总账号数',
                    value: '${controller.totalCount}',
                  ),
                  const SizedBox(width: 12),
                  SummaryPanel(
                    label: '在线账号',
                    value: '${controller.validCount}',
                  ),
                  const SizedBox(width: 12),
                  SummaryPanel(
                    label: '总积分池',
                    value: '${controller.totalPoints}',
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: FilledButton(
                      onPressed: controller.isSigningIn.value
                          ? null
                          : controller.runBatchSignIn,
                      child: const Text('执行批量打卡'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: FilledButton.tonal(
                      onPressed: controller.isDrawing.value
                          ? null
                          : controller.runBatchLuckDraw,
                      child: const Text('执行批量积分抽取'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Expanded(child: LogPanel(logs: controller.logs)),
            ],
          ),
        ),
      ),
    );
  }
}
