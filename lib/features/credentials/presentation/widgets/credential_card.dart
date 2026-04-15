import 'package:flutter/material.dart';
import 'package:waternode/features/credentials/domain/models/account_credential.dart';

class CredentialCard extends StatelessWidget {
  const CredentialCard({super.key, required this.credential});

  final AccountCredential credential;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
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
      child: Row(
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
              style: theme.textTheme.labelMedium?.copyWith(color: statusColor),
            ),
          ),
        ],
      ),
    );
  }
}
