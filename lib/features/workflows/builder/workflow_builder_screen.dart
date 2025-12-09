import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:workflow_ai/core/models/node.dart';
import 'package:workflow_ai/core/models/connection.dart';
import 'package:workflow_ai/core/models/position.dart';
import 'package:workflow_ai/features/nodes/library/node_library_sheet.dart';
import 'package:workflow_ai/features/workflows/builder/workflow_builder_provider.dart';
import 'package:workflow_ai/features/workflows/builder/canvas/workflow_canvas.dart';
import 'package:workflow_ai/features/workflows/builder/canvas/canvas_controller.dart';
import 'package:workflow_ai/features/workflows/builder/nodes/node_config_sheet.dart';
import 'package:workflow_ai/features/execution/execution_screen.dart';

class WorkflowBuilderScreen extends ConsumerStatefulWidget {
  final String? workflowId;

  const WorkflowBuilderScreen({
    super.key,
    this.workflowId,
  });

  @override
  ConsumerState<WorkflowBuilderScreen> createState() =>
      _WorkflowBuilderScreenState();
}

class _WorkflowBuilderScreenState
    extends ConsumerState<WorkflowBuilderScreen> {
  late final CanvasController _canvasController;
  final TextEditingController _nameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _canvasController = CanvasController();
  }

  @override
  void dispose() {
    _canvasController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _saveWorkflow() async {
    await ref.read(workflowBuilderProvider(widget.workflowId).notifier)
        .saveWorkflow();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Workflow saved')),
      );
    }
  }

  void _openNodeLibrary() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => NodeLibrarySheet(
        onNodeSelected: (nodeDef) {
          final workflow = ref.read(workflowBuilderProvider(widget.workflowId));
          if (workflow == null) return;

          // Calculate position in center of visible area
          final newNode = nodeDef.createNode(
            position: Position(x: 300, y: 300),
          );

          ref.read(workflowBuilderProvider(widget.workflowId).notifier)
              .addNode(newNode);
        },
      ),
    );
  }

  void _onNodeTap(Node node) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => NodeConfigSheet(
        node: node,
        onSave: (updatedNode) {
          ref
              .read(workflowBuilderProvider(widget.workflowId).notifier)
              .updateNode(updatedNode);
        },
      ),
    );
  }

  void _onConnectionCreated(Connection connection) {
    ref
        .read(workflowBuilderProvider(widget.workflowId).notifier)
        .addConnection(connection);
  }

  void _onNodeMoved(String nodeId, double x, double y) {
    ref.read(workflowBuilderProvider(widget.workflowId).notifier)
        .moveNode(nodeId, x, y);
  }

  @override
  Widget build(BuildContext context) {
    final workflow = ref.watch(workflowBuilderProvider(widget.workflowId));

    // Initialize name controller if workflow is loaded
    if (workflow != null && _nameController.text.isEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && _nameController.text.isEmpty) {
          _nameController.text = workflow.name;
        }
      });
    }

    return Scaffold(
      appBar: AppBar(
        title: workflow != null
            ? TextField(
                controller: _nameController,
                style: TextStyle(
                  color: Theme.of(context).appBarTheme.foregroundColor ??
                      Theme.of(context).colorScheme.onSurface,
                ),
                decoration: InputDecoration(
                  border: InputBorder.none,
                  hintText: 'Workflow name',
                  hintStyle: TextStyle(
                    color: Theme.of(context).appBarTheme.foregroundColor
                        ?.withOpacity(0.6) ??
                        Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                  ),
                ),
                onChanged: (value) {
                  ref
                      .read(workflowBuilderProvider(widget.workflowId).notifier)
                      .updateWorkflowName(value);
                },
              )
            : const Text('Loading...'),
        actions: [
          IconButton(
            icon: const Icon(Icons.zoom_in),
            onPressed: () {
              _canvasController.updateScale(_canvasController.scale + 0.1);
            },
          ),
          IconButton(
            icon: const Icon(Icons.zoom_out),
            onPressed: () {
              _canvasController.updateScale(_canvasController.scale - 0.1);
            },
          ),
          IconButton(
            icon: const Icon(Icons.center_focus_strong),
            onPressed: () {
              _canvasController.reset();
            },
          ),
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _saveWorkflow,
          ),
        ],
      ),
      body: workflow == null
          ? const Center(child: CircularProgressIndicator())
          : Stack(
              children: [
                WorkflowCanvas(
                  nodes: workflow.nodes,
                  connections: workflow.connections,
                  onNodeTap: _onNodeTap,
                  onNodeMoved: _onNodeMoved,
                  onConnectionCreated: _onConnectionCreated,
                  controller: _canvasController,
                ),
                // Empty state instructions
                if (workflow.nodes.isEmpty)
                  Center(
                    child: Container(
                      padding: const EdgeInsets.all(24),
                      margin: const EdgeInsets.all(32),
                      decoration: BoxDecoration(
                        color: Theme.of(context).scaffoldBackgroundColor,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.work_outline,
                            size: 64,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Start Building Your Workflow',
                            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 16),
                          _InstructionStep(
                            number: 1,
                            icon: Icons.add_circle_outline,
                            title: 'Add Nodes',
                            description: 'Tap the + button to open the node library and add nodes to your workflow',
                          ),
                          const SizedBox(height: 12),
                          _InstructionStep(
                            number: 2,
                            icon: Icons.link,
                            title: 'Connect Nodes',
                            description: 'Tap a green (output) port and drag to a node card to connect them',
                          ),
                          const SizedBox(height: 12),
                          _InstructionStep(
                            number: 3,
                            icon: Icons.settings_outlined,
                            title: 'Configure Nodes',
                            description: 'Tap any node to configure its settings and parameters',
                          ),
                          const SizedBox(height: 12),
                          _InstructionStep(
                            number: 4,
                            icon: Icons.play_arrow,
                            title: 'Run Workflow',
                            description: 'Tap the play button to execute your workflow and see it in action',
                          ),
                          const SizedBox(height: 24),
                          ElevatedButton.icon(
                            onPressed: _openNodeLibrary,
                            icon: const Icon(Icons.add),
                            label: const Text('Add Your First Node'),
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 24,
                                vertical: 12,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                // Floating action buttons
                Positioned(
                  bottom: 16,
                  right: 16,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      FloatingActionButton(
                        heroTag: 'add_node',
                        onPressed: _openNodeLibrary,
                        child: const Icon(Icons.add),
                      ),
                      const SizedBox(height: 8),
                      FloatingActionButton(
                        heroTag: 'play',
                        onPressed: () {
                          if (workflow.nodes.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Add nodes to execute workflow'),
                              ),
                            );
                            return;
                          }
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ExecutionScreen(
                                workflow: workflow,
                              ),
                            ),
                          );
                        },
                        backgroundColor: Colors.green,
                        child: const Icon(Icons.play_arrow),
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}

class _InstructionStep extends StatelessWidget {
  final int number;
  final IconData icon;
  final String title;
  final String description;

  const _InstructionStep({
    required this.number,
    required this.icon,
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              '$number',
              style: TextStyle(
                color: Theme.of(context).colorScheme.primary,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    icon,
                    size: 18,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    title,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                description,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.grey.shade600,
                    ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

