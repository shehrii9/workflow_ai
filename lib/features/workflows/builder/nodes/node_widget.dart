import 'package:flutter/material.dart';
import 'package:workflow_ai/core/models/node.dart';
import 'package:workflow_ai/core/models/node_status.dart';
import 'package:workflow_ai/core/models/port.dart';

class NodeWidget extends StatelessWidget {
  final Node node;
  final double width = 200;
  final double height = 80;
  final Function(Port, bool)? onPortTap; // port, isOutput

  const NodeWidget({
    super.key,
    required this.node,
    this.onPortTap,
  });

  Color _getNodeColor() {
    switch (node.category) {
      case 'trigger':
        return Colors.green;
      case 'action':
        return Colors.blue;
      case 'logic':
        return Colors.orange;
      case 'data':
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }

  Color _getStatusColor() {
    switch (node.status) {
      case NodeStatus.idle:
        return Colors.grey.shade300;
      case NodeStatus.running:
        return Colors.blue;
      case NodeStatus.success:
        return Colors.green;
      case NodeStatus.error:
        return Colors.red;
      case NodeStatus.skipped:
        return Colors.orange.shade300;
    }
  }

  IconData _getNodeIcon() {
    switch (node.type) {
      case 'http':
        return Icons.http;
      case 'email':
        return Icons.email;
      case 'if':
        return Icons.code;
      case 'wait':
        return Icons.timer;
      case 'manual':
        return Icons.play_arrow;
      default:
        return Icons.circle;
    }
  }

  @override
  Widget build(BuildContext context) {
    final nodeColor = _getNodeColor();
    final statusColor = _getStatusColor();

    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: statusColor,
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: nodeColor.withOpacity(0.1),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(6),
                topRight: Radius.circular(6),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  _getNodeIcon(),
                  size: 20,
                  color: nodeColor,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    node.name,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: statusColor,
                    shape: BoxShape.circle,
                  ),
                ),
              ],
            ),
          ),
          // Body
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: Row(
                children: [
                  // Input ports
                  if (node.inputs.isNotEmpty)
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: node.inputs.map((port) {
                        return GestureDetector(
                          behavior: HitTestBehavior.opaque,
                          onTap: () {
                            onPortTap?.call(port, false);
                          },
                          child: Container(
                            width: 20,
                            height: 20,
                            margin: const EdgeInsets.only(bottom: 4),
                            decoration: BoxDecoration(
                              color: Colors.blue,
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 2),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  const Spacer(),
                  // Output ports
                  if (node.outputs.isNotEmpty)
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: node.outputs.map((port) {
                        return GestureDetector(
                          behavior: HitTestBehavior.opaque,
                          onTap: () {
                            onPortTap?.call(port, true);
                          },
                          child: Container(
                            width: 20,
                            height: 20,
                            margin: const EdgeInsets.only(bottom: 4),
                            decoration: BoxDecoration(
                              color: Colors.green,
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 2),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

