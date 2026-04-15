import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:waternode/app/application/console_shell_controller.dart';
import 'package:waternode/app/presentation/widgets/workbench_section.dart';
import 'package:waternode/app/routes/app_routes.dart';
import 'package:waternode/features/credentials/application/credential_controller.dart';
import 'package:waternode/features/credentials/presentation/widgets/credential_card.dart';

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
            title: '账号管理',
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
                      label: const Text('新增账号'),
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
                        Expanded(flex: 3, child: Text('账号')),
                        Expanded(flex: 3, child: Text('备注')),
                        Expanded(child: Text('积分', textAlign: TextAlign.right)),
                        SizedBox(width: 96),
                      ],
                    ),
                    const SizedBox(height: 8),
                    for (final credential in controller.credentials)
                      CredentialCard(
                        credential: credential,
                        onSaveRemark: (remark) => controller.updateAccountMeta(
                          credential,
                          remark: remark.trim().isEmpty ? null : remark.trim(),
                        ),
                      ),
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
