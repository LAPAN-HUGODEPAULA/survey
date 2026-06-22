import 'dart:convert';

class ReportSpan {
  const ReportSpan({
    required this.text,
    this.bold = false,
    this.italic = false,
  });

  final String text;
  final bool bold;
  final bool italic;

  factory ReportSpan.fromJson(Map<String, Object?> json) {
    return ReportSpan(
      text: json['text']?.toString() ?? '',
      bold: json['bold'] == true,
      italic: json['italic'] == true,
    );
  }

  Map<String, dynamic> toJson() => {
    'text': text,
    'bold': bold,
    'italic': italic,
  };
}

abstract class ReportBlock {
  const ReportBlock(this.type);

  final String type;

  factory ReportBlock.fromJson(Map<String, Object?> json) {
    final type = json['type']?.toString();
    switch (type) {
      case 'paragraph':
        return ReportParagraphBlock.fromJson(json);
      case 'bullet_list':
        return ReportBulletListBlock.fromJson(json);
      case 'key_value':
        return ReportKeyValueBlock.fromJson(json);
      default:
        return ReportParagraphBlock(
          spans: [ReportSpan(text: jsonEncode(json))],
        );
    }
  }
}

class ReportParagraphBlock extends ReportBlock {
  ReportParagraphBlock({required this.spans}) : super('paragraph');

  final List<ReportSpan> spans;

  factory ReportParagraphBlock.fromJson(Map<String, Object?> json) {
    final rawSpans = json['spans'] as List<Object?>? ?? const <Object?>[];
    return ReportParagraphBlock(
      spans: rawSpans
          .whereType<Map<String, Object?>>()
          .map(ReportSpan.fromJson)
          .toList(growable: false),
    );
  }
}

class ReportBulletItem {
  const ReportBulletItem({required this.spans});

  final List<ReportSpan> spans;

  factory ReportBulletItem.fromJson(Map<String, Object?> json) {
    final rawSpans = json['spans'] as List<Object?>? ?? const <Object?>[];
    return ReportBulletItem(
      spans: rawSpans
          .whereType<Map<String, Object?>>()
          .map(ReportSpan.fromJson)
          .toList(growable: false),
    );
  }
}

class ReportBulletListBlock extends ReportBlock {
  ReportBulletListBlock({required this.items}) : super('bullet_list');

  final List<ReportBulletItem> items;

  factory ReportBulletListBlock.fromJson(Map<String, Object?> json) {
    final rawItems = json['items'] as List<Object?>? ?? const <Object?>[];
    return ReportBulletListBlock(
      items: rawItems
          .whereType<Map<String, Object?>>()
          .map(ReportBulletItem.fromJson)
          .toList(growable: false),
    );
  }
}

class ReportKeyValueItem {
  const ReportKeyValueItem({required this.key, required this.value});

  final String key;
  final List<ReportSpan> value;

  factory ReportKeyValueItem.fromJson(Map<String, Object?> json) {
    final rawValue = json['value'] as List<Object?>? ?? const <Object?>[];
    return ReportKeyValueItem(
      key: json['key']?.toString() ?? '',
      value: rawValue
          .whereType<Map<String, Object?>>()
          .map(ReportSpan.fromJson)
          .toList(growable: false),
    );
  }
}

class ReportKeyValueBlock extends ReportBlock {
  ReportKeyValueBlock({required this.items}) : super('key_value');

  final List<ReportKeyValueItem> items;

  factory ReportKeyValueBlock.fromJson(Map<String, Object?> json) {
    final rawItems = json['items'] as List<Object?>? ?? const <Object?>[];
    return ReportKeyValueBlock(
      items: rawItems
          .whereType<Map<String, Object?>>()
          .map(ReportKeyValueItem.fromJson)
          .toList(growable: false),
    );
  }
}

class ReportSection {
  const ReportSection({required this.title, required this.blocks});

  final String title;
  final List<ReportBlock> blocks;

  factory ReportSection.fromJson(Map<String, Object?> json) {
    final rawBlocks = json['blocks'] as List<Object?>? ?? const <Object?>[];
    return ReportSection(
      title: json['title']?.toString() ?? '',
      blocks: rawBlocks
          .whereType<Map<String, Object?>>()
          .map(ReportBlock.fromJson)
          .toList(growable: false),
    );
  }
}

class ReportPatientInfo {
  const ReportPatientInfo({
    this.name,
    this.reference,
    this.birthDate,
    this.sex,
  });

  final String? name;
  final String? reference;
  final String? birthDate;
  final String? sex;

  bool get hasInfo =>
      _hasText(name) ||
      _hasText(reference) ||
      _hasText(birthDate) ||
      _hasText(sex);

  factory ReportPatientInfo.fromJson(Map<String, Object?> json) {
    return ReportPatientInfo(
      name: json['name']?.toString(),
      reference: json['reference']?.toString(),
      birthDate: json['birth_date']?.toString(),
      sex: json['sex']?.toString(),
    );
  }
}

