import 'package:hive_flutter/hive_flutter.dart';
import 'package:workflow_ai/core/models/workflow.dart';

class StorageService {
  static const String _workflowBoxName = 'workflows';
  static Box<Map>? _workflowBox;

  static Future<void> init() async {
    await Hive.initFlutter();
    _workflowBox = await Hive.openBox<Map>(_workflowBoxName);
  }

  // Workflow operations
  static Future<void> saveWorkflow(Workflow workflow) async {
    await _workflowBox?.put(workflow.id, workflow.toJson());
  }

  static Future<Workflow?> getWorkflow(String id) async {
    final data = _workflowBox?.get(id);
    if (data == null) return null;
    return Workflow.fromJson(Map<String, dynamic>.from(data));
  }

  static Future<List<Workflow>> getAllWorkflows() async {
    final workflows = <Workflow>[];
    if (_workflowBox == null) return workflows;

    for (var key in _workflowBox!.keys) {
      final data = _workflowBox!.get(key);
      if (data != null) {
        try {
          workflows.add(
            Workflow.fromJson(Map<String, dynamic>.from(data)),
          );
        } catch (e) {
          // Skip invalid workflows
        }
      }
    }
    return workflows;
  }

  static Future<void> deleteWorkflow(String id) async {
    await _workflowBox?.delete(id);
  }

  static Future<void> clearAllWorkflows() async {
    await _workflowBox?.clear();
  }
}

