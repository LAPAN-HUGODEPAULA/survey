import 'package:design_system_flutter/components/legal/ds_legal_viewer.dart';
import 'package:design_system_flutter/components/legal/legal_content.dart';
import 'package:design_system_flutter/widgets/ds_buttons.dart';
import 'package:design_system_flutter/widgets/ds_surface.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:markdown/markdown.dart' as md;

class DsLegalNoticeGate extends StatefulWidget {
  const DsLegalNoticeGate({
    required this.onProceed,
    super.key,
    this.title = 'Aviso Inicial de Uso',
    this.subtitle =
        'Leia com atenção antes de continuar. O botão só será liberado após a confirmação.',
    this.proceedLabel = 'Prosseguir',
    this.header,
    this.isSubmitting = false,
  });

  final Future<void> Function() onProceed;
  final String title;
  final String subtitle;
  final String proceedLabel;
  final Widget? header;
  final bool isSubmitting;

  @override
  State<DsLegalNoticeGate> createState() => _DsLegalNoticeGateState();
}

class _DsLegalNoticeGateState extends State<DsLegalNoticeGate> {
  bool _accepted = false;
  bool _isSubmitting = false;

  Future<void> _submit() async {
    if (!_accepted || _isSubmitting || widget.isSubmitting) {
      return;
    }

    setState(() => _isSubmitting = true);
    try {
      await widget.onProceed();
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return FutureBuilder<DsLegalDocument>(
      future: DsLegalContentRepository.load(DsLegalDocumentType.initialNotice),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Text(
                'Não foi possível carregar o aviso inicial agora.',
                style: theme.textTheme.bodyLarge,
                textAlign: TextAlign.center,
              ),
            ),
          );
        }

        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final document = snapshot.data!;
        final checkboxLabel = document.checkboxLabel ??
            'Li e concordo com o Termo de Uso e Política de Privacidade.';

        return Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 880),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: DsPanel(
                tone: DsPanelTone.base,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if (widget.header != null) ...[
                      Center(child: widget.header!),
                      const SizedBox(height: 20),
                    ],
                    Text(
                      widget.title,
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      widget.subtitle,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 20),
                    ConstrainedBox(
                      constraints: const BoxConstraints(maxHeight: 420),
                      child: DsFocusFrame(
                        child: Scrollbar(
                          thumbVisibility: true,
                          child: SingleChildScrollView(
                            child: Html(
                              data: md.markdownToHtml(document.markdown),
                              style: dsLegalHtmlStyles(context),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextButton.icon(
                      onPressed: () => showDsLegalDocumentDialog(
                        context,
                        documentType: DsLegalDocumentType.termsOfUse,
                      ),
                      icon: const Icon(Icons.open_in_new),
                      label: const Text(
                        'Abrir Termo de Uso e Política de Privacidade',
                      ),
                    ),
                    const SizedBox(height: 8),
                    CheckboxListTile(
                      value: _accepted,
                      onChanged: (value) =>
                          setState(() => _accepted = value ?? false),
                      contentPadding: EdgeInsets.zero,
                      controlAffinity: ListTileControlAffinity.leading,
                      title: Text(
                        checkboxLabel,
                        style: theme.textTheme.bodyMedium,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Align(
                      alignment: Alignment.centerRight,
                      child: DsFilledButton(
                        label: widget.proceedLabel,
                        onPressed:
                            _accepted && !_isSubmitting && !widget.isSubmitting
                                ? _submit
                                : null,
                        loading: _isSubmitting || widget.isSubmitting,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
