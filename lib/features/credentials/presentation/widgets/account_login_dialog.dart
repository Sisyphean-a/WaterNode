import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:waternode/features/auth/application/auth_controller.dart';

class AccountLoginDialog extends StatefulWidget {
  const AccountLoginDialog({super.key, required this.controller});

  final AuthController controller;

  @override
  State<AccountLoginDialog> createState() => _AccountLoginDialogState();
}

class _AccountLoginDialogState extends State<AccountLoginDialog> {
  late final TextEditingController _mobileController;
  late final TextEditingController _codeController;

  @override
  void initState() {
    super.initState();
    widget.controller.resetLoginState();
    _mobileController = TextEditingController();
    _codeController = TextEditingController();
  }

  @override
  void dispose() {
    _mobileController.dispose();
    _codeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 420),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Obx(
            () => Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  '新增账户',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 20),
                TextField(
                  controller: _mobileController,
                  keyboardType: TextInputType.phone,
                  decoration: const InputDecoration(labelText: '手机号'),
                ),
                const SizedBox(height: 12),
                FilledButton.tonal(
                  onPressed: widget.controller.isSendingCode.value
                      ? null
                      : () =>
                            widget.controller.sendCode(_mobileController.text),
                  child: Text(
                    widget.controller.isSendingCode.value ? '发送中' : '发送',
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _codeController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: '验证码'),
                ),
                const SizedBox(height: 12),
                FilledButton(
                  onPressed: widget.controller.isLoggingIn.value
                      ? null
                      : () => _submit(context),
                  child: Text(
                    widget.controller.isLoggingIn.value ? '登录中' : '登录',
                  ),
                ),
                if (widget.controller.lastError.value != null) ...[
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.errorContainer,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      widget.controller.lastError.value!,
                      style: TextStyle(
                        color: theme.colorScheme.onErrorContainer,
                      ),
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

  Future<void> _submit(BuildContext context) async {
    await widget.controller.login(
      mobile: _mobileController.text,
      smsCode: _codeController.text,
    );
    if (!context.mounted) {
      return;
    }
    Navigator.of(context).pop();
  }
}
