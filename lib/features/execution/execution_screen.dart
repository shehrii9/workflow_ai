import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:workflow_ai/core/models/workflow.dart';
import 'package:workflow_ai/core/models/node.dart';
import 'package:workflow_ai/core/models/workflow_execution.dart';
import 'package:workflow_ai/core/models/node_execution.dart';
import 'package:workflow_ai/core/models/node_status.dart';
import 'package:workflow_ai/core/models/execution_status.dart';
import 'package:workflow_ai/features/execution/execution_provider.dart';

class ExecutionScreen extends ConsumerStatefulWidget {
  final Workflow workflow;

  const ExecutionScreen({
    super.key,
    required this.workflow,
  });

  @override
  ConsumerState<ExecutionScreen> createState() => _ExecutionScreenState();
}

class _ExecutionScreenState extends ConsumerState<ExecutionScreen> {
  @override
  void initState() {
    super.initState();
    // Auto-start execution
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(executionProvider.notifier).executeWorkflow(widget.workflow);
    });
  }

  @override
  Widget build(BuildContext context) {
    final execution = ref.watch(executionProvider);
    final isExecuting = ref.read(executionProvider.notifier).isExecuting;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Workflow Execution'),
        actions: [
          if (isExecuting)
            IconButton(
              icon: const Icon(Icons.stop),
              onPressed: () {
                ref.read(executionProvider.notifier).stopExecution();
              },
            ),
        ],
      ),
      body: execution == null
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Starting execution...'),
                ],
              ),
            )
          : _buildExecutionView(execution),
    );
  }

  Widget _buildExecutionView(WorkflowExecution execution) {
    return Column(
      children: [
        // Status header
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          color: _getStatusColor(execution.status).withOpacity(0.1),
          child: Column(
            children: [
              Row(
                children: [
                  Icon(
                    _getStatusIcon(execution.status),
                    color: _getStatusColor(execution.status),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    execution.status.displayName,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: _getStatusColor(execution.status),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                'Started: ${_formatTime(execution.startedAt)}',
                style: TextStyle(color: Colors.grey.shade600),
              ),
              if (execution.completedAt != null)
                Text(
                  'Completed: ${_formatTime(execution.completedAt!)}',
                  style: TextStyle(color: Colors.grey.shade600),
                ),
            ],
          ),
        ),
        // Error display
        if (execution.error != null)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            color: Colors.red.shade50,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Error:',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.red,
                  ),
                ),
                const SizedBox(height: 4),
                Text(execution.error!['message'] ?? 'Unknown error'),
              ],
            ),
          ),
        // Node execution list
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: widget.workflow.nodes.length,
            itemBuilder: (context, index) {
              final node = widget.workflow.nodes[index];
              final nodeExecution = execution.nodeExecutions[node.id];

              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: _getNodeStatusColor(
                      nodeExecution?.status ?? NodeStatus.idle,
                    ),
                    child: Icon(
                      _getNodeStatusIcon(
                        nodeExecution?.status ?? NodeStatus.idle,
                      ),
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                  title: Text(node.name),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Type: ${node.type}'),
                      if (nodeExecution != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          'Status: ${nodeExecution.status.displayName}',
                          style: TextStyle(
                            color: _getNodeStatusColor(nodeExecution.status),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        if (nodeExecution.error != null)
                          Text(
                            'Error: ${nodeExecution.error}',
                            style: const TextStyle(color: Colors.red),
                          ),
                      ],
                    ],
                  ),
                  trailing: nodeExecution != null
                      ? IconButton(
                          icon: const Icon(Icons.info_outline),
                          onPressed: () {
                            _showNodeDetails(context, node, nodeExecution);
                          },
                        )
                      : null,
                ),
              );
            },
          ),
        ),
        // Action buttons
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () {
                    ref.read(executionProvider.notifier).clearExecution();
                    Navigator.pop(context);
                  },
                  child: const Text('Close'),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    ref.read(executionProvider.notifier)
                        .executeWorkflow(widget.workflow);
                  },
                  child: const Text('Run Again'),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _showNodeDetails(
    BuildContext context,
    Node node,
    NodeExecution nodeExecution,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(node.name),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Status: ${nodeExecution.status.displayName}'),
              if (nodeExecution.startedAt != null)
                Text('Started: ${_formatTime(nodeExecution.startedAt!)}'),
              if (nodeExecution.completedAt != null)
                Text('Completed: ${_formatTime(nodeExecution.completedAt!)}'),
              if (nodeExecution.result != null) ...[
                const SizedBox(height: 8),
                const Text(
                  'Result:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    nodeExecution.result.toString(),
                    style: const TextStyle(fontSize: 12),
                  ),
                ),
              ],
              if (nodeExecution.error != null) ...[
                const SizedBox(height: 8),
                Text(
                  'Error: ${nodeExecution.error}',
                  style: const TextStyle(color: Colors.red),
                ),
              ],
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(ExecutionStatus status) {
    switch (status) {
      case ExecutionStatus.pending:
        return Colors.grey;
      case ExecutionStatus.running:
        return Colors.blue;
      case ExecutionStatus.completed:
        return Colors.green;
      case ExecutionStatus.failed:
        return Colors.red;
      case ExecutionStatus.cancelled:
        return Colors.orange;
    }
  }

  IconData _getStatusIcon(ExecutionStatus status) {
    switch (status) {
      case ExecutionStatus.pending:
        return Icons.hourglass_empty;
      case ExecutionStatus.running:
        return Icons.play_circle;
      case ExecutionStatus.completed:
        return Icons.check_circle;
      case ExecutionStatus.failed:
        return Icons.error;
      case ExecutionStatus.cancelled:
        return Icons.cancel;
    }
  }

  Color _getNodeStatusColor(NodeStatus status) {
    switch (status) {
      case NodeStatus.idle:
        return Colors.grey;
      case NodeStatus.running:
        return Colors.blue;
      case NodeStatus.success:
        return Colors.green;
      case NodeStatus.error:
        return Colors.red;
      case NodeStatus.skipped:
        return Colors.orange;
    }
  }

  IconData _getNodeStatusIcon(NodeStatus status) {
    switch (status) {
      case NodeStatus.idle:
        return Icons.radio_button_unchecked;
      case NodeStatus.running:
        return Icons.refresh;
      case NodeStatus.success:
        return Icons.check;
      case NodeStatus.error:
        return Icons.error;
      case NodeStatus.skipped:
        return Icons.skip_next;
    }
  }

  String _formatTime(DateTime time) {
    return '${time.hour.toString().padLeft(2, '0')}:'
        '${time.minute.toString().padLeft(2, '0')}:'
        '${time.second.toString().padLeft(2, '0')}';
  }
}

