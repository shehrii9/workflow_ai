import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:workflow_ai/core/models/workflow.dart';
import 'package:workflow_ai/core/utils/uuid_helper.dart';
import 'package:workflow_ai/core/services/storage_service.dart';
import 'package:workflow_ai/features/workflows/list/workflows_list_provider.dart';
import 'package:workflow_ai/features/workflows/builder/workflow_builder_screen.dart';

class WorkflowsListScreen extends ConsumerStatefulWidget {
  const WorkflowsListScreen({super.key});

  @override
  ConsumerState<WorkflowsListScreen> createState() =>
      _WorkflowsListScreenState();
}

class _WorkflowsListScreenState extends ConsumerState<WorkflowsListScreen> {
  @override
  Widget build(BuildContext context) {
    final workflowsAsync = ref.watch(workflowsListProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Workflows'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              ref.read(workflowsListProvider.notifier).refresh();
            },
          ),
        ],
      ),
      body: workflowsAsync.when(
        data: (workflows) {
          if (workflows.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.work_outline,
                    size: 64,
                    color: Colors.grey.shade400,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No workflows yet',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: Colors.grey.shade600,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Tap the + button to create your first workflow',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.grey.shade500,
                        ),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () async {
              await ref.read(workflowsListProvider.notifier).refresh();
            },
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: workflows.length,
              itemBuilder: (context, index) {
                final workflow = workflows[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: Theme.of(context).colorScheme.primary,
                      child: const Icon(Icons.work, color: Colors.white),
                    ),
                    title: Text(workflow.name),
                    subtitle: workflow.description != null
                        ? Text(workflow.description!)
                        : Text(
                            '${workflow.nodes.length} nodes, ${workflow.connections.length} connections',
                            style: TextStyle(
                              color: Colors.grey.shade600,
                            ),
                          ),
                    trailing: PopupMenuButton(
                      itemBuilder: (context) => [
                        const PopupMenuItem(
                          value: 'edit',
                          child: Row(
                            children: [
                              Icon(Icons.edit, size: 20),
                              SizedBox(width: 8),
                              Text('Edit'),
                            ],
                          ),
                        ),
                        const PopupMenuItem(
                          value: 'duplicate',
                          child: Row(
                            children: [
                              Icon(Icons.copy, size: 20),
                              SizedBox(width: 8),
                              Text('Duplicate'),
                            ],
                          ),
                        ),
                        const PopupMenuItem(
                          value: 'delete',
                          child: Row(
                            children: [
                              Icon(Icons.delete, size: 20, color: Colors.red),
                              SizedBox(width: 8),
                              Text('Delete', style: TextStyle(color: Colors.red)),
                            ],
                          ),
                        ),
                      ],
                      onSelected: (value) async {
                        if (value == 'delete') {
                          final confirmed = await showDialog<bool>(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: const Text('Delete Workflow'),
                              content: Text(
                                'Are you sure you want to delete "${workflow.name}"?',
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(context, false),
                                  child: const Text('Cancel'),
                                ),
                                TextButton(
                                  onPressed: () => Navigator.pop(context, true),
                                  style: TextButton.styleFrom(
                                    foregroundColor: Colors.red,
                                  ),
                                  child: const Text('Delete'),
                                ),
                              ],
                            ),
                          );

                          if (confirmed == true) {
                            await ref
                                .read(workflowsListProvider.notifier)
                                .deleteWorkflow(workflow.id);
                            if (mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Workflow deleted'),
                                ),
                              );
                            }
                          }
                        }
                      },
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => WorkflowBuilderScreen(
                            workflowId: workflow.id,
                          ),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          );
        },
        loading: () => const Center(
          child: CircularProgressIndicator(),
        ),
        error: (error, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              Text(
                'Error loading workflows',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 8),
              Text(
                error.toString(),
                style: Theme.of(context).textTheme.bodySmall,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  ref.read(workflowsListProvider.notifier).refresh();
                },
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          // Create a new workflow
          final newWorkflow = Workflow(
            id: UuidHelper.generate(),
            name: 'New Workflow',
            description: 'Created ${DateTime.now().toString().split('.').first}',
          );

          await StorageService.saveWorkflow(newWorkflow);
          await ref.read(workflowsListProvider.notifier).refresh();

          if (mounted) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => WorkflowBuilderScreen(
                  workflowId: newWorkflow.id,
                ),
              ),
            );
          }
        },
        icon: const Icon(Icons.add),
        label: const Text('New Workflow'),
      ),
    );
  }
}

