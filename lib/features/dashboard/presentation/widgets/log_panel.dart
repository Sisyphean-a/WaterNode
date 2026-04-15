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
        return ListTile(
          dense: true,
          title: Text(
            entry.message,
            style: TextStyle(
              color: entry.isError ? Theme.of(context).colorScheme.error : null,
            ),
          ),
          subtitle: Text(entry.createdAt.toIso8601String()),
        );
      },
    );
  }
}
