import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:waternode/app/application/console_shell_controller.dart';
import 'package:waternode/app/presentation/widgets/workbench_section.dart';
import 'package:waternode/app/routes/app_routes.dart';
import 'package:waternode/features/credentials/application/credential_controller.dart';
import 'package:waternode/features/credentials/presentation/widgets/credential_card.dart';
import 'package:waternode/features/dashboard/presentation/widgets/summary_panel.dart';

class CredentialPage extends GetView<CredentialController> {
  const CredentialPage({super.key});

  @override
  Widget build(BuildContext context) {
    final shell = Get.find<ConsoleShellController>();

    return Obx(
      () => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          WorkbenchSection(
            title: '凭证库',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    FilledButton.tonalIcon(
                      onPressed: controller.isRefreshing.value
                          ? null
                          : controller.refreshStatuses,
                      icon: const Icon(Icons.refresh_rounded),
                      label: const Text('刷新积分'),
                    ),
                    FilledButton.icon(
                      key: const Key('open-auth-workspace'),
                      onPressed: () => shell.selectRoute(AppRoutes.auth),
                      icon: const Icon(Icons.add_rounded),
                      label: const Text('新增凭证'),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    SizedBox(
                      width: 120,
                      child: SummaryPanel(
                        label: '账号数',
                        value: '${controller.totalCount}',
                      ),
                    ),
                    SizedBox(
                      width: 120,
                      child: SummaryPanel(
                        label: '在线',
                        value: '${controller.validCount}',
                      ),
                    ),
                    SizedBox(
                      width: 120,
                      child: SummaryPanel(
                        label: '积分池',
                        value: '${controller.totalPoints}',
                      ),
                    ),
                  ],
                ),
                if (controller.lastError.value != null) ...[
                  const SizedBox(height: 10),
                  Text(
                    controller.lastError.value!,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.error,
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 10),
          Expanded(
            child: WorkbenchSection(
              title: '账号列表',
              expandChild: true,
              child: RefreshIndicator(
                onRefresh: controller.refreshStatuses,
                child: ListView(
                  children: [
                    Row(
                      children: const [
                        Expanded(flex: 3, child: Text('手机号')),
                        Expanded(child: Text('积分', textAlign: TextAlign.right)),
                        SizedBox(width: 78),
                      ],
                    ),
                    const SizedBox(height: 8),
                    for (final credential in controller.credentials)
                      CredentialCard(credential: credential),
                    if (controller.credentials.isEmpty)
                      const Padding(
                        padding: EdgeInsets.only(top: 24),
                        child: Center(child: Text('暂无测试账号')),
                      ),
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
