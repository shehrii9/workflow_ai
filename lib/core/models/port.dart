class Port {
  final String id;
  final String name;
  final String type; // 'input' or 'output'
  final String? dataType; // 'string', 'number', 'boolean', 'object', etc.

  Port({
    required this.id,
    required this.name,
    required this.type,
    this.dataType,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'type': type,
      'dataType': dataType,
    };
  }

  factory Port.fromJson(Map<String, dynamic> json) {
    return Port(
      id: json['id'] as String,
      name: json['name'] as String,
      type: json['type'] as String,
      dataType: json['dataType'] as String?,
    );
  }
}

