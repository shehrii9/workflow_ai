import 'package:flutter/material.dart';
import 'package:workflow_ai/core/models/node.dart';
import 'package:workflow_ai/core/models/connection.dart';
import 'package:workflow_ai/core/utils/uuid_helper.dart';

class ConnectionCreator {
  String? sourceNodeId;
  String? sourcePortId;
  Offset? sourcePosition;

  void startConnection(String nodeId, String portId, Offset position) {
    sourceNodeId = nodeId;
    sourcePortId = portId;
    sourcePosition = position;
  }

  Connection? completeConnection(
    String targetNodeId,
    String targetPortId,
    List<Node> nodes,
  ) {
    if (sourceNodeId == null || sourcePortId == null) {
      return null;
    }

    // Validate connection
    final sourceNode = nodes.firstWhere(
      (n) => n.id == sourceNodeId,
      orElse: () => throw Exception('Source node not found'),
    );

    final targetNode = nodes.firstWhere(
      (n) => n.id == targetNodeId,
      orElse: () => throw Exception('Target node not found'),
    );

    // Validate source port is an output
    sourceNode.outputs.firstWhere(
      (p) => p.id == sourcePortId,
      orElse: () => throw Exception('Source port not found or not an output'),
    );

    // Validate target port is an input
    targetNode.inputs.firstWhere(
      (p) => p.id == targetPortId,
      orElse: () => throw Exception('Target port not found or not an input'),
    );

    // Create connection
    final connection = Connection(
      id: UuidHelper.generate(),
      sourceNodeId: sourceNodeId!,
      sourcePortId: sourcePortId!,
      targetNodeId: targetNodeId,
      targetPortId: targetPortId,
    );

    reset();
    return connection;
  }

  void reset() {
    sourceNodeId = null;
    sourcePortId = null;
    sourcePosition = null;
  }

  bool get isConnecting => sourceNodeId != null;
}

