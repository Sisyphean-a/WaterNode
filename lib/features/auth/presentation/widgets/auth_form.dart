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
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: mobileController,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(labelText: '手机号'),
              ),
            ),
            const SizedBox(width: 8),
            SizedBox(
              width: 140,
              child: OutlinedButton(
                onPressed: isSendingCode ? null : onSendCode,
                child: Text(isSendingCode ? '发送中' : '获取验证码'),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: codeController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: '验证码'),
              ),
            ),
            const SizedBox(width: 8),
            SizedBox(
              width: 140,
              child: FilledButton(
                onPressed: isLoggingIn ? null : onLogin,
                child: Text(isLoggingIn ? '提交中' : '保存账号'),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
