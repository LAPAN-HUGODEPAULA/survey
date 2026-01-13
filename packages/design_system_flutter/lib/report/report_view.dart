import 'package:flutter/material.dart';

import 'report_models.dart';

class ReportView extends StatelessWidget {
  const ReportView({
    super.key,
    required this.report,
    this.footer,
    this.onPrint,
    this.onExport,
  });

  final ReportDocument report;
  final String? footer;
  final VoidCallback? onPrint;
  final VoidCallback? onExport;

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
            title: report.title,
            subtitle: report.subtitle,
            createdAt: report.createdAt,
            onPrint: onPrint,
            onExport: onExport,
          ),
          const SizedBox(height: 16),
          if (report.patient.hasInfo) ...[
            _PatientCard(patient: report.patient),
            const SizedBox(height: 16),
          ],
          for (final section in report.sections) ...[
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
  const _ReportHeader({
    required this.title,
    this.subtitle,
    this.createdAt,
    this.onPrint,
    this.onExport,
  });

  final String title;
  final String? subtitle;
  final DateTime? createdAt;
  final VoidCallback? onPrint;
  final VoidCallback? onExport;

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

    final meta = createdAt != null ? _formatDate(createdAt!) : null;

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
                  if (meta != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(
                        'Gerado em: $meta',
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

class _PatientCard extends StatelessWidget {
  const _PatientCard({required this.patient});

  final ReportPatientInfo patient;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final fields = <_PatientField>[
      if (patient.name != null && patient.name!.trim().isNotEmpty)
        _PatientField(label: 'Paciente', value: patient.name!),
      if (patient.reference != null && patient.reference!.trim().isNotEmpty)
        _PatientField(label: 'Referencia', value: patient.reference!),
      if (patient.birthDate != null && patient.birthDate!.trim().isNotEmpty)
        _PatientField(label: 'Nascimento', value: patient.birthDate!),
      if (patient.sex != null && patient.sex!.trim().isNotEmpty)
        _PatientField(label: 'Sexo', value: patient.sex!),
    ];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: scheme.surfaceVariant,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: scheme.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.person_outline, color: scheme.primary),
              const SizedBox(width: 8),
              Text(
                'Paciente',
                style: textTheme.titleSmall?.copyWith(
                  color: scheme.onSurfaceVariant,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          for (final field in fields)
            Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: 110,
                    child: Text(
                      field.label,
                      style: textTheme.bodySmall?.copyWith(
                        color: scheme.onSurfaceVariant,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Text(
                      field.value,
                      style: textTheme.bodyMedium?.copyWith(
                        color: scheme.onSurface,
                      ),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _PatientField {
  const _PatientField({required this.label, required this.value});

  final String label;
  final String value;
}

class _ReportSection extends StatelessWidget {
  const _ReportSection({required this.section});

  final ReportSection section;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: scheme.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(_sectionIcon(section.title), color: scheme.primary),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  section.title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          for (final block in section.blocks) ...[
            _BlockView(block: block),
            const SizedBox(height: 12),
          ],
        ],
      ),
    );
  }
}

class _BlockView extends StatelessWidget {
  const _BlockView({required this.block});

  final ReportBlock block;

  @override
  Widget build(BuildContext context) {
    if (block is ReportParagraphBlock) {
      return _ParagraphView(block: block as ReportParagraphBlock);
    }
    if (block is ReportBulletListBlock) {
      return _BulletListView(block: block as ReportBulletListBlock);
    }
    if (block is ReportKeyValueBlock) {
      return _KeyValueView(block: block as ReportKeyValueBlock);
    }
    return const SizedBox.shrink();
  }
}

class _ParagraphView extends StatelessWidget {
  const _ParagraphView({required this.block});

  final ReportParagraphBlock block;

  @override
  Widget build(BuildContext context) {
    final style = Theme.of(context).textTheme.bodyMedium?.copyWith(height: 1.5);
    return SelectableText.rich(
      TextSpan(children: _buildSpans(block.spans, style)),
      style: style,
    );
  }
}

class _BulletListView extends StatelessWidget {
  const _BulletListView({required this.block});

  final ReportBulletListBlock block;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final style = Theme.of(context).textTheme.bodyMedium?.copyWith(height: 1.5);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final item in block.items)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '\u2022',
                  style: style?.copyWith(
                    color: scheme.primary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: SelectableText.rich(
                    TextSpan(children: _buildSpans(item.spans, style)),
                    style: style,
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}

class _KeyValueView extends StatelessWidget {
  const _KeyValueView({required this.block});

  final ReportKeyValueBlock block;

  @override
  Widget build(BuildContext context) {
    final style = Theme.of(context).textTheme.bodyMedium?.copyWith(height: 1.5);
    final labelStyle = Theme.of(context).textTheme.bodySmall?.copyWith(
          fontWeight: FontWeight.w600,
        );

    return Table(
      columnWidths: const {
        0: IntrinsicColumnWidth(),
        1: FlexColumnWidth(),
      },
      defaultVerticalAlignment: TableCellVerticalAlignment.top,
      children: [
        for (final item in block.items)
          TableRow(
            children: [
              Padding(
                padding: const EdgeInsets.only(right: 12, bottom: 8),
                child: Text(item.key, style: labelStyle),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: SelectableText.rich(
                  TextSpan(children: _buildSpans(item.value, style)),
                  style: style,
                ),
              ),
            ],
          ),
      ],
    );
  }
}

List<InlineSpan> _buildSpans(List<ReportSpan> spans, TextStyle? baseStyle) {
  return spans
      .map(
        (span) => TextSpan(
          text: span.text,
          style: baseStyle?.copyWith(
            fontWeight: span.bold ? FontWeight.w700 : FontWeight.w400,
            fontStyle: span.italic ? FontStyle.italic : FontStyle.normal,
          ),
        ),
      )
      .toList(growable: false);
}

IconData _sectionIcon(String title) {
  final normalized = title.toLowerCase();
  if (normalized.contains('resumo')) {
    return Icons.subject_outlined;
  }
  if (normalized.contains('conclus') || normalized.contains('diagnos')) {
    return Icons.fact_check_outlined;
  }
  if (normalized.contains('plano') || normalized.contains('conduta')) {
    return Icons.assignment_turned_in_outlined;
  }
  if (normalized.contains('sinais') || normalized.contains('sintoma')) {
    return Icons.health_and_safety_outlined;
  }
  return Icons.sticky_note_2_outlined;
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
