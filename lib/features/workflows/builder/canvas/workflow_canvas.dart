import 'package:flutter/material.dart';
import 'package:workflow_ai/core/models/node.dart';
import 'package:workflow_ai/core/models/connection.dart';
import 'package:workflow_ai/features/workflows/builder/canvas/canvas_controller.dart';
import 'package:workflow_ai/features/workflows/builder/nodes/draggable_node_widget.dart';
import 'package:workflow_ai/features/workflows/builder/connections/connection_painter.dart';
import 'package:workflow_ai/features/workflows/builder/connections/connection_creator.dart';

class WorkflowCanvas extends StatefulWidget {
  final List<Node> nodes;
  final List<Connection> connections;
  final Function(Node)? onNodeTap;
  final Function(String, double, double)? onNodeMoved;
  final Function(String, String, bool)? onPortTap; // nodeId, portId, isOutput
  final Function(Connection)? onConnectionCreated;
  final CanvasController controller;

  const WorkflowCanvas({
    super.key,
    required this.nodes,
    required this.connections,
    this.onNodeTap,
    this.onNodeMoved,
    this.onPortTap,
    this.onConnectionCreated,
    required this.controller,
  });

  @override
  State<WorkflowCanvas> createState() => _WorkflowCanvasState();
}

class _WorkflowCanvasState extends State<WorkflowCanvas> {
  static const double gridSize = 20.0;
  final ConnectionCreator _connectionCreator = ConnectionCreator();
  TempConnection? _tempConnection;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onScaleStart: _onScaleStart,
      onScaleUpdate: _onScaleUpdate,
      onScaleEnd: _onScaleEnd,
      child: InteractiveViewer(
        transformationController: widget.controller.transformationController,
        minScale: 0.1,
        maxScale: 3.0,
        boundaryMargin: const EdgeInsets.all(double.infinity),
        constrained: false,
        child: SizedBox(
          width: 10000,
          height: 10000,
          child: CustomPaint(
            painter: GridPainter(gridSize: gridSize),
            child: Stack(
              children: [
                // Draw connections first (behind nodes)
                CustomPaint(
                  painter: ConnectionPainter(
                    connections: widget.connections,
                    nodes: widget.nodes,
                    tempConnection: _tempConnection,
                  ),
                  size: const Size(10000, 10000),
                ),
              // Draw nodes on top
              ...widget.nodes.map((node) {
                return Positioned(
                  left: node.position.x,
                  top: node.position.y,
                  child: DraggableNodeWidget(
                    node: node,
                    onNodeTap: widget.onNodeTap,
                    onNodeMoved: widget.onNodeMoved,
                    onPortTap: (nodeId, portId) {
                      _handlePortTap(node, portId);
                    },
                  ),
                );
              }),
              // Gesture detector for temporary connection
              if (_connectionCreator.isConnecting)
                Positioned.fill(
                  child: GestureDetector(
                    behavior: HitTestBehavior.translucent,
                    onPanUpdate: (details) {
                      setState(() {
                        if (_connectionCreator.sourcePosition != null) {
                          // Transform local position to canvas coordinates
                          final canvasPosition = _toCanvasCoordinates(details.localPosition);
                          _tempConnection = TempConnection(
                            start: _connectionCreator.sourcePosition!,
                            end: canvasPosition,
                          );
                        }
                      });
                    },
                    onPanEnd: (details) {
                      // Try to complete connection if over a node or input port
                      final endPosition = _toCanvasCoordinates(details.localPosition);
                      
                      // First check if dropped on a port
                      final targetPort = _findPortAtPosition(endPosition);
                      
                      if (targetPort != null && targetPort['isOutput'] == false) {
                        // Connect to the specific port
                        final connection = _connectionCreator.completeConnection(
                          targetPort['nodeId'] as String,
                          targetPort['portId'] as String,
                          widget.nodes,
                        );
                        if (connection != null && widget.onConnectionCreated != null) {
                          widget.onConnectionCreated!(connection);
                        }
                        _connectionCreator.reset();
                        setState(() {
                          _tempConnection = null;
                        });
                      } else {
                        // Check if dropped on a node card
                        final targetNode = _findNodeAtPosition(endPosition);
                        if (targetNode != null && targetNode.inputs.isNotEmpty) {
                          // Connect to the first available input port
                          final firstInputPort = targetNode.inputs.first;
                          final connection = _connectionCreator.completeConnection(
                            targetNode.id,
                            firstInputPort.id,
                            widget.nodes,
                          );
                          if (connection != null && widget.onConnectionCreated != null) {
                            widget.onConnectionCreated!(connection);
                          }
                          _connectionCreator.reset();
                          setState(() {
                            _tempConnection = null;
                          });
                        } else {
                          // Cancel connection if not over a valid target
                          _connectionCreator.reset();
                          setState(() {
                            _tempConnection = null;
                          });
                        }
                      }
                    },
                    onTap: () {
                      // Cancel connection on tap
                      _connectionCreator.reset();
                      setState(() {
                        _tempConnection = null;
                      });
                    },
                    child: Container(color: Colors.transparent),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _onScaleStart(ScaleStartDetails details) {
    // Handle scale start if needed
  }

  void _onScaleUpdate(ScaleUpdateDetails details) {
    // The InteractiveViewer handles most of this, but we can add custom logic
  }

  void _onScaleEnd(ScaleEndDetails details) {
    // Handle scale end if needed
  }

  void _handlePortTap(Node node, String portId) {
    final isOutput = node.outputs.any((p) => p.id == portId);

    if (isOutput) {
      // Start connection from output port
      final portPosition = _getPortPosition(node, portId, true);
      _connectionCreator.startConnection(node.id, portId, portPosition);
      setState(() {
        _tempConnection = TempConnection(
          start: portPosition,
          end: portPosition,
        );
      });
    } else {
      // Complete connection to input port
      if (_connectionCreator.isConnecting) {
        final connection = _connectionCreator.completeConnection(
          node.id,
          portId,
          widget.nodes,
        );
        if (connection != null && widget.onConnectionCreated != null) {
          widget.onConnectionCreated!(connection);
        }
        _connectionCreator.reset();
        setState(() {
          _tempConnection = null;
        });
      }
    }
  }

  /// Convert local coordinates to canvas coordinates (accounting for zoom/pan)
  Offset _toCanvasCoordinates(Offset localPoint) {
    final matrix = widget.controller.transformationController.value;
    final inverted = Matrix4.inverted(matrix);
    return MatrixUtils.transformPoint(inverted, localPoint);
  }

  Map<String, dynamic>? _findPortAtPosition(Offset position) {
    const portHitRadius = 25.0; // Increased hit radius for easier connection
    
    for (final node in widget.nodes) {
      // Check input ports (blue)
      for (int i = 0; i < node.inputs.length; i++) {
        final portPosition = _getPortPosition(node, node.inputs[i].id, false);
        final distance = (position - portPosition).distance;
        if (distance < portHitRadius) {
          return {
            'nodeId': node.id,
            'portId': node.inputs[i].id,
            'isOutput': false,
          };
        }
      }
      
      // Check output ports (green) - but we don't want to connect output to output
      for (int i = 0; i < node.outputs.length; i++) {
        final portPosition = _getPortPosition(node, node.outputs[i].id, true);
        final distance = (position - portPosition).distance;
        if (distance < portHitRadius) {
          return {
            'nodeId': node.id,
            'portId': node.outputs[i].id,
            'isOutput': true,
          };
        }
      }
    }
    
    return null;
  }

  /// Find node at the given position (checking if position is within node bounds)
  Node? _findNodeAtPosition(Offset position) {
    const nodeWidth = 200.0;
    const nodeHeight = 80.0;
    
    for (final node in widget.nodes) {
      // Check if position is within node bounds
      if (position.dx >= node.position.x &&
          position.dx <= node.position.x + nodeWidth &&
          position.dy >= node.position.y &&
          position.dy <= node.position.y + nodeHeight) {
        return node;
      }
    }
    
    return null;
  }

  Offset _getPortPosition(Node node, String portId, bool isOutput) {
    final nodeWidth = 200.0;
    final nodeHeight = 80.0;
    final ports = isOutput ? node.outputs : node.inputs;
    final portIndex = ports.indexWhere((p) => p.id == portId);

    if (portIndex == -1) {
      return Offset(
        node.position.x + (isOutput ? nodeWidth : 0),
        node.position.y + nodeHeight / 2,
      );
    }

    final portSpacing = nodeHeight / (ports.length + 1);
    final portY = node.position.y + portSpacing * (portIndex + 1);

    return Offset(
      node.position.x + (isOutput ? nodeWidth : 0),
      portY,
    );
  }
}

class GridPainter extends CustomPainter {
  final double gridSize;

  GridPainter({required this.gridSize});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.grey.withOpacity(0.2)
      ..strokeWidth = 0.5;

    // Draw grid over a large virtual canvas area
    // This allows zooming out to see more of the canvas
    const virtualCanvasSize = 10000.0; // Large virtual canvas
    const startOffset = -virtualCanvasSize / 2;
    const endOffset = virtualCanvasSize / 2;

    // Draw vertical lines across the virtual canvas
    for (double x = startOffset; x <= endOffset; x += gridSize) {
      canvas.drawLine(
        Offset(x, startOffset),
        Offset(x, endOffset),
        paint,
      );
    }

    // Draw horizontal lines across the virtual canvas
    for (double y = startOffset; y <= endOffset; y += gridSize) {
      canvas.drawLine(
        Offset(startOffset, y),
        Offset(endOffset, y),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(GridPainter oldDelegate) => false;
}

