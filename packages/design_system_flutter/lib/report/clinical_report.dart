import 'package:flutter/material.dart';

class ClinicalReportSection {
  final String title;
  final String? body;
  final List<String> bullets;

  const ClinicalReportSection({
    required this.title,
    this.body,
    this.bullets = const [],
  });

  bool get hasContent => (body != null && body!.trim().isNotEmpty) || bullets.isNotEmpty;
}

List<ClinicalReportSection> buildClinicalReportSections({
  String? classification,
  String? medicalRecord,
  String classificationTitle = 'Classificacao',
  String recordTitle = 'Registro Clinico',
}) {
  final sections = <ClinicalReportSection>[];

  final trimmedClassification = classification?.trim();
  if (trimmedClassification != null && trimmedClassification.isNotEmpty) {
    sections.add(
      ClinicalReportSection(
        title: classificationTitle,
        body: trimmedClassification,
      ),
    );
  }

  final record = medicalRecord?.trim();
  if (record == null || record.isEmpty) {
    return sections;
  }

  final blocks = record.split(RegExp(r'\n\s*\n'));
  for (final rawBlock in blocks) {
    final block = rawBlock.trim();
    if (block.isEmpty) {
      continue;
    }

    final parsed = _parseBlock(block, recordTitle);
    if (parsed != null && parsed.hasContent) {
      sections.add(parsed);
    }
  }

  return sections;
}

ClinicalReportSection? _parseBlock(String block, String defaultTitle) {
  final lines = block
      .split(RegExp(r'\r?\n'))
      .map((line) => line.trim())
      .where((line) => line.isNotEmpty)
      .toList();

  if (lines.isEmpty) {
    return null;
  }

  String title = defaultTitle;
  List<String> contentLines = List<String>.from(lines);

  final firstLine = contentLines.first;
  if (firstLine.endsWith(':')) {
    title = firstLine.substring(0, firstLine.length - 1).trim();
    contentLines = contentLines.sublist(1);
  } else if (contentLines.length == 1 && firstLine.contains(':')) {
    final splitIndex = firstLine.indexOf(':');
    title = firstLine.substring(0, splitIndex).trim();
    final remainder = firstLine.substring(splitIndex + 1).trim();
    contentLines = remainder.isEmpty ? <String>[] : <String>[remainder];
  }

  final bulletMatcher = RegExp(r'^[-\u2022]\s+');
  final bullets = <String>[];
  final bodyLines = <String>[];

  for (final line in contentLines) {
    if (bulletMatcher.hasMatch(line)) {
      bullets.add(line.replaceFirst(bulletMatcher, '').trim());
    } else {
      bodyLines.add(line);
    }
  }

  final body = bodyLines.isEmpty ? null : bodyLines.join('\n');

  return ClinicalReportSection(
    title: title,
    body: body,
    bullets: bullets,
  );
}

class ClinicalReportView extends StatelessWidget {
  final String title;
  final String? subtitle;
  final String? meta;
  final List<ClinicalReportSection> sections;
  final String? footer;
  final VoidCallback? onPrint;
  final VoidCallback? onExport;

  const ClinicalReportView({
    super.key,
    required this.title,
    required this.sections,
    this.subtitle,
    this.meta,
    this.footer,
    this.onPrint,
    this.onExport,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: scheme.outlineVariant),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _ReportHeader(
            title: title,
            subtitle: subtitle,
            meta: meta,
            onPrint: onPrint,
            onExport: onExport,
          ),
          const SizedBox(height: 16),
          for (final section in sections) ...[
            _ReportSection(section: section),
            const SizedBox(height: 16),
          ],
          if (footer != null && footer!.trim().isNotEmpty) ...[
            Divider(color: scheme.outlineVariant),
            const SizedBox(height: 8),
            Text(
              footer!,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: scheme.onSurfaceVariant,
                  ),
            ),
          ],
        ],
      ),
    );
  }
}

class _ReportHeader extends StatelessWidget {
  final String title;
  final String? subtitle;
  final String? meta;
  final VoidCallback? onPrint;
  final VoidCallback? onExport;

  const _ReportHeader({
    required this.title,
    this.subtitle,
    this.meta,
    this.onPrint,
    this.onExport,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final actions = <Widget>[
      if (onPrint != null)
        TextButton.icon(
          onPressed: onPrint,
          icon: const Icon(Icons.print_outlined),
          label: const Text('Imprimir'),
        ),
      if (onExport != null)
        OutlinedButton.icon(
          onPressed: onExport,
          icon: const Icon(Icons.download_outlined),
          label: const Text('Exportar'),
        ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                  if (subtitle != null && subtitle!.trim().isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(
                        subtitle!,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: scheme.onSurfaceVariant,
                            ),
                      ),
                    ),
                  if (meta != null && meta!.trim().isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(
                        meta!,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: scheme.onSurfaceVariant,
                            ),
                      ),
                    ),
                ],
              ),
            ),
            if (actions.isNotEmpty)
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: actions,
              ),
          ],
        ),
        const SizedBox(height: 12),
        Container(
          height: 4,
          width: 56,
          decoration: BoxDecoration(
            color: scheme.primary,
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ],
    );
  }
}

class _ReportSection extends StatelessWidget {
  final ClinicalReportSection section;

  const _ReportSection({required this.section});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final bodyStyle = Theme.of(context).textTheme.bodyMedium;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          section.title,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: scheme.onSurface,
                fontWeight: FontWeight.w600,
              ),
        ),
        const SizedBox(height: 8),
        if (section.body != null && section.body!.trim().isNotEmpty)
          SelectableText(
            section.body!,
            style: bodyStyle?.copyWith(
              height: 1.5,
              color: scheme.onSurface,
            ),
          ),
        if (section.bullets.isNotEmpty) ...[
          if (section.body != null && section.body!.trim().isNotEmpty)
            const SizedBox(height: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: section.bullets
                .map(
                  (bullet) => Padding(
                    padding: const EdgeInsets.only(bottom: 6),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '\u2022',
                          style: bodyStyle?.copyWith(
                            color: scheme.primary,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: SelectableText(
                            bullet,
                            style: bodyStyle?.copyWith(
                              height: 1.5,
                              color: scheme.onSurface,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                )
                .toList(),
          ),
        ],
      ],
    );
  }
}
