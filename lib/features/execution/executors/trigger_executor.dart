import 'package:workflow_ai/core/models/node.dart';
import 'package:workflow_ai/features/execution/executors/base_executor.dart';

class TriggerExecutor extends NodeExecutor {
  @override
  bool canExecute(String nodeType) {
    return ['manual', 'schedule'].contains(nodeType);
  }

  @override
  Future<Map<String, dynamic>> execute(
    Node node,
    Map<String, dynamic> inputData,
  ) async {
    switch (node.type) {
      case 'manual':
        return _executeManual(node, inputData);
      case 'schedule':
        return _executeSchedule(node, inputData);
      default:
        throw Exception('Unknown trigger node type: ${node.type}');
    }
  }

  Future<Map<String, dynamic>> _executeManual(
    Node node,
    Map<String, dynamic> inputData,
  ) async {
    // Manual trigger just passes through initial data
    return {
      'triggered': 'manual',
      'timestamp': DateTime.now().toIso8601String(),
      'data': inputData,
    };
  }

  Future<Map<String, dynamic>> _executeSchedule(
    Node node,
    Map<String, dynamic> inputData,
  ) async {
    // Schedule trigger (would be handled by scheduler in real implementation)
    return {
      'triggered': 'schedule',
      'timestamp': DateTime.now().toIso8601String(),
      'data': inputData,
    };
  }
}

