import 'package:flutter/material.dart';
import 'package:waternode/features/credentials/domain/models/account_credential.dart';
import 'package:waternode/features/credentials/domain/models/account_sign_in_state.dart';

class CredentialCard extends StatefulWidget {
  const CredentialCard({
    super.key,
    required this.credential,
    required this.onSaveRemark,
    required this.onCopyToken,
  });

  final AccountCredential credential;
  final Future<void> Function(String remark) onSaveRemark;
  final Future<void> Function() onCopyToken;

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
        ? Colors.green.shade600
        : theme.colorScheme.error;

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: theme.dividerColor.withValues(alpha: 0.1),
        ),
        boxShadow: [
          BoxShadow(
            color: theme.shadowColor.withValues(alpha: 0.02),
            blurRadius: 12,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: theme.colorScheme.primaryContainer,
                  foregroundColor: theme.colorScheme.onPrimaryContainer,
                  child: const Icon(Icons.person_rounded),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        credential.mobile,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: statusColor.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              credential.isValid ? '状态有效' : '已失效',
                              style: theme.textTheme.labelSmall?.copyWith(
                                color: statusColor,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '打卡：${_signInStateLabel(credential.signInState)}',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '积分余额',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${credential.points}',
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w800,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),
            Divider(color: theme.dividerColor.withValues(alpha: 0.05)),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _remarkController,
                    decoration: const InputDecoration(
                      hintText: '添加备注名称...',
                      isDense: true,
                      border: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      filled: false,
                      contentPadding: EdgeInsets.zero,
                      prefixIcon: Icon(Icons.edit_note_rounded, size: 20),
                      prefixIconConstraints: BoxConstraints(minWidth: 28),
                    ),
                    style: theme.textTheme.bodyMedium,
                    onSubmitted: widget.onSaveRemark,
                  ),
                ),
                IconButton(
                  key: Key('copy-token-${credential.mobile}'),
                  onPressed: widget.onCopyToken,
                  tooltip: '提取 Token',
                  icon: const Icon(Icons.content_copy_rounded, size: 20),
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ],
            ),
          ],
        ),
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
        return '签到成功';
      case AccountSignInState.failure:
        return '异常';
      case AccountSignInState.unknown:
        return '未知';
    }
  }
}
