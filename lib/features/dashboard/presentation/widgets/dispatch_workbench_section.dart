import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:waternode/app/presentation/widgets/workbench_section.dart';
import 'package:waternode/features/credentials/application/credential_controller.dart';
import 'package:waternode/features/credentials/domain/models/account_credential.dart';
import 'package:waternode/features/devices/application/device_controller.dart';
import 'package:waternode/features/devices/domain/models/device_station.dart';

class DispatchWorkbenchSection extends StatelessWidget {
  const DispatchWorkbenchSection({
    super.key,
    required this.credentialController,
    required this.deviceController,
  });

  final CredentialController credentialController;
  final DeviceController deviceController;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Obx(
      () => WorkbenchSection(title: '取水控制台', child: _buildContent(context, theme)),
    );
  }

  Widget _buildContent(BuildContext context, ThemeData theme) {
    final selectedCredential = deviceController.selectedCredential.value;
    final selectedStation = deviceController.selectedStation.value;
    final lastError = deviceController.lastError.value;
    final isLoading = deviceController.isLoading.value;

    final accountLabel = selectedCredential == null ? '未选中任何账号' : _accountLabel(selectedCredential);
    final stationLabel = selectedStation == null ? '未绑定对应设备' : _stationLabel(selectedStation);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // 核心改动：上下堆叠的选择器卡片，给文字留足水平空间，专门解决长名字溢出问题
        _StatusCardTile(
          icon: Icons.account_circle_outlined,
          label: '当 前 账 号',
          value: accountLabel,
          trailingText: selectedCredential != null ? '${selectedCredential.points} 分' : null,
          iconColor: theme.colorScheme.primary,
          onTap: () => _showAccountSelector(context),
        ),
        const SizedBox(height: 12),
        _StatusCardTile(
          icon: Icons.ev_station_outlined,
          label: '目标水站终端',
          value: stationLabel,
          iconColor: theme.colorScheme.secondary,
          onTap: () => _showStationSelector(context),
        ),

        if (lastError != null) ...[
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: theme.colorScheme.errorContainer.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                Icon(Icons.error_outline_rounded, color: theme.colorScheme.error),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    lastError,
                    style: TextStyle(
                      color: theme.colorScheme.error,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],

        const SizedBox(height: 24),

        // 超大取水按钮区
        Row(
          children: [
            Expanded(
              child: SizedBox(
                height: 120, // 增加高度增强按压区域
                child: FilledButton.tonal(
                  key: const Key('water-action-7.5'),
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
                  ),
                  onPressed: isLoading
                      ? null
                      : () => _confirmAndSend(context, quantity: 1, volumeLabel: '7.5L'),
                  child: const _WaterActionContent(
                    icon: Icons.water_drop_outlined,
                    label: '7.5L',
                    emphasize: false,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: SizedBox(
                height: 120, // 增加高度增强按压区域
                child: FilledButton(
                  key: const Key('water-action-15'),
                  style: FilledButton.styleFrom(
                    backgroundColor: theme.colorScheme.primary,
                    foregroundColor: theme.colorScheme.onPrimary,
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
                  ),
                  onPressed: isLoading
                      ? null
                      : () => _confirmAndSend(context, quantity: 2, volumeLabel: '15L'),
                  child: const _WaterActionContent(
                    icon: Icons.water_drop_rounded,
                    label: '15L',
                    emphasize: true,
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  String _accountLabel(AccountCredential credential) {
    final remark = credential.remark?.trim();
    if (remark != null && remark.isNotEmpty) {
      return remark;
    }
    return '尾号${credential.mobile.substring(credential.mobile.length - 4)}';
  }

  String _stationLabel(DeviceStation station) {
    final address = station.address;
    if (address == null || address.trim().isEmpty) {
      return station.name;
    }
    return '${station.name} · $address';
  }

  void _showAccountSelector(BuildContext context) {
    final accounts = credentialController.credentials.where((item) => item.isValid).toList();
    if (accounts.isEmpty) return;

    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        final theme = Theme.of(context);
        return _BottomSheetContent(
          title: '切换当前账号',
          child: ListView.separated(
            shrinkWrap: true,
            itemCount: accounts.length,
            separatorBuilder: (context, index) => const SizedBox(height: 8),
            itemBuilder: (context, index) {
              final acc = accounts[index];
              return ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primaryContainer,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.person, color: theme.colorScheme.onPrimaryContainer),
                ),
                title: Text(_accountLabel(acc), style: const TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text(acc.mobile, style: TextStyle(color: theme.colorScheme.onSurfaceVariant)),
                trailing: Text(
                  '${acc.points} 积分',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.primary,
                  ),
                ),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                tileColor: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
                onTap: () {
                  deviceController.selectCredential(acc);
                  Navigator.of(context).pop();
                },
              );
            },
          ),
        );
      },
    );
  }

  void _showStationSelector(BuildContext context) {
    final stations = deviceController.stations;
    if (stations.isEmpty) return;

    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        final theme = Theme.of(context);
        return _BottomSheetContent(
          title: '切换取水终端',
          child: ListView.separated(
            shrinkWrap: true,
            itemCount: stations.length,
            separatorBuilder: (context, index) => const SizedBox(height: 8),
            itemBuilder: (context, index) {
              final st = stations[index];
              return ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.secondaryContainer,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.ev_station, color: theme.colorScheme.onSecondaryContainer),
                ),
                title: Text(st.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text(st.address ?? '暂无地址信息', style: TextStyle(color: theme.colorScheme.onSurfaceVariant)),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                tileColor: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
                onTap: () {
                  deviceController.selectStationById(st.id);
                  Navigator.of(context).pop();
                },
              );
            },
          ),
        );
      },
    );
  }

  Future<void> _confirmAndSend(
    BuildContext context, {
    required int quantity,
    required String volumeLabel,
  }) async {
    final stationName = deviceController.selectedStation.value?.name ?? '当前设备';
    
    // 沉浸式底部操作确认面板 (取代了 AlertDialog)
    final confirmed = await showModalBottomSheet<bool>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        final theme = Theme.of(context);
        return SafeArea(
          child: Container(
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
          ),
          padding: const EdgeInsets.fromLTRB(24, 12, 24, 48), // 增加底部边距适应全面屏
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Container(
                  width: 48,
                  height: 6,
                  decoration: BoxDecoration(
                    color: theme.dividerColor.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                '确认执行指令',
                style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.4),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Column(
                  children: [
                    Text('即将向目标终端', style: theme.textTheme.titleMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
                    const SizedBox(height: 8),
                    Text(stationName, style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold), textAlign: TextAlign.center),
                    const SizedBox(height: 16),
                    Text('下发出水量为', style: theme.textTheme.titleMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
                    const SizedBox(height: 4),
                    Text(
                      volumeLabel,
                      style: theme.textTheme.displayMedium?.copyWith(
                        color: theme.colorScheme.primary,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              FilledButton.icon(
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                ),
                icon: const Icon(Icons.bolt_rounded, size: 28),
                label: const Text('确认出水', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                onPressed: () => Navigator.of(context).pop(true),
              ),
              const SizedBox(height: 16),
              TextButton(
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('放弃操作', style: TextStyle(fontSize: 16)),
              ),
            ],
          ),
        ));
      },
    );

    if (confirmed != true) return;
    await deviceController.sendCommand(quantity: quantity);
  }
}

// ============== 辅助组件 ==============

class _StatusCardTile extends StatelessWidget {
  const _StatusCardTile({
    required this.icon,
    required this.label,
    required this.value,
    this.trailingText,
    required this.iconColor,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final String value;
  final String? trailingText;
  final Color iconColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Material(
      color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
      borderRadius: BorderRadius.circular(20),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: iconColor.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: iconColor, size: 28),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: theme.textTheme.labelMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 2.0,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      value,
                      style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              if (trailingText != null) ...[
                const SizedBox(width: 4),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: iconColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    trailingText!,
                    style: theme.textTheme.labelLarge?.copyWith(
                      color: iconColor,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              ],
              const SizedBox(width: 4),
              Icon(Icons.keyboard_arrow_down_rounded, color: theme.dividerColor.withValues(alpha: 0.5)),
            ],
          ),
        ),
      ),
    );
  }
}

class _WaterActionContent extends StatelessWidget {
  const _WaterActionContent({
    required this.icon,
    required this.label,
    this.emphasize = false,
  });

  final IconData icon;
  final String label;
  final bool emphasize;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(icon, size: emphasize ? 48 : 36, color: emphasize ? null : theme.colorScheme.primary),
        const SizedBox(height: 12),
        Text(
          label,
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.w900,
            color: emphasize ? theme.colorScheme.onPrimary : theme.colorScheme.primary,
          ),
        ),
      ],
    );
  }
}

class _BottomSheetContent extends StatelessWidget {
  const _BottomSheetContent({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return DraggableScrollableSheet(
      initialChildSize: 0.6,
      maxChildSize: 0.9,
      minChildSize: 0.4,
      expand: false,
      builder: (_, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
          ),
          padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Container(
                  width: 48,
                  height: 6,
                  decoration: BoxDecoration(
                    color: theme.dividerColor.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                title,
                style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: SingleChildScrollView(
                  controller: scrollController,
                  child: child,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
