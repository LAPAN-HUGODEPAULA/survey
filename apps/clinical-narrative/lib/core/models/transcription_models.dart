library;

class TranscriptionSegment {
  TranscriptionSegment({
    required this.startSeconds,
    required this.endSeconds,
    required this.text,
    this.confidence,
  });

  final double startSeconds;
  final double endSeconds;
  final String text;
  final double? confidence;

  factory TranscriptionSegment.fromJson(Map<String, dynamic> json) {
    return TranscriptionSegment(
      startSeconds: (json['startSeconds'] as num?)?.toDouble() ?? 0,
      endSeconds: (json['endSeconds'] as num?)?.toDouble() ?? 0,
      text: json['text']?.toString() ?? '',
      confidence: (json['confidence'] as num?)?.toDouble(),
    );
  }
}

class TranscriptionResponse {
  TranscriptionResponse({
    required this.requestId,
    required this.text,
    required this.processingTimeMs,
    required this.provider,
    required this.language,
    required this.segments,
    required this.warnings,
    this.confidence,
    required this.metadata,
  });

  final String requestId;
  final String text;
  final int processingTimeMs;
  final String provider;
  final String language;
  final List<TranscriptionSegment> segments;
  final List<String> warnings;
  final double? confidence;
  final Map<String, dynamic> metadata;

  factory TranscriptionResponse.fromJson(Map<String, dynamic> json) {
    return TranscriptionResponse(
      requestId: json['requestId']?.toString() ?? '',
      text: json['text']?.toString() ?? '',
      processingTimeMs: (json['processingTimeMs'] as num?)?.toInt() ?? 0,
      provider: json['provider']?.toString() ?? '',
      language: json['language']?.toString() ?? '',
      segments: (json['segments'] as List?)
              ?.map((item) => TranscriptionSegment.fromJson(
                    Map<String, dynamic>.from(item as Map),
                  ))
              .toList() ??
          const [],
      warnings: (json['warnings'] as List?)
              ?.map((item) => item.toString())
              .toList() ??
          const [],
      confidence: (json['confidence'] as num?)?.toDouble(),
      metadata: json['metadata'] is Map<String, dynamic>
          ? Map<String, dynamic>.from(json['metadata'] as Map)
          : const {},
    );
  }
}
