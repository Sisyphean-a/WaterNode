import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:waternode/app/routes/app_routes.dart';
import 'package:waternode/features/credentials/application/credential_controller.dart';
import 'package:waternode/features/credentials/presentation/widgets/credential_card.dart';

class CredentialPage extends GetView<CredentialController> {
  const CredentialPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Align(
            alignment: Alignment.centerRight,
            child: FilledButton.icon(
              onPressed: () => Get.offNamed<dynamic>(AppRoutes.auth),
              icon: const Icon(Icons.add_rounded),
              label: const Text('新增登录凭证'),
            ),
          ),
          if (controller.lastError.value != null) ...[
            const SizedBox(height: 12),
            Text(
              controller.lastError.value!,
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
          ],
          const SizedBox(height: 16),
          Expanded(
            child: RefreshIndicator(
              onRefresh: controller.refreshStatuses,
              child: ListView(
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
        ],
      ),
    );
  }
}
