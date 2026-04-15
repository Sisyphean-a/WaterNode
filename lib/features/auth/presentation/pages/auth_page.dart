import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:waternode/app/application/console_shell_controller.dart';
import 'package:waternode/app/presentation/widgets/workbench_section.dart';
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
  ConsoleShellController get shell => Get.find<ConsoleShellController>();

  @override
  void dispose() {
    mobileController.dispose();
    codeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => Align(
        alignment: Alignment.topLeft,
        child: SizedBox(
          width: 520,
          child: WorkbenchSection(
            title: '登录授权',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
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
                      shell.selectRoute(AppRoutes.credentials);
                    }
                  },
                  isSendingCode: controller.isSendingCode.value,
                  isLoggingIn: controller.isLoggingIn.value,
                ),
                if (controller.lastError.value != null) ...[
                  const SizedBox(height: 10),
                  Text(
                    controller.lastError.value!,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.error,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
