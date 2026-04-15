import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:waternode/features/auth/application/auth_controller.dart';
import 'package:waternode/features/auth/presentation/widgets/auth_form.dart';

class AuthPage extends StatefulWidget {
  const AuthPage({super.key});

  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  final mobileController = TextEditingController();
  final codeController = TextEditingController();

  AuthController get controller => Get.find<AuthController>();

  @override
  void dispose() {
    mobileController.dispose();
    codeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('登录授权页')),
      body: Obx(
        () => Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              AuthForm(
                mobileController: mobileController,
                codeController: codeController,
                onSendCode: () => controller.sendCode(mobileController.text),
                onLogin: () async {
                  await controller.login(
                    mobile: mobileController.text,
                    smsCode: codeController.text,
                  );
                  if (mounted) {
                    Get.back<void>();
                  }
                },
                isSendingCode: controller.isSendingCode.value,
                isLoggingIn: controller.isLoggingIn.value,
              ),
              const SizedBox(height: 16),
              if (controller.lastError.value != null)
                Text(
                  controller.lastError.value!,
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
