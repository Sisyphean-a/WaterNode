import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:waternode/features/dashboard/application/dashboard_controller.dart';

class CredentialAutomationSection extends StatelessWidget {
  const CredentialAutomationSection({super.key, required this.controller});

  final DashboardController controller;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final isBusy = controller.isSigningIn.value || controller.isDrawing.value;
      return Wrap(
        spacing: 8,
        runSpacing: 8,
        children: [
          FilledButton.tonal(
            onPressed: isBusy ? null : controller.runBatchSignIn,
            child: const Text('签到'),
          ),
          FilledButton.tonal(
            onPressed: isBusy ? null : controller.runBatchLuckDraw,
            child: const Text('抽奖'),
          ),
        ],
      );
    });
  }
}
