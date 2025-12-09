import 'package:workflow_ai/core/models/position.dart';
import 'package:workflow_ai/core/models/node_status.dart';
import 'package:workflow_ai/core/models/port.dart';

class Node {
  final String id;
  final String type; // 'trigger', 'action', 'logic', etc.
  final String name;
  final String category;
  final Position position;
  final Map<String, dynamic> configuration;
  final List<Port> inputs;
  final List<Port> outputs;
  final NodeStatus status;
  final Map<String, dynamic>? executionResult;

  Node({
    required this.id,
    required this.type,
    required this.name,
    required this.category,
    required this.position,
    this.configuration = const {},
    this.inputs = const [],
    this.outputs = const [],
    this.status = NodeStatus.idle,
    this.executionResult,
  });

  Node copyWith({
    String? id,
    String? type,
    String? name,
    String? category,
    Position? position,
    Map<String, dynamic>? configuration,
    List<Port>? inputs,
    List<Port>? outputs,
    NodeStatus? status,
    Map<String, dynamic>? executionResult,
  }) {
    return Node(
      id: id ?? this.id,
      type: type ?? this.type,
      name: name ?? this.name,
      category: category ?? this.category,
      position: position ?? this.position,
      configuration: configuration ?? this.configuration,
      inputs: inputs ?? this.inputs,
      outputs: outputs ?? this.outputs,
      status: status ?? this.status,
      executionResult: executionResult ?? this.executionResult,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type,
      'name': name,
      'category': category,
      'position': position.toJson(),
      'configuration': configuration,
      'inputs': inputs.map((e) => e.toJson()).toList(),
      'outputs': outputs.map((e) => e.toJson()).toList(),
      'status': status.name,
      'executionResult': executionResult,
    };
  }

  factory Node.fromJson(Map<String, dynamic> json) {
    return Node(
      id: json['id'] as String,
      type: json['type'] as String,
      name: json['name'] as String,
      category: json['category'] as String,
      position: Position.fromJson(json['position'] as Map<String, dynamic>),
      configuration: json['configuration'] as Map<String, dynamic>? ?? {},
      inputs: (json['inputs'] as List<dynamic>?)
              ?.map((e) => Port.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      outputs: (json['outputs'] as List<dynamic>?)
              ?.map((e) => Port.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      status: NodeStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => NodeStatus.idle,
      ),
      executionResult: json['executionResult'] as Map<String, dynamic>?,
    );
  }
}

