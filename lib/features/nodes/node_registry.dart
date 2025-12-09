import 'package:flutter/material.dart';
import 'package:workflow_ai/core/models/node.dart';
import 'package:workflow_ai/core/models/port.dart';
import 'package:workflow_ai/core/models/position.dart';
import 'package:workflow_ai/core/utils/uuid_helper.dart';

class NodeDefinition {
  final String type;
  final String name;
  final String category;
  final IconData icon;
  final String description;
  final List<PortDefinition> inputs;
  final List<PortDefinition> outputs;
  final Map<String, dynamic> defaultConfiguration;

  const NodeDefinition({
    required this.type,
    required this.name,
    required this.category,
    required this.icon,
    required this.description,
    this.inputs = const [],
    this.outputs = const [],
    this.defaultConfiguration = const {},
  });

  Node createNode({Position? position}) {
    return Node(
      id: UuidHelper.generate(),
      type: type,
      name: name,
      category: category,
      position: position ?? Position(x: 100, y: 100),
      configuration: Map<String, dynamic>.from(defaultConfiguration),
      inputs: inputs
          .map((input) => Port(
                id: UuidHelper.generate(),
                name: input.name,
                type: 'input',
                dataType: input.dataType,
              ))
          .toList(),
      outputs: outputs
          .map((output) => Port(
                id: UuidHelper.generate(),
                name: output.name,
                type: 'output',
                dataType: output.dataType,
              ))
          .toList(),
    );
  }
}

class PortDefinition {
  final String name;
  final String? dataType;

  const PortDefinition({
    required this.name,
    this.dataType,
  });
}

class NodeRegistry {
  static final List<NodeDefinition> _nodes = [
    // Triggers
    const NodeDefinition(
      type: 'manual',
      name: 'Manual Trigger',
      category: 'trigger',
      icon: Icons.play_arrow,
      description: 'Manually start the workflow',
      outputs: [
        PortDefinition(name: 'output', dataType: 'object'),
      ],
    ),
    const NodeDefinition(
      type: 'schedule',
      name: 'Schedule',
      category: 'trigger',
      icon: Icons.schedule,
      description: 'Trigger workflow on a schedule',
      outputs: [
        PortDefinition(name: 'output', dataType: 'object'),
      ],
    ),

    // Actions
    const NodeDefinition(
      type: 'http',
      name: 'HTTP Request',
      category: 'action',
      icon: Icons.http,
      description: 'Make an HTTP request',
      inputs: [
        PortDefinition(name: 'input', dataType: 'object'),
      ],
      outputs: [
        PortDefinition(name: 'output', dataType: 'object'),
      ],
      defaultConfiguration: {
        'method': 'GET',
        'url': '',
      },
    ),
    const NodeDefinition(
      type: 'email',
      name: 'Send Email',
      category: 'action',
      icon: Icons.email,
      description: 'Send an email',
      inputs: [
        PortDefinition(name: 'input', dataType: 'object'),
      ],
      outputs: [
        PortDefinition(name: 'output', dataType: 'object'),
      ],
      defaultConfiguration: {
        'to': '',
        'subject': '',
        'body': '',
      },
    ),

    // Logic
    const NodeDefinition(
      type: 'if',
      name: 'If',
      category: 'logic',
      icon: Icons.code,
      description: 'Conditional logic',
      inputs: [
        PortDefinition(name: 'input', dataType: 'object'),
      ],
      outputs: [
        PortDefinition(name: 'true', dataType: 'object'),
        PortDefinition(name: 'false', dataType: 'object'),
      ],
      defaultConfiguration: {
        'condition': '',
      },
    ),
    const NodeDefinition(
      type: 'wait',
      name: 'Wait',
      category: 'logic',
      icon: Icons.timer,
      description: 'Wait for a specified time',
      inputs: [
        PortDefinition(name: 'input', dataType: 'object'),
      ],
      outputs: [
        PortDefinition(name: 'output', dataType: 'object'),
      ],
      defaultConfiguration: {
        'duration': 1000,
      },
    ),
    const NodeDefinition(
      type: 'merge',
      name: 'Merge',
      category: 'logic',
      icon: Icons.merge_type,
      description: 'Merge multiple inputs',
      inputs: [
        PortDefinition(name: 'input1', dataType: 'object'),
        PortDefinition(name: 'input2', dataType: 'object'),
      ],
      outputs: [
        PortDefinition(name: 'output', dataType: 'object'),
      ],
    ),

    // Data
    const NodeDefinition(
      type: 'set',
      name: 'Set Variable',
      category: 'data',
      icon: Icons.edit,
      description: 'Set a variable value',
      inputs: [
        PortDefinition(name: 'input', dataType: 'object'),
      ],
      outputs: [
        PortDefinition(name: 'output', dataType: 'object'),
      ],
      defaultConfiguration: {
        'variable': '',
        'value': '',
      },
    ),
  ];

  static List<NodeDefinition> get allNodes => _nodes;

  static List<NodeDefinition> getByCategory(String category) {
    return _nodes.where((node) => node.category == category).toList();
  }

  static NodeDefinition? getByType(String type) {
    try {
      return _nodes.firstWhere((node) => node.type == type);
    } catch (e) {
      return null;
    }
  }

  static List<String> get categories {
    return _nodes.map((node) => node.category).toSet().toList();
  }
}

