library;

class DocumentPreview {
  DocumentPreview({
    required this.html,
    required this.title,
    required this.body,
    required this.missingFields,
    required this.metadata,
  });

  final String html;
  final String title;
  final String body;
  final List<String> missingFields;
  final Map<String, dynamic> metadata;

  factory DocumentPreview.fromJson(Map<String, dynamic> json) {
    return DocumentPreview(
      html: json['html']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      body: json['body']?.toString() ?? '',
      missingFields: (json['missingFields'] as List?)
              ?.map((item) => item.toString())
              .toList() ??
          const [],
      metadata: json['metadata'] is Map<String, dynamic>
          ? Map<String, dynamic>.from(json['metadata'] as Map)
          : const {},
    );
  }
}

class DocumentRecord {
  DocumentRecord({
    required this.id,
    required this.sessionId,
    required this.documentType,
    required this.title,
    required this.body,
    required this.html,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    required this.metadata,
  });

  final String id;
  final String sessionId;
  final String documentType;
  final String title;
  final String body;
  final String html;
  final String status;
  final String createdAt;
  final String updatedAt;
  final Map<String, dynamic> metadata;

  factory DocumentRecord.fromJson(Map<String, dynamic> json) {
    return DocumentRecord(
      id: json['_id']?.toString() ?? '',
      sessionId: json['sessionId']?.toString() ?? '',
      documentType: json['documentType']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      body: json['body']?.toString() ?? '',
      html: json['html']?.toString() ?? '',
      status: json['status']?.toString() ?? '',
      createdAt: json['createdAt']?.toString() ?? '',
      updatedAt: json['updatedAt']?.toString() ?? '',
      metadata: json['metadata'] is Map<String, dynamic>
          ? Map<String, dynamic>.from(json['metadata'] as Map)
          : const {},
    );
  }
}
