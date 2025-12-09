import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:workflow_ai/core/models/node.dart';
import 'package:workflow_ai/core/models/connection.dart';

class ConnectionPainter extends CustomPainter {
  final List<Connection> connections;
  final List<Node> nodes;
  final TempConnection? tempConnection;

  ConnectionPainter({
    required this.connections,
    required this.nodes,
    this.tempConnection,
  });

  Node? _findNode(String nodeId) {
    try {
      return nodes.firstWhere((node) => node.id == nodeId);
    } catch (e) {
      return null;
    }
  }

  Offset _getPortPosition(Node node, String portId, bool isOutput) {
    // Simple implementation: ports are on the left (input) or right (output) side
    final nodeWidth = 200.0;
    final nodeHeight = 80.0;

    // Find port index
    final ports = isOutput ? node.outputs : node.inputs;
    final portIndex = ports.indexWhere((p) => p.id == portId);

    if (portIndex == -1) {
      // Default position if port not found
      return Offset(
        node.position.x + (isOutput ? nodeWidth : 0),
        node.position.y + nodeHeight / 2,
      );
    }

    // Calculate port position
    final portSpacing = nodeHeight / (ports.length + 1);
    final portY = node.position.y + portSpacing * (portIndex + 1);

    return Offset(
      node.position.x + (isOutput ? nodeWidth : 0),
      portY,
    );
  }

  @override
  void paint(Canvas canvas, Size size) {
    // Draw temporary connection if exists
    if (tempConnection != null) {
      final tempPaint = Paint()
        ..color = Colors.blue.withOpacity(0.5)
        ..strokeWidth = 2
        ..style = PaintingStyle.stroke;

      final controlPoint1 = Offset(
        tempConnection!.start.dx + 50,
        tempConnection!.start.dy,
      );
      final controlPoint2 = Offset(
        tempConnection!.end.dx - 50,
        tempConnection!.end.dy,
      );

      final path = Path()
        ..moveTo(tempConnection!.start.dx, tempConnection!.start.dy)
        ..cubicTo(
          controlPoint1.dx,
          controlPoint1.dy,
          controlPoint2.dx,
          controlPoint2.dy,
          tempConnection!.end.dx,
          tempConnection!.end.dy,
        );

      canvas.drawPath(path, tempPaint);
    }

    final paint = Paint()
      ..color = Colors.grey.shade400
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    for (final connection in connections) {
      final sourceNode = _findNode(connection.sourceNodeId);
      final targetNode = _findNode(connection.targetNodeId);

      if (sourceNode == null || targetNode == null) {
        continue;
      }

      final startPoint = _getPortPosition(
        sourceNode,
        connection.sourcePortId,
        true, // output
      );

      final endPoint = _getPortPosition(
        targetNode,
        connection.targetPortId,
        false, // input
      );

        // Draw curved line (bezier curve)
        final controlPoint1 = Offset(
          startPoint.dx + 50,
          startPoint.dy,
        );
        final controlPoint2 = Offset(
          endPoint.dx - 50,
          endPoint.dy,
        );

        final path = Path()
          ..moveTo(startPoint.dx, startPoint.dy)
          ..cubicTo(
            controlPoint1.dx,
            controlPoint1.dy,
            controlPoint2.dx,
            controlPoint2.dy,
            endPoint.dx,
            endPoint.dy,
          );

        canvas.drawPath(path, paint);

        // Draw arrow at the end
        _drawArrow(canvas, endPoint, controlPoint2);
    }
  }

  void _drawArrow(Canvas canvas, Offset point, Offset direction) {
    final arrowSize = 8.0;
    final directionVector = direction - point;
    final angle = directionVector.direction;
    final cosAngle = math.cos(angle);
    final sinAngle = math.sin(angle);

    final path = Path()
      ..moveTo(point.dx, point.dy)
      ..lineTo(
        point.dx - arrowSize * (1 + 0.5 * cosAngle),
        point.dy - arrowSize * (1 + 0.5 * sinAngle),
      )
      ..lineTo(
        point.dx - arrowSize * (1 - 0.5 * cosAngle),
        point.dy - arrowSize * (1 - 0.5 * sinAngle),
      )
      ..close();

    canvas.drawPath(
      path,
      Paint()
        ..color = Colors.grey.shade400
        ..style = PaintingStyle.fill,
    );
  }

  @override
  bool shouldRepaint(ConnectionPainter oldDelegate) {
    return oldDelegate.connections != connections ||
        oldDelegate.nodes != nodes ||
        oldDelegate.tempConnection != tempConnection;
  }
}

class TempConnection {
  final Offset start;
  final Offset end;

  TempConnection({required this.start, required this.end});
}

