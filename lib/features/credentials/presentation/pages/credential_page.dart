import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:waternode/app/presentation/widgets/workbench_section.dart';
import 'package:waternode/features/auth/application/auth_controller.dart';
import 'package:waternode/features/credentials/application/credential_controller.dart';
import 'package:waternode/features/credentials/presentation/widgets/account_login_dialog.dart';
import 'package:waternode/features/credentials/presentation/widgets/credential_card.dart';
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
          // Action Bar
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: theme.dividerColor.withValues(alpha: 0.1)),
              boxShadow: [
                BoxShadow(
                  color: theme.shadowColor.withValues(alpha: 0.02),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              children: [
                // Left Actions
                _buildActionButton(
                  context,
                  icon: Icons.refresh_rounded,
                  tooltip: '刷新数据',
                  onTap: controller.isRefreshing.value ? null : controller.refreshStatuses,
                  isBusy: controller.isRefreshing.value,
                ),
                const SizedBox(width: 8),
                _buildActionButton(
                  context,
                  icon: Icons.check_circle_outline_rounded,
                  tooltip: '批量签到',
                  onTap: (dashboardController.isSigningIn.value || dashboardController.isDrawing.value)
                      ? null
                      : dashboardController.runBatchSignIn,
                  isBusy: dashboardController.isSigningIn.value,
                ),
                const SizedBox(width: 8),
                _buildActionButton(
                  context,
                  icon: Icons.card_giftcard_rounded,
                  tooltip: '批量抽奖',
                  onTap: (dashboardController.isSigningIn.value || dashboardController.isDrawing.value)
                      ? null
                      : dashboardController.runBatchLuckDraw,
                  isBusy: dashboardController.isDrawing.value,
                ),
                const Spacer(),
                // Right Action (Add Menu)
                FilledButton.icon(
                  onPressed: () => _showAddOptions(context, controller, authController),
                  icon: const Icon(Icons.add_rounded),
                  label: const Text('添加'),
                  style: FilledButton.styleFrom(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ],
            ),
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

  Widget _buildActionButton(
    BuildContext context, {
    required IconData icon,
    required String tooltip,
    required VoidCallback? onTap,
    required bool isBusy,
  }) {
    final theme = Theme.of(context);
    return Tooltip(
      message: tooltip,
      child: Material(
        color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(12),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Container(
            width: 44,
            height: 44,
            alignment: Alignment.center,
            child: isBusy
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Icon(
                    icon,
                    size: 20,
                    color: onTap == null
                        ? theme.colorScheme.onSurface.withValues(alpha: 0.38)
                        : theme.colorScheme.primary,
                  ),
          ),
        ),
      ),
    );
  }

  void _showAddOptions(
    BuildContext context,
    CredentialController controller,
    AuthController authController,
  ) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        final theme = Theme.of(context);
        return Container(
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          padding: const EdgeInsets.fromLTRB(24, 12, 24, 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: theme.dividerColor.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                '添加账号',
                style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 16),
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(Icons.login_rounded, color: theme.colorScheme.onPrimaryContainer),
                ),
                title: const Text('手动登录'),
                subtitle: const Text('通过账号密码直接关联'),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                onTap: () {
                  Navigator.of(context).pop();
                  showDialog<void>(
                    context: context,
                    builder: (_) => AccountLoginDialog(controller: authController),
                  );
                },
              ),
              const SizedBox(height: 8),
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.secondaryContainer,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(Icons.key_rounded, color: theme.colorScheme.onSecondaryContainer),
                ),
                title: const Text('导入 Token'),
                subtitle: const Text('直接通过抓包获取的信息导入'),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                onTap: () {
                  if (controller.isImporting.value) return;
                  Navigator.of(context).pop();
                  showDialog<void>(
                    context: context,
                    builder: (_) => TokenImportDialog(controller: controller),
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _copyToken(BuildContext context, String token) async {
    await Clipboard.setData(ClipboardData(text: token));
    if (!context.mounted) {
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Token 已复制')));
  }
}
