import 'package:workflow_ai/core/models/workflow.dart';
import 'package:workflow_ai/core/models/node.dart';
import 'package:workflow_ai/core/models/node_status.dart';
import 'package:workflow_ai/core/models/workflow_execution.dart';
import 'package:workflow_ai/core/models/node_execution.dart';
import 'package:workflow_ai/core/models/execution_status.dart';
import 'package:workflow_ai/core/utils/uuid_helper.dart';
import 'package:workflow_ai/features/execution/executors/executor_registry.dart';

class WorkflowExecutionEngine {
  final Function(String nodeId, NodeStatus status)? onNodeStatusChanged;
  final Function(String nodeId, Map<String, dynamic>? result)? onNodeResult;
  final Function(ExecutionStatus status)? onExecutionStatusChanged;

  WorkflowExecutionEngine({
    this.onNodeStatusChanged,
    this.onNodeResult,
    this.onExecutionStatusChanged,
  });

  /// Execute a workflow
  Future<WorkflowExecution> execute(Workflow workflow) async {
    final executionId = UuidHelper.generate();
    final execution = WorkflowExecution(
      id: executionId,
      workflowId: workflow.id,
      status: ExecutionStatus.running,
    );

    onExecutionStatusChanged?.call(ExecutionStatus.running);

    try {
      // Find trigger nodes (nodes with no inputs)
      final triggerNodes = workflow.nodes.where(
        (node) => node.inputs.isEmpty || node.category == 'trigger',
      ).toList();

      if (triggerNodes.isEmpty) {
        throw Exception('No trigger nodes found in workflow');
      }

      // Build execution graph
      final executionGraph = _buildExecutionGraph(workflow);

      // Execute starting from triggers
      final nodeExecutions = <String, NodeExecution>{};
      final nodeData = <String, Map<String, dynamic>>{};

      for (final trigger in triggerNodes) {
        await _executeNode(
          trigger,
          workflow,
          executionGraph,
          nodeExecutions,
          nodeData,
          {},
        );
      }

      // Update execution with results
      final completedExecution = execution.copyWith(
        status: ExecutionStatus.completed,
        completedAt: DateTime.now(),
        nodeExecutions: nodeExecutions,
      );

      onExecutionStatusChanged?.call(ExecutionStatus.completed);
      return completedExecution;
    } catch (e) {
      final failedExecution = execution.copyWith(
        status: ExecutionStatus.failed,
        completedAt: DateTime.now(),
        error: {'message': e.toString()},
      );

      onExecutionStatusChanged?.call(ExecutionStatus.failed);
      return failedExecution;
    }
  }

  /// Build execution graph (adjacency list)
  Map<String, List<String>> _buildExecutionGraph(Workflow workflow) {
    final graph = <String, List<String>>{};

    // Initialize graph
    for (final node in workflow.nodes) {
      graph[node.id] = [];
    }

    // Add edges based on connections
    for (final connection in workflow.connections) {
      if (!graph.containsKey(connection.sourceNodeId)) {
        graph[connection.sourceNodeId] = [];
      }
      graph[connection.sourceNodeId]!.add(connection.targetNodeId);
    }

    return graph;
  }

  /// Execute a single node
  Future<void> _executeNode(
    Node node,
    Workflow workflow,
    Map<String, List<String>> executionGraph,
    Map<String, NodeExecution> nodeExecutions,
    Map<String, Map<String, dynamic>> nodeData,
    Map<String, dynamic> inputData,
  ) async {
    // Check if already executed
    if (nodeExecutions.containsKey(node.id)) {
      return;
    }

    // Update status
    onNodeStatusChanged?.call(node.id, NodeStatus.running);
    final startTime = DateTime.now();

    try {
      // Get executor
      final executor = ExecutorRegistry.getExecutor(node.type);
      if (executor == null) {
        throw Exception('No executor found for node type: ${node.type}');
      }

      // Execute node
      final result = await executor.execute(node, inputData);

      // Store result
      nodeData[node.id] = result;

      final nodeExecution = NodeExecution(
        nodeId: node.id,
        status: NodeStatus.success,
        startedAt: startTime,
        completedAt: DateTime.now(),
        result: result,
      );

      nodeExecutions[node.id] = nodeExecution;
      onNodeStatusChanged?.call(node.id, NodeStatus.success);
      onNodeResult?.call(node.id, result);

      // Execute connected nodes
      final connectedNodeIds = executionGraph[node.id] ?? [];
      for (final connectedNodeId in connectedNodeIds) {
        final connectedNode = workflow.nodes.firstWhere(
          (n) => n.id == connectedNodeId,
        );

        // Check if all inputs are satisfied (for nodes with multiple inputs)
        if (_canExecuteNode(connectedNode, workflow, nodeExecutions)) {
          // Collect data from all input connections
          final connectedInputData = _collectInputData(
            connectedNode,
            workflow,
            nodeData,
          );

          await _executeNode(
            connectedNode,
            workflow,
            executionGraph,
            nodeExecutions,
            nodeData,
            connectedInputData,
          );
        }
      }
    } catch (e) {
      final nodeExecution = NodeExecution(
        nodeId: node.id,
        status: NodeStatus.error,
        startedAt: startTime,
        completedAt: DateTime.now(),
        error: e.toString(),
      );

      nodeExecutions[node.id] = nodeExecution;
      onNodeStatusChanged?.call(node.id, NodeStatus.error);
      throw e;
    }
  }

  /// Check if a node can be executed (all inputs satisfied)
  bool _canExecuteNode(
    Node node,
    Workflow workflow,
    Map<String, NodeExecution> nodeExecutions,
  ) {
    // If node has no inputs, it can always execute
    if (node.inputs.isEmpty) return true;

    // Check if all input connections have been executed
    final inputConnections = workflow.connections.where(
      (c) => c.targetNodeId == node.id,
    );

    for (final connection in inputConnections) {
      if (!nodeExecutions.containsKey(connection.sourceNodeId)) {
        return false;
      }
      final sourceExecution = nodeExecutions[connection.sourceNodeId]!;
      if (sourceExecution.status != NodeStatus.success) {
        return false;
      }
    }

    return true;
  }

  /// Collect input data from all connected nodes
  Map<String, dynamic> _collectInputData(
    Node node,
    Workflow workflow,
    Map<String, Map<String, dynamic>> nodeData,
  ) {
    final inputData = <String, dynamic>{};

    final inputConnections = workflow.connections.where(
      (c) => c.targetNodeId == node.id,
    );

    for (final connection in inputConnections) {
      final sourceData = nodeData[connection.sourceNodeId];
      if (sourceData != null) {
        // Merge data from all inputs
        inputData.addAll(sourceData);
      }
    }

    return inputData;
  }
}


