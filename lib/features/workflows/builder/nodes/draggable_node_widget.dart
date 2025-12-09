import 'package:flutter/material.dart';
import 'package:workflow_ai/core/models/node.dart';
import 'package:workflow_ai/features/workflows/builder/nodes/node_widget.dart';

class DraggableNodeWidget extends StatefulWidget {
  final Node node;
  final Function(Node)? onNodeTap;
  final Function(String, double, double)? onNodeMoved;
  final Function(String, String)? onPortTap; // nodeId, portId

  const DraggableNodeWidget({
    super.key,
    required this.node,
    this.onNodeTap,
    this.onNodeMoved,
    this.onPortTap,
  });

  @override
  State<DraggableNodeWidget> createState() => _DraggableNodeWidgetState();
}

class _DraggableNodeWidgetState extends State<DraggableNodeWidget> {
  Offset _dragOffset = Offset.zero;
  bool _isDragging = false;

  @override
  void didUpdateWidget(DraggableNodeWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Reset drag offset if node position changed externally
    if (oldWidget.node.position != widget.node.position && !_isDragging) {
      _dragOffset = Offset.zero;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Transform.translate(
      offset: _dragOffset,
      child: GestureDetector(
        behavior: HitTestBehavior.deferToChild,
        onTap: () => widget.onNodeTap?.call(widget.node),
        onPanStart: (details) {
          setState(() {
            _isDragging = true;
            _dragOffset = Offset.zero;
          });
        },
        onPanUpdate: (details) {
          // Update local offset for smooth visual dragging
          setState(() {
            _dragOffset = _dragOffset + details.delta;
          });
        },
        onPanEnd: (details) {
          // Update actual node position only when drag ends
          if (widget.onNodeMoved != null) {
            final newX = widget.node.position.x + _dragOffset.dx;
            final newY = widget.node.position.y + _dragOffset.dy;
            widget.onNodeMoved!(widget.node.id, newX, newY);
          }
          setState(() {
            _isDragging = false;
            _dragOffset = Offset.zero;
          });
        },
        onPanCancel: () {
          // Cancel drag if interrupted
          setState(() {
            _isDragging = false;
            _dragOffset = Offset.zero;
          });
        },
        child: NodeWidget(
          node: widget.node,
          onPortTap: (port, isOutput) {
            widget.onPortTap?.call(widget.node.id, port.id);
          },
        ),
      ),
    );
  }
}

