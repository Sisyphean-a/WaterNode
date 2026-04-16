import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:waternode/app/presentation/widgets/workbench_section.dart';
import 'package:waternode/features/auth/application/auth_controller.dart';
import 'package:waternode/features/credentials/application/credential_controller.dart';
import 'package:waternode/features/credentials/presentation/widgets/account_login_dialog.dart';
import 'package:waternode/features/credentials/presentation/widgets/credential_card.dart';
import 'package:waternode/features/credentials/presentation/widgets/credential_automation_section.dart';
import 'package:waternode/features/credentials/presentation/widgets/token_import_dialog.dart';
import 'package:waternode/features/dashboard/application/dashboard_controller.dart';

class CredentialPage extends GetView<CredentialController> {
  const CredentialPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final authController = Get.find<AuthController>();
    final dashboardController = Get.find<DashboardController>();

    return Obx(
      () => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
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
                label: const Text('刷新'),
              ),
              FilledButton.tonalIcon(
                key: const Key('open-token-import-dialog'),
                onPressed: controller.isImporting.value
                    ? null
                    : () => showDialog<void>(
                        context: context,
                        builder: (_) =>
                            TokenImportDialog(controller: controller),
                      ),
                icon: const Icon(Icons.key_rounded),
                label: const Text('导入'),
              ),
              FilledButton.icon(
                key: const Key('open-add-account-dialog'),
                onPressed: () => showDialog<void>(
                  context: context,
                  builder: (_) =>
                      AccountLoginDialog(controller: authController),
                ),
                icon: const Icon(Icons.add_rounded),
                label: const Text('新增'),
              ),
              CredentialAutomationSection(controller: dashboardController),
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
                style: TextStyle(color: theme.colorScheme.onErrorContainer),
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
                  separatorBuilder: (context, index) =>
                      const SizedBox(height: 12),
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
