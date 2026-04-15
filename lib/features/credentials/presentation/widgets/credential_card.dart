import 'package:flutter/material.dart';
import 'package:waternode/features/credentials/domain/models/account_credential.dart';
import 'package:waternode/features/credentials/domain/models/account_sign_in_state.dart';

class CredentialCard extends StatefulWidget {
  const CredentialCard({
    super.key,
    required this.credential,
    required this.onSaveRemark,
  });

  final AccountCredential credential;
  final Future<void> Function(String remark) onSaveRemark;

  @override
  State<CredentialCard> createState() => _CredentialCardState();
}

class _CredentialCardState extends State<CredentialCard> {
  late final TextEditingController _remarkController;

  @override
  void initState() {
    super.initState();
    _remarkController = TextEditingController(text: widget.credential.remark);
  }

  @override
  void didUpdateWidget(covariant CredentialCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.credential.remark != widget.credential.remark) {
      _remarkController.text = widget.credential.remark ?? '';
    }
  }

  @override
  void dispose() {
    _remarkController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final credential = widget.credential;
    final statusColor = credential.isValid
        ? Colors.green.shade700
        : theme.colorScheme.error;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                flex: 3,
                child: Text(
                  credential.mobile,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Expanded(
                flex: 3,
                child: TextField(
                  controller: _remarkController,
                  decoration: const InputDecoration(
                    labelText: '备注',
                    isDense: true,
                  ),
                  onSubmitted: widget.onSaveRemark,
                ),
              ),
              Expanded(
                child: Text(
                  '${credential.points}',
                  textAlign: TextAlign.right,
                  style: theme.textTheme.bodyMedium,
                ),
              ),
              const SizedBox(width: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  credential.isValid ? '有效' : '失效',
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: statusColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            '签到状态：${_signInStateLabel(credential.signInState)}',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  String _signInStateLabel(AccountSignInState state) {
    switch (state) {
      case AccountSignInState.available:
        return '未签到';
      case AccountSignInState.completed:
        return '已签到';
      case AccountSignInState.success:
        return '本次签到成功';
      case AccountSignInState.failure:
        return '签到失败';
      case AccountSignInState.unknown:
        return '状态未知';
    }
  }
}
