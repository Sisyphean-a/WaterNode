import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:waternode/app/presentation/widgets/workbench_section.dart';
import 'package:waternode/features/dashboard/application/dashboard_controller.dart';
import 'package:waternode/features/dashboard/presentation/widgets/log_panel.dart';
import 'package:waternode/features/devices/application/device_controller.dart';

class TaskCenterPage extends GetView<DashboardController> {
  const TaskCenterPage({super.key});

  @override
  Widget build(BuildContext context) {
    final deviceController = Get.find<DeviceController>();

    return Obx(
      () => ListView(
        children: [
          WorkbenchSection(
            title: '最近操作记录',
            child: SizedBox(
              height: 240,
              child: LogPanel(logs: controller.logs),
            ),
          ),
          const SizedBox(height: 10),
          WorkbenchSection(
            title: '取水记录',
            child: SizedBox(
              height: 180,
              child: LogPanel(logs: deviceController.logs),
            ),
          ),
          const SizedBox(height: 10),
          WorkbenchSection(
            title: '账单核对',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                DropdownButtonFormField<String>(
                  key: const Key('bill-account-select'),
                  initialValue: controller.selectedBillAccountMobile.value,
                  decoration: const InputDecoration(labelText: '账单账号'),
                  items: controller.validCredentials
                      .map(
                        (item) => DropdownMenuItem<String>(
                          value: item.mobile,
                          child: Text(item.remark ?? item.mobile),
                        ),
                      )
                      .toList(growable: false),
                  onChanged: controller.selectBillAccount,
                ),
                const SizedBox(height: 10),
                if (controller.isLoadingBills.value)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 20),
                    child: Center(child: CircularProgressIndicator()),
                  )
                else
                  _BillList(controller: controller),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _BillList extends StatelessWidget {
  const _BillList({required this.controller});

  final DashboardController controller;

  @override
  Widget build(BuildContext context) {
    if (controller.recentBills.isEmpty) {
      return const Text('暂无账单记录');
    }

    return Column(
      children: controller.recentBills
          .map(
            (bill) => Container(
              width: double.infinity,
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Theme.of(
                  context,
                ).colorScheme.surfaceContainerHighest.withValues(alpha: 0.42),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('${bill.billTypeLabel} · ${bill.directionLabel}'),
                  const SizedBox(height: 4),
                  Text(
                    _formatDateTime(bill.createdAt),
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  const SizedBox(height: 4),
                  Text('变动 ${bill.amount}，变化后总积分 ${bill.totalAmount}'),
                  if (bill.remark != null && bill.remark!.isNotEmpty)
                    Text(bill.remark!),
                ],
              ),
            ),
          )
          .toList(growable: false),
    );
  }

  String _formatDateTime(DateTime value) {
    final month = value.month.toString().padLeft(2, '0');
    final day = value.day.toString().padLeft(2, '0');
    final hour = value.hour.toString().padLeft(2, '0');
    final minute = value.minute.toString().padLeft(2, '0');
    final second = value.second.toString().padLeft(2, '0');
    return '${value.year}-$month-$day $hour:$minute:$second';
  }
}