class ReportDocument {
  const ReportDocument({
    required this.title,
    required this.patient,
    required this.sections,
    this.subtitle,
    this.createdAt,
  });

  final String title;
  final String? subtitle;
  final DateTime? createdAt;
  final ReportPatientInfo patient;
  final List<ReportSection> sections;

  factory ReportDocument.fromJson(Map<String, Object?> json) {
    final rawSections = json['sections'] as List<Object?>? ?? const <Object?>[];
    final createdAtRaw = json['created_at']?.toString();
    final rawPatient = json['patient'];

    return ReportDocument(
      title: json['title']?.toString() ?? '',
      subtitle: json['subtitle']?.toString(),
      createdAt: _parseDate(createdAtRaw),
      patient: rawPatient is Map<String, Object?>
          ? ReportPatientInfo.fromJson(rawPatient)
          : const ReportPatientInfo(),
      sections: rawSections
          .whereType<Map<String, Object?>>()
          .map(ReportSection.fromJson)
          .toList(growable: false),
    );
  }

  factory ReportDocument.fromPlainText({
    required String text,
    required String title,
    String? subtitle,
    ReportPatientInfo? patient,
  }) {
    final blocks = text
        .split(RegExp(r'\n\s*\n'))
        .map((paragraph) => paragraph.trim())
        .where((paragraph) => paragraph.isNotEmpty)
        .map(
          (paragraph) =>
              ReportParagraphBlock(spans: [ReportSpan(text: paragraph)]),
        )
        .toList(growable: false);
    return ReportDocument(
      title: title,
      subtitle: subtitle,
      createdAt: DateTime.now(),
      patient: patient ?? const ReportPatientInfo(),
      sections: [ReportSection(title: 'Relatorio', blocks: blocks)],
    );
  }

  factory ReportDocument.fromError(String message) {
    return ReportDocument(
      title: 'Relatorio Clinico',
      createdAt: DateTime.now(),
      patient: const ReportPatientInfo(),
      sections: [
        ReportSection(
          title: 'Erro no processamento',
          blocks: [
            ReportParagraphBlock(spans: [ReportSpan(text: message)]),
          ],
        ),
      ],
    );
  }

  String toPlainText({String? footer}) {
    final buffer = StringBuffer();
    final subtitle = this.subtitle;
    final createdAt = this.createdAt;
    if (title.trim().isNotEmpty) {
      buffer.writeln(title.trim());
    }
    if (_hasText(subtitle)) {
      buffer.writeln(subtitle?.trim());
    }
    if (createdAt != null) {
      buffer.writeln('Gerado em: ${_formatDate(createdAt)}');
    }
    if (patient.hasInfo) {
      buffer.writeln('');
      if (_hasText(patient.name)) {
        buffer.writeln('Paciente: ${patient.name?.trim()}');
      }
      if (_hasText(patient.reference)) {
        buffer.writeln('Referencia: ${patient.reference?.trim()}');
      }
      if (_hasText(patient.birthDate)) {
        buffer.writeln('Nascimento: ${patient.birthDate?.trim()}');
      }
      if (_hasText(patient.sex)) {
        buffer.writeln('Sexo: ${patient.sex?.trim()}');
      }
    }
    for (final section in sections) {
      buffer.writeln('');
      buffer.writeln('${section.title}:');
      for (final block in section.blocks) {
        if (block is ReportParagraphBlock) {
          buffer.writeln(_spansToText(block.spans));
        } else if (block is ReportBulletListBlock) {
          for (final item in block.items) {
            buffer.writeln('- ${_spansToText(item.spans)}');
          }
        } else if (block is ReportKeyValueBlock) {
          for (final item in block.items) {
            buffer.writeln('${item.key}: ${_spansToText(item.value)}');
          }
        }
      }
    }
    if (footer != null && footer.trim().isNotEmpty) {
      buffer.writeln('');
      buffer.writeln(footer.trim());
    }
    return buffer.toString().trim();
  }
}

bool _hasText(String? value) => value?.trim().isNotEmpty ?? false;

DateTime? _parseDate(String? value) {
  if (value == null || value.trim().isEmpty) {
    return null;
  }
  try {
    return DateTime.parse(value);
  } catch (_) {
    return null;
  }
}

String _formatDate(DateTime date) {
  final local = date.toLocal();
  final day = local.day.toString().padLeft(2, '0');
  final month = local.month.toString().padLeft(2, '0');
  final year = local.year.toString().padLeft(4, '0');
  final hour = local.hour.toString().padLeft(2, '0');
  final minute = local.minute.toString().padLeft(2, '0');
  return '$day/$month/$year $hour:$minute';
}

String _spansToText(List<ReportSpan> spans) {
  return spans.map((span) => span.text).join();
}
