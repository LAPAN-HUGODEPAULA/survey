class ChatMessage {
  ChatMessage({
    required this.id,
    required this.sessionId,
    required this.role,
    required this.messageType,
    required this.content,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
    this.metadata,
    this.editHistory,
    this.isPending = false,
    this.hasError = false,
  });

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      id: (json['_id'] ?? '').toString(),
      sessionId: (json['sessionId'] ?? '').toString(),
      role: (json['role'] ?? '').toString(),
      messageType: (json['messageType'] ?? '').toString(),
      content: (json['content'] ?? '').toString(),
      createdAt: (json['createdAt'] ?? '').toString(),
      updatedAt: (json['updatedAt'] ?? '').toString(),
      deletedAt: json['deletedAt']?.toString(),
      metadata: json['metadata'] is Map<String, dynamic>
          ? Map<String, dynamic>.from(json['metadata'] as Map<String, dynamic>)
          : null,
      editHistory: json['editHistory'] is List
          ? (json['editHistory'] as List)
                .whereType<Map<Object?, Object?>>()
                .map(Map<String, dynamic>.from)
                .toList()
          : null,
    );
  }

  final String id;
  final String sessionId;
  final String role;
  final String messageType;
  final String content;
  final String createdAt;
  final String updatedAt;
  final String? deletedAt;
  final Map<String, dynamic>? metadata;
  final List<Map<String, dynamic>>? editHistory;
  final bool isPending;
  final bool hasError;

  ChatMessage copyWith({
    String? content,
    String? updatedAt,
    String? deletedAt,
    Map<String, dynamic>? metadata,
    List<Map<String, dynamic>>? editHistory,
    bool? isPending,
    bool? hasError,
  }) {
    return ChatMessage(
      id: id,
      sessionId: sessionId,
      role: role,
      messageType: messageType,
      content: content ?? this.content,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      metadata: metadata ?? this.metadata,
      editHistory: editHistory ?? this.editHistory,
      isPending: isPending ?? this.isPending,
      hasError: hasError ?? this.hasError,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'sessionId': sessionId,
      'role': role,
      'messageType': messageType,
      'content': content,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
      if (deletedAt != null) 'deletedAt': deletedAt,
      if (metadata != null) 'metadata': metadata,
      if (editHistory != null) 'editHistory': editHistory,
    };
  }
}
