import 'package:flutter/material.dart';
import 'package:waternode/features/credentials/domain/models/account_credential.dart';
import 'package:waternode/features/credentials/domain/models/account_sign_in_state.dart';

class CredentialCard extends StatelessWidget {
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
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final statusColor = credential.isValid
        ? Colors.green.shade600
        : theme.colorScheme.error;

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: theme.dividerColor.withValues(alpha: 0.1)),
        boxShadow: [
          BoxShadow(
            color: theme.shadowColor.withValues(alpha: 0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _showOptionsSheet(context),
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            child: Row(
              children: [
                // Start Avatar
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    credential.isValid ? Icons.person_rounded : Icons.person_off_rounded,
                    color: statusColor,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 14),
                // Center Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        credential.mobile,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              _buildSubtitle(),
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                // End Points
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '${credential.points}',
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w800,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: statusColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        credential.isValid ? '状态有效' : '已失效',
                        style: theme.textTheme.labelSmall?.copyWith(color: statusColor, fontSize: 10),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _buildSubtitle() {
    final remark = (credential.remark?.isNotEmpty == true) ? credential.remark! : '未命名账号';
    final signState = _signInStateLabel(credential.signInState);
    return '$remark • 打卡: $signState';
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

  void _showOptionsSheet(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _OptionsSheet(
        credential: credential,
        onSaveRemark: onSaveRemark,
        onCopyToken: onCopyToken,
      ),
    );
  }
}

class _OptionsSheet extends StatefulWidget {
  const _OptionsSheet({
    required this.credential,
    required this.onSaveRemark,
    required this.onCopyToken,
  });

  final AccountCredential credential;
  final Future<void> Function(String) onSaveRemark;
  final Future<void> Function() onCopyToken;

  @override
  State<_OptionsSheet> createState() => _OptionsSheetState();
}

class _OptionsSheetState extends State<_OptionsSheet> {
  late final TextEditingController _remarkController;

  @override
  void initState() {
    super.initState();
    _remarkController = TextEditingController(text: widget.credential.remark);
  }

  @override
  void dispose() {
    _remarkController.dispose();
    super.dispose();
  }

  Future<void> _handleSave(BuildContext context) async {
    final nav = Navigator.of(context);
    await widget.onSaveRemark(_remarkController.text);
    if (mounted) nav.pop();
  }

  void _handleCopy(BuildContext context) {
    widget.onCopyToken();
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
      child: Container(
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: theme.dividerColor.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              '管理通行证',
              style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 8),
            Text(
              widget.credential.mobile,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 24),
            TextField(
              controller: _remarkController,
              decoration: InputDecoration(
                labelText: '备注名称',
                hintText: '输入别名以便于区分',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                prefixIcon: const Icon(Icons.edit_note_rounded),
                filled: true,
              ),
              textInputAction: TextInputAction.done,
              onSubmitted: (_) => _handleSave(context),
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: () => _handleSave(context),
              icon: const Icon(Icons.save_rounded),
              label: const Text('保存修改'),
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: () => _handleCopy(context),
              icon: const Icon(Icons.content_copy_rounded),
              label: const Text('复制 Token'),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
