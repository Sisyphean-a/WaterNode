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

    return Obx(
      () => ListView(
        children: [
          Row(
            children: [
              Expanded(
                child: SummaryPanel(
                  label: '账号总数',
                  value: '${controller.totalCount}',
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: SummaryPanel(
                  label: '总积分',
                  value: '${controller.totalPoints}',
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          WorkbenchSection(
            title: '核心取水区',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _SelectionField<String>(
                  fieldKey: const Key('workbench-account-select'),
                  label: '选择账号',
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
                const SizedBox(height: 10),
                _SelectionField<String>(
                  fieldKey: const Key('workbench-region-select'),
                  label: '选择区域',
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
                const SizedBox(height: 10),
                Text(
                  _buildStatusLine(deviceController),
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                if (deviceController.lastError.value != null) ...[
                  const SizedBox(height: 8),
                  Text(
                    deviceController.lastError.value!,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.error,
                    ),
                  ),
                ],
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    FilledButton(
                      onPressed: deviceController.isLoading.value
                          ? null
                          : () => deviceController.sendCommand(quantity: 1),
                      child: const Text('立即取水 7.5L'),
                    ),
                    FilledButton(
                      onPressed: deviceController.isLoading.value
                          ? null
                          : () => deviceController.sendCommand(quantity: 2),
                      child: const Text('立即取水 15L'),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          WorkbenchSection(
            title: '批量操作',
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                FilledButton.icon(
                  onPressed:
                      controller.isSigningIn.value || controller.isDrawing.value
                      ? null
                      : controller.runBatchSignIn,
                  icon: const Icon(Icons.fact_check_rounded),
                  label: Text(controller.isSigningIn.value ? '签到执行中' : '批量签到'),
                ),
                FilledButton.icon(
                  onPressed:
                      controller.isSigningIn.value || controller.isDrawing.value
                      ? null
                      : controller.runBatchLuckDraw,
                  icon: const Icon(Icons.casino_rounded),
                  label: Text(controller.isDrawing.value ? '抽奖执行中' : '批量抽奖'),
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
        ? '未选择账号'
        : _accountLabel(credential);
    final regionLabel = source?.name ?? '未选择区域';
    final stationLabel = station?.name ?? '当前区域暂无设备';
    return '当前账号：$accountLabel  当前区域：$regionLabel  当前设备：$stationLabel';
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
