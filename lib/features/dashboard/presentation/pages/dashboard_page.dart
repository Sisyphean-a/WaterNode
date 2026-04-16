import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:waternode/app/presentation/widgets/workbench_section.dart';
import 'package:waternode/features/credentials/application/credential_controller.dart';
import 'package:waternode/features/credentials/domain/models/account_credential.dart';
import 'package:waternode/features/dashboard/application/dashboard_controller.dart';
import 'package:waternode/features/dashboard/presentation/widgets/summary_panel.dart';
import 'package:waternode/features/devices/application/device_controller.dart';

class DashboardPage extends GetView<DashboardController> {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    final credentialController = Get.find<CredentialController>();
    final deviceController = Get.find<DeviceController>();
    final theme = Theme.of(context);

    return Obx(
      () => ListView(
        children: [
          Row(
            children: [
              Expanded(
                child: SummaryPanel(
                  label: '有效账号数',
                  value: '${controller.totalCount}',
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: SummaryPanel(
                  label: '总可用积分',
                  value: '${controller.totalPoints}',
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          WorkbenchSection(
            title: '极速取水控制台',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                 Row(
                   children: [
                     Expanded(
                       child: _SelectionField<String>(
                        fieldKey: const Key('workbench-account-select'),
                        label: '指派账号',
                        value: deviceController.selectedCredential.value?.mobile,
                        items: credentialController.credentials
                            .where((item) => item.isValid)
                            .map(
                              (item) => DropdownMenuItem<String>(
                                value: item.mobile,
                                child: Text(_accountLabel(item)),
                              ),
                            )
                            .toList(growable: false),
                        onChanged: (value) {
                          final credential = credentialController.credentials
                              .firstWhereOrNull((item) => item.mobile == value);
                          if (credential != null) {
                            deviceController.selectCredential(credential);
                          }
                        },
                      ),
                     ),
                     const SizedBox(width: 16),
                     Expanded(
                       child: _SelectionField<String>(
                        fieldKey: const Key('workbench-region-select'),
                        label: '水源区域',
                        value: deviceController.selectedSource.value?.code,
                        items: deviceController.sources
                            .map(
                              (item) => DropdownMenuItem<String>(
                                value: item.code,
                                child: Text(item.name),
                              ),
                            )
                            .toList(growable: false),
                        onChanged: (value) {
                          if (value != null) {
                            deviceController.selectSourceByCode(value);
                          }
                        },
                      ),
                     ),
                   ],
                 ),
                 
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.info_outline_rounded, size: 20, color: theme.colorScheme.onSurfaceVariant),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _buildStatusLine(deviceController),
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                if (deviceController.lastError.value != null) ...[
                  const SizedBox(height: 12),
                  Text(
                    deviceController.lastError.value!,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.error,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
                const SizedBox(height: 24),
                Wrap(
                  spacing: 16,
                  runSpacing: 16,
                  alignment: WrapAlignment.end,
                  children: [
                    FilledButton.tonalIcon(
                      onPressed: deviceController.isLoading.value
                          ? null
                          : () => deviceController.sendCommand(quantity: 1),
                      icon: const Icon(Icons.water_drop_outlined),
                      label: const Text('标准一杯 7.5L'),
                    ),
                    FilledButton.icon(
                      style: FilledButton.styleFrom(
                        backgroundColor: theme.colorScheme.primary,
                        foregroundColor: theme.colorScheme.onPrimary,
                      ),
                      onPressed: deviceController.isLoading.value
                          ? null
                          : () => deviceController.sendCommand(quantity: 2),
                      icon: const Icon(Icons.water_drop_rounded),
                      label: const Text('畅饮大杯 15L'),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          WorkbenchSection(
            title: '一键自动化',
            child: Wrap(
              spacing: 16,
              runSpacing: 16,
              children: [
                _ActionCard(
                  icon: Icons.fact_check_rounded,
                  title: '全员智能签到',
                  subtitle: controller.isSigningIn.value ? 'AI自动执行中...' : '释放双手，自动打卡',
                  isActive: controller.isSigningIn.value,
                  onTap: controller.isSigningIn.value || controller.isDrawing.value
                      ? null
                      : controller.runBatchSignIn,
                ),
                _ActionCard(
                  icon: Icons.casino_rounded,
                  title: '批量自动化抽奖',
                  subtitle: controller.isDrawing.value ? '算力调度执行中...' : '一键抽取所有福利',
                  isActive: controller.isDrawing.value,
                  onTap: controller.isSigningIn.value || controller.isDrawing.value
                      ? null
                      : controller.runBatchLuckDraw,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _accountLabel(AccountCredential credential) {
    if (credential.remark != null && credential.remark!.trim().isNotEmpty) {
      return '${credential.remark} · ${credential.mobile}';
    }
    return credential.mobile;
  }

  String _buildStatusLine(DeviceController controller) {
    final credential = controller.selectedCredential.value;
    final source = controller.selectedSource.value;
    final station = controller.stations.firstOrNull;
    final accountLabel = credential == null
        ? '未指定'
        : _accountLabel(credential);
    final regionLabel = source?.name ?? '自动';
    final stationLabel = station?.name ?? '无可用终端';
    return '目标：$accountLabel | 区域：$regionLabel | 终端：$stationLabel';
  }
}

class _SelectionField<T> extends StatelessWidget {
  const _SelectionField({
    required this.fieldKey,
    required this.label,
    required this.value,
    required this.items,
    required this.onChanged,
  });

  final Key fieldKey;
  final String label;
  final T? value;
  final List<DropdownMenuItem<T>> items;
  final ValueChanged<T?> onChanged;

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<T>(
      key: fieldKey,
      initialValue: value,
      decoration: InputDecoration(labelText: label),
      items: items,
      onChanged: onChanged,
    );
  }
}

class _ActionCard extends StatelessWidget {
  const _ActionCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.isActive,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final bool isActive;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = isActive ? theme.colorScheme.primary : theme.colorScheme.secondary;
    
    return Material(
      color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
      borderRadius: BorderRadius.circular(16),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Container(
          width: 220,
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 28),
              ),
              const SizedBox(height: 16),
              Text(
                title,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: theme.colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: isActive ? color : theme.colorScheme.onSurfaceVariant,
                  fontWeight: isActive ? FontWeight.w600 : null,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
