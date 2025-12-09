enum NodeStatus {
  idle,
  running,
  success,
  error,
  skipped,
}

extension NodeStatusExtension on NodeStatus {
  String get displayName {
    switch (this) {
      case NodeStatus.idle:
        return 'Idle';
      case NodeStatus.running:
        return 'Running';
      case NodeStatus.success:
        return 'Success';
      case NodeStatus.error:
        return 'Error';
      case NodeStatus.skipped:
        return 'Skipped';
    }
  }
}

