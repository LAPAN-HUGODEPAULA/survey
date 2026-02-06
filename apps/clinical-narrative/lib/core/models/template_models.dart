library;

class TemplateRecord {
  TemplateRecord({
    required this.id,
    required this.templateGroupId,
    required this.name,
    required this.documentType,
    required this.version,
    required this.status,
    required this.body,
    required this.placeholders,
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final String templateGroupId;
  final String name;
  final String documentType;
  final String version;
  final String status;
  final String body;
  final List<String> placeholders;
  final String createdAt;
  final String updatedAt;

  factory TemplateRecord.fromJson(Map<String, dynamic> json) {
    return TemplateRecord(
      id: json['_id']?.toString() ?? '',
      templateGroupId: json['templateGroupId']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      documentType: json['documentType']?.toString() ?? '',
      version: json['version']?.toString() ?? '',
      status: json['status']?.toString() ?? '',
      body: json['body']?.toString() ?? '',
      placeholders: (json['placeholders'] as List?)
              ?.map((item) => item.toString())
              .toList() ??
          const [],
      createdAt: json['createdAt']?.toString() ?? '',
      updatedAt: json['updatedAt']?.toString() ?? '',
    );
  }
}

class TemplatePreview {
  TemplatePreview({
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

  factory TemplatePreview.fromJson(Map<String, dynamic> json) {
    return TemplatePreview(
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
