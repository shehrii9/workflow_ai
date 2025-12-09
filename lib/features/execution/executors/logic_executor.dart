import 'package:workflow_ai/core/models/node.dart';
import 'package:workflow_ai/features/execution/executors/base_executor.dart';

class LogicExecutor extends NodeExecutor {
  @override
  bool canExecute(String nodeType) {
    return ['if', 'wait', 'merge'].contains(nodeType);
  }

  @override
  Future<Map<String, dynamic>> execute(
    Node node,
    Map<String, dynamic> inputData,
  ) async {
    switch (node.type) {
      case 'if':
        return _executeIf(node, inputData);
      case 'wait':
        return _executeWait(node, inputData);
      case 'merge':
        return _executeMerge(node, inputData);
      default:
        throw Exception('Unknown logic node type: ${node.type}');
    }
  }

  Future<Map<String, dynamic>> _executeIf(
    Node node,
    Map<String, dynamic> inputData,
  ) async {
    final condition = node.configuration['condition'] as String? ?? '';
    
    // Simple condition evaluation (can be enhanced)
    // For now, just check if condition string is truthy
    final result = _evaluateCondition(condition, inputData);
    
    return {
      'condition': condition,
      'result': result,
      'data': inputData,
    };
  }

  Future<Map<String, dynamic>> _executeWait(
    Node node,
    Map<String, dynamic> inputData,
  ) async {
    final duration = node.configuration['duration'] as int? ?? 1000;
    await Future.delayed(Duration(milliseconds: duration));
    
    return {
      'waited': duration,
      'data': inputData,
    };
  }

  Future<Map<String, dynamic>> _executeMerge(
    Node node,
    Map<String, dynamic> inputData,
  ) async {
    // Merge node receives data from multiple inputs
    // For now, just pass through the input data
    return {
      'merged': true,
      'data': inputData,
    };
  }

  bool _evaluateCondition(String condition, Map<String, dynamic> data) {
    // Simple condition evaluation
    // Can be enhanced with a proper expression parser
    if (condition.isEmpty) return false;
    
    // Check if condition references data
    for (final key in data.keys) {
      if (condition.contains(key)) {
        final value = data[key];
        if (value is bool) return value;
        if (value is String && value.isNotEmpty) return true;
        if (value != null) return true;
      }
    }
    
    // Default: check if condition is truthy
    return condition.toLowerCase() == 'true' || condition == '1';
  }
}

