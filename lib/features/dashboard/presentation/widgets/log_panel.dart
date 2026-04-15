import 'package:flutter/material.dart';
import 'package:waternode/features/dashboard/domain/models/task_log_entry.dart';

class LogPanel extends StatelessWidget {
  const LogPanel({super.key, required this.logs});

  final List<TaskLogEntry> logs;

  @override
  Widget build(BuildContext context) {
    if (logs.isEmpty) {
      return const Center(child: Text('暂无日志'));
    }

    return ListView.builder(
      itemCount: logs.length,
      itemBuilder: (context, index) {
        final entry = logs[index];
        final theme = Theme.of(context);

        return Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          decoration: BoxDecoration(
            color: theme.colorScheme.surfaceContainerHighest.withValues(
              alpha: 0.42,
            ),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  entry.message,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: entry.isError ? theme.colorScheme.error : null,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Text(
                _formatDateTime(entry.createdAt),
                style: theme.textTheme.labelSmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  String _formatDateTime(DateTime value) {
    final month = value.month.toString().padLeft(2, '0');
    final day = value.day.toString().padLeft(2, '0');
    final hour = value.hour.toString().padLeft(2, '0');
    final minute = value.minute.toString().padLeft(2, '0');
    final second = value.second.toString().padLeft(2, '0');
    return '${value.year}-$month-$day $hour:$minute:$second';
  }
}
