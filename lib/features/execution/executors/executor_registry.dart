import 'package:workflow_ai/features/execution/executors/base_executor.dart';
import 'package:workflow_ai/features/execution/executors/http_executor.dart';
import 'package:workflow_ai/features/execution/executors/logic_executor.dart';
import 'package:workflow_ai/features/execution/executors/trigger_executor.dart';

class ExecutorRegistry {
  static final List<NodeExecutor> _executors = [
    TriggerExecutor(),
    HttpExecutor(),
    LogicExecutor(),
  ];

  static NodeExecutor? getExecutor(String nodeType) {
    return _executors.firstWhere(
      (executor) => executor.canExecute(nodeType),
      orElse: () => throw Exception('No executor found for node type: $nodeType'),
    );
  }

  static bool hasExecutor(String nodeType) {
    try {
      getExecutor(nodeType);
      return true;
    } catch (e) {
      return false;
    }
  }
}

