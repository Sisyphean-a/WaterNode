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
      () => Center(
        child: SingleChildScrollView(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480),
            child: WorkbenchSection(
              title: '绑定或新增账号',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    '请输入您的手机号与短信验证码以完成授权操作',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 24),
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
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.errorContainer,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.error_outline_rounded,
                            color: Theme.of(context).colorScheme.onErrorContainer,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              controller.lastError.value!,
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.onErrorContainer,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
