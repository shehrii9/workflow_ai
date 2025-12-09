import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:workflow_ai/core/models/workflow.dart';
import 'package:workflow_ai/core/models/workflow_execution.dart';
import 'package:workflow_ai/core/models/node_execution.dart';
import 'package:workflow_ai/core/models/node_status.dart';
import 'package:workflow_ai/core/models/execution_status.dart';
import 'package:workflow_ai/features/execution/workflow_execution_engine.dart';

class ExecutionNotifier extends StateNotifier<WorkflowExecution?> {
  ExecutionNotifier() : super(null);

  WorkflowExecutionEngine? _engine;
  bool _isExecuting = false;
  final Map<String, NodeStatus> _nodeStatuses = {};
  final Map<String, Map<String, dynamic>> _nodeResults = {};

  bool get isExecuting => _isExecuting;
  Map<String, NodeStatus> get nodeStatuses => Map.unmodifiable(_nodeStatuses);
  Map<String, Map<String, dynamic>> get nodeResults =>
      Map.unmodifiable(_nodeResults);

  Future<void> executeWorkflow(Workflow workflow) async {
    if (_isExecuting) return;

    _isExecuting = true;
    _nodeStatuses.clear();
    _nodeResults.clear();
    state = null;

    _engine = WorkflowExecutionEngine(
      onNodeStatusChanged: (nodeId, status) {
        _nodeStatuses[nodeId] = status;
        // Create a temporary execution state for real-time updates
        if (state != null) {
          final updatedExecutions = Map<String, NodeExecution>.from(
            state!.nodeExecutions,
          );
          // Update or create node execution
          if (updatedExecutions.containsKey(nodeId)) {
            final existing = updatedExecutions[nodeId]!;
            updatedExecutions[nodeId] = NodeExecution(
              nodeId: nodeId,
              status: status,
              startedAt: existing.startedAt,
              completedAt: status == NodeStatus.success ||
                      status == NodeStatus.error
                  ? DateTime.now()
                  : null,
              result: existing.result,
              error: existing.error,
            );
          } else {
            updatedExecutions[nodeId] = NodeExecution(
              nodeId: nodeId,
              status: status,
              startedAt: DateTime.now(),
            );
          }
          state = state!.copyWith(nodeExecutions: updatedExecutions);
        }
      },
      onNodeResult: (nodeId, result) {
        if (result != null) {
          _nodeResults[nodeId] = result;
        }
        if (state != null) {
          final updatedExecutions = Map<String, NodeExecution>.from(
            state!.nodeExecutions,
          );
          if (updatedExecutions.containsKey(nodeId)) {
            final existing = updatedExecutions[nodeId]!;
            updatedExecutions[nodeId] = NodeExecution(
              nodeId: nodeId,
              status: existing.status,
              startedAt: existing.startedAt,
              completedAt: existing.completedAt,
              result: result,
              error: existing.error,
            );
            state = state!.copyWith(nodeExecutions: updatedExecutions);
          }
        }
      },
      onExecutionStatusChanged: (status) {
        if (state != null) {
          state = state!.copyWith(status: status);
        }
      },
    );

    try {
      final execution = await _engine!.execute(workflow);
      state = execution;
    } catch (e) {
      state = WorkflowExecution(
        id: '',
        workflowId: workflow.id,
        status: ExecutionStatus.failed,
        error: {'message': e.toString()},
      );
    } finally {
      _isExecuting = false;
    }
  }

  void stopExecution() {
    // TODO: Implement cancellation
    _isExecuting = false;
  }

  void clearExecution() {
    state = null;
  }
}

final executionProvider =
    StateNotifierProvider<ExecutionNotifier, WorkflowExecution?>(
  (ref) => ExecutionNotifier(),
);

