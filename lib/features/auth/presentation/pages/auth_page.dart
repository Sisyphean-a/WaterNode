import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:waternode/app/routes/app_routes.dart';
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
    return Obx(
      () => Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 520),
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  AuthForm(
                    mobileController: mobileController,
                    codeController: codeController,
                    onSendCode: () =>
                        controller.sendCode(mobileController.text),
                    onLogin: () async {
                      await controller.login(
                        mobile: mobileController.text,
                        smsCode: codeController.text,
                      );
                      if (mounted) {
                        Get.offNamed<dynamic>(AppRoutes.credentials);
                      }
                    },
                    isSendingCode: controller.isSendingCode.value,
                    isLoggingIn: controller.isLoggingIn.value,
                  ),
                  const SizedBox(height: 16),
                  if (controller.lastError.value != null)
                    Text(
                      controller.lastError.value!,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.error,
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
