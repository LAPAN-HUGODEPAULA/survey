import 'package:flutter/services.dart';

enum DsLegalDocumentType { termsOfUse, initialNotice }

class DsLegalDocument {
  const DsLegalDocument({
    required this.type,
    required this.title,
    required this.markdown,
    this.checkboxLabel,
  });

  final DsLegalDocumentType type;
  final String title;
  final String markdown;
  final String? checkboxLabel;
}

class DsLegalContentRepository {
  static const String _packageName = 'design_system_flutter';
  static const String _termsPath =
      'packages/$_packageName/assets/legal/Termo-de-Uso-e-Política-de-Privacidade-ptbr.md';
  static const String _initialNoticePath =
      'packages/$_packageName/assets/legal/Aviso-Inicial-de-Uso-ptbr.md';
  static const String _checkboxMarker = '**Checkbox sugerido**';

  static final Map<DsLegalDocumentType, Future<DsLegalDocument>> _cache =
      <DsLegalDocumentType, Future<DsLegalDocument>>{};

  static Future<DsLegalDocument> load(DsLegalDocumentType type) {
    return _cache.putIfAbsent(type, () => _load(type));
  }

  static Future<DsLegalDocument> _load(DsLegalDocumentType type) async {
    switch (type) {
      case DsLegalDocumentType.termsOfUse:
        final markdown = await rootBundle.loadString(_termsPath);
        return parseTermsOfUse(markdown);
      case DsLegalDocumentType.initialNotice:
        final rawMarkdown = await rootBundle.loadString(_initialNoticePath);
        return parseInitialNotice(rawMarkdown);
    }
  }

  static DsLegalDocument parseTermsOfUse(String markdown) {
    return DsLegalDocument(
      type: DsLegalDocumentType.termsOfUse,
      title: 'Termo de Uso e Política de Privacidade',
      markdown: markdown.trim(),
    );
  }

  static DsLegalDocument parseInitialNotice(String rawMarkdown) {
    final markerIndex = rawMarkdown.indexOf(_checkboxMarker);
    if (markerIndex == -1) {
      return DsLegalDocument(
        type: DsLegalDocumentType.initialNotice,
        title: 'Aviso Inicial de Uso',
        markdown: rawMarkdown.trim(),
      );
    }

    final body = rawMarkdown.substring(0, markerIndex).trim();
    final trailing =
        rawMarkdown.substring(markerIndex + _checkboxMarker.length).trim();
    final checkboxLabel = trailing
        .split('\n')
        .map((line) => line.trim())
        .where((line) => line.isNotEmpty)
        .map((line) => line.replaceFirst(RegExp(r'^\[\s*\]\s*'), '').trim())
        .firstWhere((line) => line.isNotEmpty, orElse: () => '');

    return DsLegalDocument(
      type: DsLegalDocumentType.initialNotice,
      title: 'Aviso Inicial de Uso',
      markdown: body,
      checkboxLabel: checkboxLabel.isEmpty ? null : checkboxLabel,
    );
  }
}
