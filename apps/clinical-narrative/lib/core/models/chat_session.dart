library;

class ChatSession {
  ChatSession({
    required this.id,
    required this.status,
    required this.phase,
    required this.createdAt,
    required this.updatedAt,
    this.patientId,
    this.completedAt,
    this.metadata,
  });

  final String id;
  final String status;
  final String phase;
  final String createdAt;
  final String updatedAt;
  final String? patientId;
  final String? completedAt;
  final Map<String, dynamic>? metadata;

  ChatSession copyWith({
    String? status,
    String? phase,
    String? updatedAt,
    String? completedAt,
    Map<String, dynamic>? metadata,
  }) {
    return ChatSession(
      id: id,
      status: status ?? this.status,
      phase: phase ?? this.phase,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      patientId: patientId,
      completedAt: completedAt ?? this.completedAt,
      metadata: metadata ?? this.metadata,
    );
  }

  factory ChatSession.fromJson(Map<String, dynamic> json) {
    return ChatSession(
      id: (json['_id'] ?? '').toString(),
      status: (json['status'] ?? '').toString(),
      phase: (json['phase'] ?? '').toString(),
      createdAt: (json['createdAt'] ?? '').toString(),
      updatedAt: (json['updatedAt'] ?? '').toString(),
      patientId: json['patientId']?.toString(),
      completedAt: json['completedAt']?.toString(),
      metadata: json['metadata'] is Map<String, dynamic>
          ? Map<String, dynamic>.from(json['metadata'] as Map)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'status': status,
      'phase': phase,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
      if (patientId != null) 'patientId': patientId,
      if (completedAt != null) 'completedAt': completedAt,
      if (metadata != null) 'metadata': metadata,
    };
  }
}
