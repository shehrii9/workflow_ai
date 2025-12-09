import 'package:workflow_ai/core/models/node.dart';
import 'package:workflow_ai/core/models/connection.dart';

class Workflow {
  final String id;
  final String name;
  final String? description;
  final List<Node> nodes;
  final List<Connection> connections;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isActive;
  final Map<String, dynamic> metadata;
  final List<String> tags;

  Workflow({
    required this.id,
    required this.name,
    this.description,
    this.nodes = const [],
    this.connections = const [],
    DateTime? createdAt,
    DateTime? updatedAt,
    this.isActive = true,
    this.metadata = const {},
    this.tags = const [],
  })  : createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  Workflow copyWith({
    String? id,
    String? name,
    String? description,
    List<Node>? nodes,
    List<Connection>? connections,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isActive,
    Map<String, dynamic>? metadata,
    List<String>? tags,
  }) {
    return Workflow(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      nodes: nodes ?? this.nodes,
      connections: connections ?? this.connections,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
      isActive: isActive ?? this.isActive,
      metadata: metadata ?? this.metadata,
      tags: tags ?? this.tags,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'nodes': nodes.map((e) => e.toJson()).toList(),
      'connections': connections.map((e) => e.toJson()).toList(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'isActive': isActive,
      'metadata': metadata,
      'tags': tags,
    };
  }

  factory Workflow.fromJson(Map<String, dynamic> json) {
    return Workflow(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String?,
      nodes: (json['nodes'] as List<dynamic>?)
              ?.map((e) => Node.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      connections: (json['connections'] as List<dynamic>?)
              ?.map((e) => Connection.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      isActive: json['isActive'] as bool? ?? true,
      metadata: json['metadata'] as Map<String, dynamic>? ?? {},
      tags: (json['tags'] as List<dynamic>?)?.cast<String>() ?? [],
    );
  }
}

