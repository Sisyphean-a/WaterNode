import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:waternode/features/credentials/application/credential_controller.dart';
import 'package:waternode/features/dashboard/application/dashboard_controller.dart';
import 'package:waternode/features/dashboard/presentation/widgets/dispatch_workbench_section.dart';
import 'package:waternode/features/dashboard/presentation/widgets/summary_panel.dart';
import 'package:waternode/features/devices/application/device_controller.dart';

class DashboardPage extends GetView<DashboardController> {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    final credentialController = Get.find<CredentialController>();
    final deviceController = Get.find<DeviceController>();

    return Obx(() {
      final totalCount = credentialController.credentials.length;
      final totalPoints = credentialController.credentials.fold<int>(
        0,
        (sum, item) => sum + item.points,
      );
      return ListView(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: SummaryPanel(label: '有效账号数', value: '$totalCount'),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: SummaryPanel(label: '总可用积分', value: '$totalPoints'),
              ),
            ],
          ),
          const SizedBox(height: 16),
          DispatchWorkbenchSection(
            credentialController: credentialController,
            deviceController: deviceController,
          ),
        ],
      );
    });
  }
}
