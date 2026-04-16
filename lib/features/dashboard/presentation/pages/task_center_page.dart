import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:waternode/features/dashboard/application/dashboard_controller.dart';
import 'package:waternode/features/dashboard/presentation/widgets/log_panel.dart';
import 'package:waternode/features/devices/application/device_controller.dart';
import 'package:waternode/features/credentials/domain/models/account_credential.dart';

class TaskCenterPage extends StatelessWidget {
  const TaskCenterPage({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Column(
        children: [
          Container(
            color: Theme.of(context).colorScheme.surface,
            child: const TabBar(
              dividerColor: Colors.transparent,
              indicatorSize: TabBarIndicatorSize.tab,
              tabs: [
                Tab(text: '🪙 账单核对'),
                Tab(text: '💧 取水历史'),
                Tab(text: '🤖 系统日志'),
              ],
            ),
          ),
          Expanded(
            child: TabBarView(
              children: [
                _BillView(),
                _DispatchLogView(),
                _SystemLogView(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DispatchLogView extends GetView<DeviceController> {
  @override
  Widget build(BuildContext context) {
    return Obx(() => LogPanel(logs: controller.logs.toList(growable: false)));
  }
}

class _SystemLogView extends GetView<DashboardController> {
  @override
  Widget build(BuildContext context) {
    return Obx(() => LogPanel(logs: controller.logs.toList(growable: false)));
  }
}

class _BillView extends GetView<DashboardController> {
  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final credentials = controller.validCredentials;
      final selectedMobile = controller.selectedBillAccountMobile.value;
      AccountCredential? selectedAccount = credentials.firstWhereOrNull((c) => c.mobile == selectedMobile);
      
      final labelStr = selectedAccount != null 
         ? (selectedAccount.remark?.trim().isNotEmpty == true ? selectedAccount.remark! : '尾号 ${selectedAccount.mobile.substring(selectedAccount.mobile.length - 4)}')
         : '请选择账号以查询账单';

      return Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: _AccountPickerTile(
              label: '查 询 账 号',
              value: labelStr,
              pointsText: selectedAccount != null ? '${selectedAccount.points} 积分' : null,
              onTap: () => _showAccountSelector(context, credentials, selectedMobile),
            ),
          ),
          Expanded(
            child: controller.isLoadingBills.value
                ? const Center(child: CircularProgressIndicator())
                : const _BillList(),
          ),
        ],
      );
    });
  }

  void _showAccountSelector(BuildContext context, List<AccountCredential> accounts, String? currentMobile) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
         final theme = Theme.of(context);
         return DraggableScrollableSheet(
            initialChildSize: 0.6,
            maxChildSize: 0.9,
            minChildSize: 0.4,
            expand: false,
            builder: (_, scrollController) => Container(
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
              ),
              padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
              child: Column(
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
                  Text('选择要核对账单的账号', style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800)),
                  const SizedBox(height: 16),
                  Expanded(
                    child: ListView.separated(
                       shrinkWrap: true,
                       controller: scrollController,
                       itemCount: accounts.length,
                       separatorBuilder: (context, index) => const SizedBox(height: 8),
                       itemBuilder: (context, index) {
                         final acc = accounts[index];
                         final isSelected = acc.mobile == currentMobile;
                         final accName = (acc.remark?.trim().isNotEmpty == true) ? acc.remark! : '尾号 ${acc.mobile.substring(acc.mobile.length - 4)}';
                         
                         return ListTile(
                            leading: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: isSelected ? theme.colorScheme.primaryContainer : theme.colorScheme.surfaceContainerHighest,
                                shape: BoxShape.circle,
                              ),
                              child: Icon(Icons.person, color: isSelected ? theme.colorScheme.onPrimaryContainer : theme.colorScheme.onSurfaceVariant),
                            ),
                            title: Text(accName, style: TextStyle(fontWeight: FontWeight.bold, color: isSelected ? theme.colorScheme.primary : null)),
                            subtitle: Text(acc.mobile),
                            trailing: Text('${acc.points} 积分', style: theme.textTheme.titleMedium?.copyWith(color: theme.colorScheme.secondary, fontWeight: FontWeight.bold)),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                            tileColor: isSelected ? theme.colorScheme.primaryContainer.withValues(alpha: 0.2) : theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
                            onTap: () {
                               controller.selectBillAccount(acc.mobile);
                               Navigator.of(context).pop();
                            }
                         );
                       }
                    )
                  )
                ]
              )
            )
         );
      }
    );
  }
}

class _AccountPickerTile extends StatelessWidget {
  const _AccountPickerTile({required this.label, required this.value, this.pointsText, required this.onTap});
  final String label;
  final String value;
  final String? pointsText;
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
                  color: theme.colorScheme.primary.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.account_balance_wallet_rounded, color: theme.colorScheme.primary, size: 28),
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
              if (pointsText != null) ...[
                const SizedBox(width: 4),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.secondary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    pointsText!,
                    style: theme.textTheme.labelLarge?.copyWith(
                      color: theme.colorScheme.secondary,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              ],
              const SizedBox(width: 8),
              Icon(Icons.keyboard_arrow_down_rounded, color: theme.dividerColor.withValues(alpha: 0.5)),
            ]
          )
        )
      )
    );
  }
}

class _BillList extends GetView<DashboardController> {
  const _BillList();

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final bills = controller.recentBills.toList(growable: false);
      if (bills.isEmpty) {
        return Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.receipt_long_outlined, size: 48, color: Theme.of(context).dividerColor),
              const SizedBox(height: 16),
              const Text('该账号暂无近期账单', style: TextStyle(color: Colors.grey)),
            ],
          ),
        );
      }

      return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
      itemCount: bills.length,
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
         final bill = bills[index];
         final theme = Theme.of(context);
         
         // 判定金额正负数（以颜色区分）
         final isIncome = bill.direction == 'IN' || bill.direction == '1' || bill.directionLabel.contains('入');
         final amountColor = isIncome ? Colors.green.shade600 : theme.colorScheme.error;
         final amountPrefix = isIncome ? '+' : '';
         
         return Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      bill.billTypeLabel,
                      style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
                    ),
                    Text(
                      '$amountPrefix${bill.amount}',
                      style: theme.textTheme.titleLarge?.copyWith(
                        color: amountColor,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      _formatDateTime(bill.createdAt),
                      style: theme.textTheme.labelMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                    ),
                    Text(
                      '当前余量: ${bill.totalAmount}',
                      style: theme.textTheme.labelMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                if (bill.remark?.trim().isNotEmpty == true) ...[
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      bill.remark!,
                      style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                    )
                  )
                ]
              ],
            )
         );
      }
    );
    });
  }

  String _formatDateTime(DateTime value) {
    final month = value.month.toString().padLeft(2, '0');
    final day = value.day.toString().padLeft(2, '0');
    final hour = value.hour.toString().padLeft(2, '0');
    final minute = value.minute.toString().padLeft(2, '0');
    return '$month-$day $hour:$minute';
  }
}

