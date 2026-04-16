import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:waternode/app/application/console_shell_controller.dart';
import 'package:waternode/app/presentation/widgets/workbench_section.dart';
import 'package:waternode/app/routes/app_routes.dart';
import 'package:waternode/features/credentials/application/credential_controller.dart';
import 'package:waternode/features/credentials/presentation/widgets/credential_card.dart';
import 'package:waternode/features/credentials/presentation/widgets/token_import_dialog.dart';

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
                      key: const Key('open-token-import-dialog'),
                      onPressed: controller.isImporting.value
                          ? null
                          : () => showDialog<void>(
                              context: context,
                              builder: (_) => TokenImportDialog(
                                controller: controller,
                              ),
                            ),
                      icon: const Icon(Icons.key_rounded),
                      label: const Text('导入 Token'),
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
                        SizedBox(width: 144),
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
                        onCopyToken: () => _copyToken(context, credential.token),
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

  Future<void> _copyToken(BuildContext context, String token) async {
    await Clipboard.setData(ClipboardData(text: token));
    if (!context.mounted) {
      return;
    }
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Token 已复制')));
  }
}
