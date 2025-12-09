import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:workflow_ai/core/models/workflow.dart';
import 'package:workflow_ai/core/services/storage_service.dart';

class WorkflowsListNotifier extends StateNotifier<AsyncValue<List<Workflow>>> {
  WorkflowsListNotifier() : super(const AsyncValue.loading()) {
    loadWorkflows();
  }

  Future<void> loadWorkflows() async {
    try {
      state = const AsyncValue.loading();
      final workflows = await StorageService.getAllWorkflows();
      state = AsyncValue.data(workflows);
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
    }
  }

  Future<void> deleteWorkflow(String id) async {
    await StorageService.deleteWorkflow(id);
    await loadWorkflows();
  }

  Future<void> refresh() async {
    await loadWorkflows();
  }
}

final workflowsListProvider =
    StateNotifierProvider<WorkflowsListNotifier, AsyncValue<List<Workflow>>>(
  (ref) => WorkflowsListNotifier(),
);

