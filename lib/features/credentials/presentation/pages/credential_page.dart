import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:waternode/app/routes/app_routes.dart';
import 'package:waternode/features/credentials/application/credential_controller.dart';
import 'package:waternode/features/credentials/presentation/widgets/credential_card.dart';

class CredentialPage extends GetView<CredentialController> {
  const CredentialPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('凭证管理')),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Get.toNamed(AppRoutes.auth),
        child: const Icon(Icons.add),
      ),
      body: Obx(
        () => RefreshIndicator(
          onRefresh: controller.refreshStatuses,
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              for (final credential in controller.credentials)
                CredentialCard(credential: credential),
              if (controller.credentials.isEmpty)
                const Padding(
                  padding: EdgeInsets.only(top: 48),
                  child: Center(child: Text('暂无测试账号')),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
