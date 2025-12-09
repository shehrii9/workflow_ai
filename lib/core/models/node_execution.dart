import 'package:workflow_ai/core/models/node_status.dart';

class NodeExecution {
  final String nodeId;
  final NodeStatus status;
  final DateTime? startedAt;
  final DateTime? completedAt;
  final Map<String, dynamic>? result;
  final String? error;

  NodeExecution({
    required this.nodeId,
    this.status = NodeStatus.idle,
    this.startedAt,
    this.completedAt,
    this.result,
    this.error,
  });

  Map<String, dynamic> toJson() {
    return {
      'nodeId': nodeId,
      'status': status.name,
      'startedAt': startedAt?.toIso8601String(),
      'completedAt': completedAt?.toIso8601String(),
      'result': result,
      'error': error,
    };
  }

  factory NodeExecution.fromJson(Map<String, dynamic> json) {
    return NodeExecution(
      nodeId: json['nodeId'] as String,
      status: NodeStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => NodeStatus.idle,
      ),
      startedAt: json['startedAt'] != null
          ? DateTime.parse(json['startedAt'] as String)
          : null,
      completedAt: json['completedAt'] != null
          ? DateTime.parse(json['completedAt'] as String)
          : null,
      result: json['result'] as Map<String, dynamic>?,
      error: json['error'] as String?,
    );
  }
}

