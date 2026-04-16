import 'package:flutter/material.dart';
import 'package:waternode/features/dashboard/domain/models/task_log_entry.dart';

class LogPanel extends StatelessWidget {
  const LogPanel({super.key, required this.logs});

  final List<TaskLogEntry> logs;

  @override
  Widget build(BuildContext context) {
    if (logs.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.feed_outlined, size: 48, color: Theme.of(context).dividerColor),
            const SizedBox(height: 16),
            const Text('暂无历史操作数据', style: TextStyle(color: Colors.grey)),
          ],
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      itemCount: logs.length,
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final entry = logs[index];
        final theme = Theme.of(context);
        final isError = entry.isError;
        
        final iconColor = isError ? theme.colorScheme.error : theme.colorScheme.primary;
        final iconData = isError ? Icons.warning_amber_rounded : Icons.check_circle_outline_rounded;
        final bgColor = isError 
            ? theme.colorScheme.errorContainer.withValues(alpha: 0.2)
            : theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3);

        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(16),
            border: isError ? Border.all(color: theme.colorScheme.error.withValues(alpha: 0.3)) : null,
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(iconData, color: iconColor, size: 24),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      entry.message,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: isError ? theme.colorScheme.error : theme.colorScheme.onSurface,
                        fontWeight: isError ? FontWeight.w600 : FontWeight.w500,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _formatDateTime(entry.createdAt),
                      style: theme.textTheme.labelMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
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
    return '$month-$day $hour:$minute:$second';
  }
}
