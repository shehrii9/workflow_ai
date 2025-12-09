class Connection {
  final String id;
  final String sourceNodeId;
  final String sourcePortId;
  final String targetNodeId;
  final String targetPortId;

  Connection({
    required this.id,
    required this.sourceNodeId,
    required this.sourcePortId,
    required this.targetNodeId,
    required this.targetPortId,
  });

  Connection copyWith({
    String? id,
    String? sourceNodeId,
    String? sourcePortId,
    String? targetNodeId,
    String? targetPortId,
  }) {
    return Connection(
      id: id ?? this.id,
      sourceNodeId: sourceNodeId ?? this.sourceNodeId,
      sourcePortId: sourcePortId ?? this.sourcePortId,
      targetNodeId: targetNodeId ?? this.targetNodeId,
      targetPortId: targetPortId ?? this.targetPortId,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'sourceNodeId': sourceNodeId,
      'sourcePortId': sourcePortId,
      'targetNodeId': targetNodeId,
      'targetPortId': targetPortId,
    };
  }

  factory Connection.fromJson(Map<String, dynamic> json) {
    return Connection(
      id: json['id'] as String,
      sourceNodeId: json['sourceNodeId'] as String,
      sourcePortId: json['sourcePortId'] as String,
      targetNodeId: json['targetNodeId'] as String,
      targetPortId: json['targetPortId'] as String,
    );
  }
}

