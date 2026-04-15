import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:waternode/app/application/console_shell_controller.dart';
import 'package:waternode/app/presentation/widgets/workbench_section.dart';
import 'package:waternode/app/routes/app_routes.dart';
import 'package:waternode/features/dashboard/application/dashboard_controller.dart';
import 'package:waternode/features/dashboard/presentation/widgets/summary_panel.dart';

class DashboardPage extends GetView<DashboardController> {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    final shell = Get.find<ConsoleShellController>();

    return Obx(
      () => ListView(
        children: [
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              SizedBox(
                width: 160,
                child: SummaryPanel(
                  label: '账号总数',
                  value: '${controller.totalCount}',
                ),
              ),
              SizedBox(
                width: 160,
                child: SummaryPanel(
                  label: '在线账号',
                  value: '${controller.validCount}',
                ),
              ),
              SizedBox(
                width: 160,
                child: SummaryPanel(
                  label: '总积分',
                  value: '${controller.totalPoints}',
                ),
              ),
              SizedBox(
                width: 160,
                child: SummaryPanel(
                  label: '失效账号',
                  value: '${controller.invalidCount}',
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          LayoutBuilder(
            builder: (context, constraints) {
              final singleColumn = constraints.maxWidth < 860;
              if (singleColumn) {
                return Column(
                  children: [
                    _QuickActions(shell: shell),
                    const SizedBox(height: 10),
                    _LatestLog(logMessage: _latestLogMessage(controller)),
                  ],
                );
              }

              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(child: _QuickActions(shell: shell)),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _LatestLog(
                      logMessage: _latestLogMessage(controller),
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  String _latestLogMessage(DashboardController controller) {
    if (controller.logs.isEmpty) {
      return '尚无批量任务日志';
    }
    return controller.logs.first.message;
  }
}

class _QuickActions extends StatelessWidget {
  const _QuickActions({required this.shell});

  final ConsoleShellController shell;

  @override
  Widget build(BuildContext context) {
    return WorkbenchSection(
      title: '快捷操作',
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: [
          FilledButton.icon(
            key: const Key('open-devices-workspace'),
            onPressed: () => shell.selectRoute(AppRoutes.devices),
            icon: const Icon(Icons.water_drop_rounded),
            label: const Text('进入终端大厅'),
          ),
          FilledButton.tonalIcon(
            onPressed: () => shell.selectRoute(AppRoutes.tasks),
            icon: const Icon(Icons.task_alt_rounded),
            label: const Text('打开批量任务'),
          ),
          FilledButton.tonalIcon(
            onPressed: () => shell.selectRoute(AppRoutes.credentials),
            icon: const Icon(Icons.badge_rounded),
            label: const Text('查看凭证库'),
          ),
        ],
      ),
    );
  }
}

class _LatestLog extends StatelessWidget {
  const _LatestLog({required this.logMessage});

  final String logMessage;

  @override
  Widget build(BuildContext context) {
    return WorkbenchSection(title: '最新日志', child: Text(logMessage));
  }
}
