enum ExecutionStatus {
  pending,
  running,
  completed,
  failed,
  cancelled,
}

extension ExecutionStatusExtension on ExecutionStatus {
  String get displayName {
    switch (this) {
      case ExecutionStatus.pending:
        return 'Pending';
      case ExecutionStatus.running:
        return 'Running';
      case ExecutionStatus.completed:
        return 'Completed';
      case ExecutionStatus.failed:
        return 'Failed';
      case ExecutionStatus.cancelled:
        return 'Cancelled';
    }
  }
}

