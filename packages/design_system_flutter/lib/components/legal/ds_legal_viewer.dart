import 'package:design_system_flutter/components/legal/legal_content.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:markdown/markdown.dart' as md;

Future<void> showDsLegalDocumentDialog(
  BuildContext context, {
  required DsLegalDocumentType documentType,
}) {
  return showDialog<void>(
    context: context,
    builder: (context) => DsLegalDocumentDialog(documentType: documentType),
  );
}

class DsLegalDocumentDialog extends StatelessWidget {
  const DsLegalDocumentDialog({
    required this.documentType,
    super.key,
  });

  final DsLegalDocumentType documentType;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Dialog(
      insetPadding: const EdgeInsets.all(24),
      child: ConstrainedBox(
        constraints: const BoxConstraints(
          maxWidth: 920,
          maxHeight: 760,
        ),
        child: FutureBuilder<DsLegalDocument>(
          future: DsLegalContentRepository.load(documentType),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return _LegalDialogFrame(
                title: 'Aviso legal',
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Text(
                      'Não foi possível carregar o documento legal agora.',
                      style: Theme.of(context).textTheme.bodyLarge,
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              );
            }

            if (!snapshot.hasData) {
              return const _LegalDialogFrame(
                title: 'Carregando documento',
                child: Center(child: CircularProgressIndicator()),
              );
            }

            final document = snapshot.data!;
            return _LegalDialogFrame(
              title: document.title,
              child: Container(
                color: colorScheme.surface,
                padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
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
            );
          },
        ),
      ),
    );
  }
}

Map<String, Style> dsLegalHtmlStyles(BuildContext context) {
  final textTheme = Theme.of(context).textTheme;
  final colorScheme = Theme.of(context).colorScheme;
  return <String, Style>{
    'body': Style(
      margin: Margins.zero,
      padding: HtmlPaddings.zero,
      color: colorScheme.onSurface,
      fontSize: FontSize(14),
      lineHeight: const LineHeight(1.55),
    ),
    'h1': Style(
      fontSize: FontSize(textTheme.headlineSmall?.fontSize ?? 24),
      fontWeight: FontWeight.w700,
      margin: Margins.only(bottom: 18),
    ),
    'h2': Style(
      fontSize: FontSize(textTheme.titleLarge?.fontSize ?? 20),
      fontWeight: FontWeight.w700,
      margin: Margins.only(top: 20, bottom: 12),
    ),
    'h3': Style(
      fontSize: FontSize(textTheme.titleMedium?.fontSize ?? 18),
      fontWeight: FontWeight.w600,
      margin: Margins.only(top: 16, bottom: 10),
    ),
    'p': Style(margin: Margins.only(bottom: 12)),
    'li': Style(margin: Margins.only(bottom: 8)),
    'ul': Style(margin: Margins.only(bottom: 12)),
    'ol': Style(margin: Margins.only(bottom: 12)),
    'strong': Style(fontWeight: FontWeight.w700),
    'a': Style(
      color: colorScheme.primary,
      textDecoration: TextDecoration.underline,
    ),
  };
}

class _LegalDialogFrame extends StatelessWidget {
  const _LegalDialogFrame({
    required this.title,
    required this.child,
  });

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 24, 16, 12),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                ),
              ),
              IconButton(
                tooltip: 'Fechar',
                onPressed: () => Navigator.of(context).pop(),
                icon: const Icon(Icons.close),
              ),
            ],
          ),
        ),
        const Divider(height: 1),
        Expanded(child: child),
      ],
    );
  }
}
