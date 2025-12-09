import 'package:workflow_ai/core/models/node.dart';

/// Base class for all node executors
abstract class NodeExecutor {
  /// Execute a node with given input data
  /// Returns output data that will be passed to connected nodes
  Future<Map<String, dynamic>> execute(
    Node node,
    Map<String, dynamic> inputData,
  );

  /// Check if this executor can handle the given node type
  bool canExecute(String nodeType);
}

/// Execution result
class ExecutionResult {
  final bool success;
  final Map<String, dynamic>? data;
  final String? error;
  final Duration? duration;

  ExecutionResult({
    required this.success,
    this.data,
    this.error,
    this.duration,
  });

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'data': data,
      'error': error,
      'duration': duration?.inMilliseconds,
    };
  }
}

