import 'package:flutter/material.dart';

class AuthForm extends StatelessWidget {
  const AuthForm({
    super.key,
    required this.mobileController,
    required this.codeController,
    required this.onSendCode,
    required this.onLogin,
    required this.isSendingCode,
    required this.isLoggingIn,
  });

  final TextEditingController mobileController;
  final TextEditingController codeController;
  final Future<void> Function() onSendCode;
  final Future<void> Function() onLogin;
  final bool isSendingCode;
  final bool isLoggingIn;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TextField(
          controller: mobileController,
          keyboardType: TextInputType.phone,
          decoration: const InputDecoration(labelText: '手机号'),
        ),
        const SizedBox(height: 16),
        TextField(
          controller: codeController,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(labelText: '验证码'),
        ),
        const SizedBox(height: 24),
        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: isSendingCode ? null : onSendCode,
                child: Text(isSendingCode ? '发送中...' : '获取验证码'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: FilledButton(
                onPressed: isLoggingIn ? null : onLogin,
                child: Text(isLoggingIn ? '登录中...' : '提交授权'),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
