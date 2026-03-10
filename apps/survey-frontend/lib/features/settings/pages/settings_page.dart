/// Página de configurações da aplicação.
///
/// Permite selecionar o questionário ativo e gerar um link preparado
/// para uso com screener autenticado e questionário bloqueados.
library;

import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:survey_app/core/models/screener_access_link.dart';
import 'package:survey_app/core/models/survey/survey.dart';
import 'package:survey_app/core/providers/app_settings.dart';
import 'package:survey_app/core/repositories/screener_access_link_repository.dart';
import 'package:survey_app/core/services/file_download.dart';
import 'package:survey_app/features/survey/pages/survey_details_page.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key, this.accessLinkRepository});

  final ScreenerAccessLinkRepository? accessLinkRepository;

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final _formKey = GlobalKey<FormState>();
  late final ScreenerAccessLinkRepository _accessLinkRepository =
      widget.accessLinkRepository ?? ScreenerAccessLinkRepository();

  ScreenerAccessLink? _generatedLink;
  bool _isGeneratingLink = false;
  String? _generationError;

  @override
  void initState() {
    super.initState();
    final settings = Provider.of<AppSettings>(context, listen: false);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      settings.loadAvailableSurveys();
    });
  }

  void _showSurveyDetails(Survey survey) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SurveyDetailsPage(survey: survey),
      ),
    );
  }

  Future<void> _generatePreparedLink() async {
    final settings = context.read<AppSettings>();
    final token = settings.authToken;
    final selectedSurvey = settings.selectedSurvey;
    if (token == null || selectedSurvey == null) {
      return;
    }

    setState(() {
      _isGeneratingLink = true;
      _generationError = null;
    });

    try {
      final link = await _accessLinkRepository.create(
        authToken: token,
        surveyId: selectedSurvey.id,
      );
      if (!mounted) {
        return;
      }
      setState(() {
        _generatedLink = link;
        _isGeneratingLink = false;
      });
      _showMessage('Link preparado com sucesso.');
    } catch (_) {
      if (!mounted) {
        return;
      }
      setState(() {
        _isGeneratingLink = false;
        _generationError =
            'Não foi possível gerar o link agora. Tente novamente em alguns instantes.';
      });
    }
  }

  Future<void> _copyLink(String url) async {
    await Clipboard.setData(ClipboardData(text: url));
    if (!mounted) {
      return;
    }
    _showMessage('Link copiado.');
  }

  Future<void> _saveLinkText(String url) async {
    await saveTextDownload(
      fileName: 'questionario_preparado.txt',
      content: 'Link do questionário preparado:\n$url\n',
    );
    _showMessage('Arquivo de texto salvo.');
  }

  Future<void> _saveQrPng(String url) async {
    final painter = QrPainter(
      data: url,
      version: QrVersions.auto,
      gapless: true,
      eyeStyle: const QrEyeStyle(color: Colors.black),
      dataModuleStyle: const QrDataModuleStyle(color: Colors.black),
    );
    final imageData = await painter.toImageData(
      2048,
      format: ui.ImageByteFormat.png,
    );
    if (imageData == null) {
      throw StateError('Não foi possível gerar o QR code.');
    }
    await saveBytesDownload(
      fileName: 'questionario_preparado_qr.png',
      bytes: imageData.buffer.asUint8List(),
      mimeType: 'image/png',
    );
    if (!mounted) {
      return;
    }
    _showMessage('QR code em PNG salvo.');
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), duration: const Duration(seconds: 2)),
    );
  }

  void _submitForm() {
    final isFormValid = _formKey.currentState!.validate();
    final settings = Provider.of<AppSettings>(context, listen: false);
    final validationErrors = <String>[];

    if (settings.selectedSurvey == null) {
      validationErrors.add('Selecione um questionário');
    }

    if (validationErrors.isNotEmpty || !isFormValid) {
      final content = validationErrors.isNotEmpty
          ? 'Campos obrigatórios não preenchidos:\n• ${validationErrors.join('\n• ')}'
          : 'Por favor, corrija os erros nos campos destacados.';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(content),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Configurações salvas com sucesso!'),
        backgroundColor: Theme.of(context).colorScheme.tertiary,
        duration: const Duration(seconds: 2),
      ),
    );

    Future.delayed(const Duration(milliseconds: 200), () {
      if (!mounted) return;
      context.go('/');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AppSettings>(
      builder: (context, settings, child) {
        final generatedUrl = _generatedLink == null
            ? null
            : _accessLinkRepository.buildShareableUrl(_generatedLink!.token);

        return Scaffold(
          appBar: AppBar(title: const Text('Configurações')),
          body: Center(
            child: Container(
              constraints: const BoxConstraints(maxWidth: 700),
              child: Form(
                key: _formKey,
                child: ListView(
                  padding: const EdgeInsets.all(24.0),
                  children: [
                    if (settings.isLockedAssessmentMode) ...[
                      _buildLockedModeCard(settings),
                      const SizedBox(height: 24),
                    ],
                    const Text(
                      'Questionário Ativo',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      settings.isLockedAssessmentMode
                          ? 'Este questionário foi preparado com antecedência e não pode ser alterado nesta sessão.'
                          : 'Selecione qual questionário será aplicado:',
                      style: const TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                    const SizedBox(height: 16),
                    if (settings.isLoadingSurveys) ...[
                      const Center(child: CircularProgressIndicator()),
                    ] else if (settings.availableSurveys.isEmpty) ...[
                      Card(
                        color: Theme.of(context)
                            .colorScheme
                            .surfaceContainerHighest,
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Text(
                            'Nenhum questionário foi encontrado no servidor. Verifique se o backend está em execução.',
                            style: TextStyle(
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSurfaceVariant,
                            ),
                          ),
                        ),
                      ),
                    ] else ...[
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              DropdownButtonFormField<String>(
                                key: ValueKey(settings.selectedSurveyId),
                                initialValue: settings.selectedSurveyId,
                                isExpanded: true,
                                decoration: const InputDecoration(
                                  labelText: 'Questionário Selecionado *',
                                  border: OutlineInputBorder(),
                                  contentPadding: EdgeInsets.symmetric(
                                    horizontal: 16.0,
                                  ),
                                ),
                                items: settings.availableSurveys
                                    .map<DropdownMenuItem<String>>((survey) {
                                  final displayName =
                                      survey.surveyDisplayName.isNotEmpty
                                      ? survey.surveyDisplayName
                                      : survey.surveyName;
                                  return DropdownMenuItem<String>(
                                    value: survey.id,
                                    child: Text(displayName),
                                  );
                                }).toList(),
                                validator: (value) =>
                                    value == null ? 'Campo obrigatório' : null,
                                onChanged: settings.isLockedAssessmentMode
                                    ? null
                                    : (value) {
                                        settings.selectSurvey(value);
                                      },
                              ),
                              const SizedBox(height: 16),
                              ElevatedButton.icon(
                                onPressed: settings.selectedSurvey != null
                                    ? () => _showSurveyDetails(
                                        settings.selectedSurvey!,
                                      )
                                    : null,
                                icon: const Icon(Icons.info_outline),
                                label: const Text('Ver Detalhes do Questionário'),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                    const SizedBox(height: 24),
                    if (!settings.isLockedAssessmentMode) ...[
                      _buildPreparedLinkSection(settings, generatedUrl),
                      const SizedBox(height: 24),
                    ],
                    Card(
                      color: Theme.of(context).colorScheme.primaryContainer,
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  Icons.info_outline,
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onPrimaryContainer,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'Status das Configurações',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onPrimaryContainer,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            _buildStatusItem(
                              'Questionário selecionado:',
                              settings.selectedSurvey != null
                                  ? settings.selectedSurveyName
                                  : 'Nenhum selecionado',
                              settings.selectedSurvey != null,
                            ),
                            _buildStatusItem(
                              'Questionários disponíveis:',
                              '${settings.availableSurveys.length} encontrado(s)',
                              settings.availableSurveys.isNotEmpty,
                            ),
                            _buildStatusItem(
                              'Modo preparado:',
                              settings.isLockedAssessmentMode
                                  ? 'Ativo'
                                  : 'Desativado',
                              true,
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Container(
                      padding: const EdgeInsets.all(16.0),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.secondaryContainer,
                        border: Border.all(
                          color: Theme.of(context).colorScheme.outline,
                        ),
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.info_outline,
                            color: Theme.of(context)
                                .colorScheme
                                .onSecondaryContainer,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              settings.isLockedAssessmentMode
                                  ? 'Esta sessão foi aberta com um link preparado. As configurações ficam protegidas para evitar alterações acidentais.'
                                  : 'Campos marcados com (*) são obrigatórios e serão validados antes de salvar.',
                              style: const TextStyle(fontSize: 14),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: _submitForm,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text(
                        'Salvar e Voltar',
                        style: TextStyle(fontSize: 18),
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

  Widget _buildLockedModeCard(AppSettings settings) {
    return Card(
      color: Theme.of(context).colorScheme.primaryContainer,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Sessão preparada',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.onPrimaryContainer,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Este acesso foi preparado para ${settings.screenerDisplayName} com o questionário ${settings.selectedSurveyName}.',
              style: TextStyle(
                color: Theme.of(context).colorScheme.onPrimaryContainer,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPreparedLinkSection(AppSettings settings, String? generatedUrl) {
    final canGenerate = settings.isLoggedIn && settings.selectedSurvey != null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Link do Questionário',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        const Text(
          'Gere um link direto com screener e questionário já preparados para facilitar o uso por pessoas com pouca familiaridade tecnológica.',
          style: TextStyle(fontSize: 16, color: Colors.grey),
        ),
        const SizedBox(height: 16),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  canGenerate
                      ? 'O link será criado para ${settings.screenerDisplayName} e o questionário ${settings.selectedSurveyName}.'
                      : 'Entre com um screener e selecione um questionário para gerar o link preparado.',
                ),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: canGenerate && !_isGeneratingLink
                      ? _generatePreparedLink
                      : null,
                  icon: _isGeneratingLink
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.link),
                  label: const Text('Gerar link do questionário'),
                ),
                if (_generationError != null) ...[
                  const SizedBox(height: 12),
                  Text(
                    _generationError!,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.error,
                    ),
                  ),
                ],
                if (generatedUrl != null && _generatedLink != null) ...[
                  const SizedBox(height: 16),
                  SelectableText(
                    generatedUrl,
                    style: const TextStyle(fontSize: 15),
                  ),
                  const SizedBox(height: 16),
                  QrImageView(
                    data: generatedUrl,
                    size: 180,
                    backgroundColor: Colors.white,
                  ),
                  const SizedBox(height: 16),
                  Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: [
                      ElevatedButton.icon(
                        onPressed: () => _copyLink(generatedUrl),
                        icon: const Icon(Icons.copy),
                        label: const Text('Copiar link'),
                      ),
                      ElevatedButton.icon(
                        onPressed: () => _saveLinkText(generatedUrl),
                        icon: const Icon(Icons.description_outlined),
                        label: const Text('Salvar texto'),
                      ),
                      ElevatedButton.icon(
                        onPressed: () => _saveQrPng(generatedUrl),
                        icon: const Icon(Icons.qr_code_2),
                        label: const Text('Salvar QR em PNG'),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStatusItem(String label, String value, bool isValid) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          Icon(
            isValid ? Icons.check_circle : Icons.cancel,
            color: isValid
                ? Theme.of(context).colorScheme.tertiary
                : Theme.of(context).colorScheme.error,
            size: 20,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: RichText(
              text: TextSpan(
                style: TextStyle(
                  fontSize: 14,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
                children: [
                  TextSpan(
                    text: label,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  TextSpan(text: ' $value'),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
