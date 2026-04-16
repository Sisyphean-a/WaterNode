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
    final theme = Theme.of(context);

    return Obx(
      () => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              FilledButton.tonalIcon(
                onPressed: controller.isRefreshing.value
                    ? null
                    : controller.refreshStatuses,
                icon: const Icon(Icons.refresh_rounded),
                label: const Text('刷新'),
              ),
              const SizedBox(width: 8),
              FilledButton.tonalIcon(
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
              const SizedBox(width: 8),
              FilledButton.icon(
                key: const Key('open-auth-workspace'),
                onPressed: () => shell.selectRoute(AppRoutes.auth),
                icon: const Icon(Icons.add_rounded),
                label: const Text('新增账号'),
              ),
            ],
          ),
          if (controller.lastError.value != null) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: theme.colorScheme.errorContainer,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                controller.lastError.value!,
                style: TextStyle(
                  color: theme.colorScheme.onErrorContainer,
                ),
              ),
            ),
          ],
          const SizedBox(height: 16),
          Expanded(
            child: WorkbenchSection(
              title: '您的通行证',
              expandChild: true,
              child: RefreshIndicator(
                onRefresh: controller.refreshStatuses,
                child: ListView.separated(
                  separatorBuilder: (context, index) => const SizedBox(height: 12),
                  itemCount: controller.credentials.length,
                  itemBuilder: (context, index) {
                    final credential = controller.credentials[index];
                    return CredentialCard(
                      credential: credential,
                      onSaveRemark: (remark) => controller.updateAccountMeta(
                        credential,
                        remark: remark.trim().isEmpty ? null : remark.trim(),
                      ),
                      onCopyToken: () => _copyToken(context, credential.token),
                    );
                  },
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
