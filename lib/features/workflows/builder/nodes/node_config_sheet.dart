import 'package:flutter/material.dart';
import 'package:workflow_ai/core/models/node.dart';
import 'package:workflow_ai/features/nodes/node_registry.dart';

class NodeConfigSheet extends StatefulWidget {
  final Node node;
  final Function(Node) onSave;

  const NodeConfigSheet({
    super.key,
    required this.node,
    required this.onSave,
  });

  @override
  State<NodeConfigSheet> createState() => _NodeConfigSheetState();
}

class _NodeConfigSheetState extends State<NodeConfigSheet> {
  late Map<String, dynamic> _configuration;
  late TextEditingController _nameController;

  @override
  void initState() {
    super.initState();
    _configuration = Map<String, dynamic>.from(widget.node.configuration);
    _nameController = TextEditingController(text: widget.node.name);
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _save() {
    final updatedNode = widget.node.copyWith(
      name: _nameController.text,
      configuration: _configuration,
    );
    widget.onSave(updatedNode);
    Navigator.pop(context);
  }

  Widget _buildConfigField(String key, dynamic value) {
    if (value is String) {
      return TextField(
        controller: TextEditingController(text: value),
        decoration: InputDecoration(
          labelText: key,
          border: const OutlineInputBorder(),
        ),
        onChanged: (newValue) {
          _configuration[key] = newValue;
        },
      );
    } else if (value is int) {
      return TextField(
        controller: TextEditingController(text: value.toString()),
        decoration: InputDecoration(
          labelText: key,
          border: const OutlineInputBorder(),
        ),
        keyboardType: TextInputType.number,
        onChanged: (newValue) {
          final intValue = int.tryParse(newValue);
          if (intValue != null) {
            _configuration[key] = intValue;
          }
        },
      );
    } else if (value is Map) {
      return ExpansionTile(
        title: Text(key),
        children: value.entries.map((entry) {
          return Padding(
            padding: const EdgeInsets.only(left: 16),
            child: _buildConfigField(entry.key, entry.value),
          );
        }).toList(),
      );
    }
    return const SizedBox.shrink();
  }

  @override
  Widget build(BuildContext context) {
    final nodeDef = NodeRegistry.getByType(widget.node.type);

    return DraggableScrollableSheet(
      initialChildSize: 0.7,
      minChildSize: 0.5,
      maxChildSize: 0.9,
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: Theme.of(context).scaffoldBackgroundColor,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
          ),
          child: Column(
            children: [
              // Handle bar
              Container(
                margin: const EdgeInsets.only(top: 12),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              // Header
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    if (nodeDef != null) Icon(nodeDef.icon),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        widget.node.name,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ),
              // Configuration fields
              Expanded(
                child: ListView(
                  controller: scrollController,
                  padding: const EdgeInsets.all(16),
                  children: [
                    // Node name
                    TextField(
                      controller: _nameController,
                      decoration: const InputDecoration(
                        labelText: 'Node Name',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Configuration
                    if (_configuration.isNotEmpty) ...[
                      const Text(
                        'Configuration',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      ..._configuration.entries.map((entry) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 16),
                          child: _buildConfigField(entry.key, entry.value),
                        );
                      }),
                    ] else
                      const Text(
                        'No configuration options available',
                        style: TextStyle(color: Colors.grey),
                      ),
                  ],
                ),
              ),
              // Save button
              Padding(
                padding: const EdgeInsets.all(16),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _save,
                    child: const Text('Save'),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

