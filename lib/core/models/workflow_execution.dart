import 'package:workflow_ai/core/models/execution_status.dart';
import 'package:workflow_ai/core/models/node_execution.dart';

class WorkflowExecution {
  final String id;
  final String workflowId;
  final ExecutionStatus status;
  final DateTime startedAt;
  final DateTime? completedAt;
  final Map<String, NodeExecution> nodeExecutions;
  final Map<String, dynamic>? error;

  WorkflowExecution({
    required this.id,
    required this.workflowId,
    this.status = ExecutionStatus.pending,
    DateTime? startedAt,
    this.completedAt,
    this.nodeExecutions = const {},
    this.error,
  }) : startedAt = startedAt ?? DateTime.now();

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'workflowId': workflowId,
      'status': status.name,
      'startedAt': startedAt.toIso8601String(),
      'completedAt': completedAt?.toIso8601String(),
      'nodeExecutions': nodeExecutions.map(
        (key, value) => MapEntry(key, value.toJson()),
      ),
      'error': error,
    };
  }

  factory WorkflowExecution.fromJson(Map<String, dynamic> json) {
    final nodeExecutionsMap = json['nodeExecutions'] as Map<String, dynamic>?;
    return WorkflowExecution(
      id: json['id'] as String,
      workflowId: json['workflowId'] as String,
      status: ExecutionStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => ExecutionStatus.pending,
      ),
      startedAt: DateTime.parse(json['startedAt'] as String),
      completedAt: json['completedAt'] != null
          ? DateTime.parse(json['completedAt'] as String)
          : null,
      nodeExecutions: nodeExecutionsMap?.map(
            (key, value) => MapEntry(
              key,
              NodeExecution.fromJson(value as Map<String, dynamic>),
            ),
          ) ??
          {},
      error: json['error'] as Map<String, dynamic>?,
    );
  }

  WorkflowExecution copyWith({
    String? id,
    String? workflowId,
    ExecutionStatus? status,
    DateTime? startedAt,
    DateTime? completedAt,
    Map<String, NodeExecution>? nodeExecutions,
    Map<String, dynamic>? error,
  }) {
    return WorkflowExecution(
      id: id ?? this.id,
      workflowId: workflowId ?? this.workflowId,
      status: status ?? this.status,
      startedAt: startedAt ?? this.startedAt,
      completedAt: completedAt ?? this.completedAt,
      nodeExecutions: nodeExecutions ?? this.nodeExecutions,
      error: error ?? this.error,
    );
  }
}

