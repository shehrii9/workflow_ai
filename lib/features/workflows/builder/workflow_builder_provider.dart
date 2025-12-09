import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:workflow_ai/core/models/workflow.dart';
import 'package:workflow_ai/core/models/node.dart';
import 'package:workflow_ai/core/models/connection.dart';
import 'package:workflow_ai/core/services/storage_service.dart';
import 'package:workflow_ai/core/utils/uuid_helper.dart';

class WorkflowBuilderNotifier extends StateNotifier<Workflow?> {
  WorkflowBuilderNotifier(String? workflowId) : super(null) {
    if (workflowId != null) {
      loadWorkflow(workflowId);
    } else {
      // Create new workflow
      state = Workflow(
        id: UuidHelper.generate(),
        name: 'New Workflow',
      );
    }
  }

  Future<void> loadWorkflow(String id) async {
    final workflow = await StorageService.getWorkflow(id);
    state = workflow;
  }

  Future<void> saveWorkflow() async {
    if (state == null) return;
    await StorageService.saveWorkflow(state!);
  }

  void updateWorkflowName(String name) {
    if (state == null) return;
    state = state!.copyWith(name: name);
  }

  void updateWorkflowDescription(String? description) {
    if (state == null) return;
    state = state!.copyWith(description: description);
  }

  void addNode(Node node) {
    if (state == null) return;
    final nodes = List<Node>.from(state!.nodes)..add(node);
    state = state!.copyWith(nodes: nodes);
  }

  void updateNode(Node node) {
    if (state == null) return;
    final nodes = state!.nodes.map((n) => n.id == node.id ? node : n).toList();
    state = state!.copyWith(nodes: nodes);
  }

  void deleteNode(String nodeId) {
    if (state == null) return;
    final nodes = state!.nodes.where((n) => n.id != nodeId).toList();
    // Also remove connections involving this node
    final connections = state!.connections
        .where((c) =>
            c.sourceNodeId != nodeId && c.targetNodeId != nodeId)
        .toList();
    state = state!.copyWith(nodes: nodes, connections: connections);
  }

  void moveNode(String nodeId, double x, double y) {
    if (state == null) return;
    final nodes = state!.nodes.map((node) {
      if (node.id == nodeId) {
        return node.copyWith(
          position: node.position.copyWith(x: x, y: y),
        );
      }
      return node;
    }).toList();
    state = state!.copyWith(nodes: nodes);
  }

  void addConnection(Connection connection) {
    if (state == null) return;
    final connections = List<Connection>.from(state!.connections)..add(connection);
    state = state!.copyWith(connections: connections);
  }

  void deleteConnection(String connectionId) {
    if (state == null) return;
    final connections =
        state!.connections.where((c) => c.id != connectionId).toList();
    state = state!.copyWith(connections: connections);
  }
}

final workflowBuilderProvider =
    StateNotifierProvider.family<WorkflowBuilderNotifier, Workflow?, String?>(
  (ref, workflowId) => WorkflowBuilderNotifier(workflowId),
);

