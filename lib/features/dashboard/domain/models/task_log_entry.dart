class TaskLogEntry {
  const TaskLogEntry({
    required this.message,
    required this.createdAt,
    this.isError = false,
  });

  final String message;
  final DateTime createdAt;
  final bool isError;
}
