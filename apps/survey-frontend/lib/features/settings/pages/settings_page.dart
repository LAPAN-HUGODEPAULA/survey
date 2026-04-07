/// Lets a screener choose the active survey and generate a prepared access link.
///
/// Prepared links lock the screener identity and survey selection so assisted
/// sessions can start with minimal setup friction.
library;

import 'dart:ui' as ui;

import 'package:design_system_flutter/widgets.dart';
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
import 'package:survey_app/shared/widgets/screener_navigation_app_bar.dart';

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
  DsFeedbackMessage? _pageFeedback;
  List<String> _validationErrors = const <String>[];

  @override
  void initState() {
    super.initState();
    final settings = Provider.of<AppSettings>(context, listen: false);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      settings.loadAvailableSurveys();
    });
  }

  /// Opens the read-only survey details dialog without leaving settings.
  void _showSurveyDetails(Survey survey) {
    Navigator.push(
      context,
      MaterialPageRoute<void>(
        builder: (context) => SurveyDetailsPage(survey: survey),
      ),
    );
  }

  /// Requests a backend token that pre-binds the screener and survey choice.
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
      _pageFeedback = null;
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
      _showMessage(
        DsFeedbackMessage(
          severity: DsStatusType.success,
          title: 'Link preparado',
          message: 'O link foi gerado com sucesso.',
        ),
      );
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
    _showMessage(
      const DsFeedbackMessage(
        severity: DsStatusType.success,
        title: 'Link copiado',
        message: 'O link preparado foi copiado para a área de transferência.',
      ),
    );
  }

  Future<void> _saveLinkText(String url) async {
    await saveTextDownload(
      fileName: 'questionario_preparado.txt',
      content: 'Link do questionário preparado:\n$url\n',
    );
    _showMessage(
      const DsFeedbackMessage(
        severity: DsStatusType.success,
        title: 'Arquivo salvo',
        message: 'O arquivo de texto do link preparado foi salvo.',
      ),
    );
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
    _showMessage(
      const DsFeedbackMessage(
        severity: DsStatusType.success,
        title: 'QR Code salvo',
        message: 'A imagem do QR Code foi salva em PNG.',
      ),
    );
  }

  void _showMessage(DsFeedbackMessage feedback) {
    showDsFeedbackSnackBar(
      context,
      feedback: feedback,
      duration: const Duration(seconds: 2),
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
      setState(() {
        _validationErrors = validationErrors;
        _pageFeedback = const DsFeedbackMessage(
          severity: DsStatusType.error,
          title: 'Revise as configurações',
          message: 'Corrija os campos destacados antes de continuar.',
        );
      });
      return;
    }

    setState(() {
      _validationErrors = const <String>[];
      _pageFeedback = DsFeedbackMessage(
        severity: DsStatusType.success,
        title: 'Configurações salvas',
        message: 'As configurações foram salvas com sucesso.',
      );
    });

    _showMessage(
      const DsFeedbackMessage(
        severity: DsStatusType.success,
        title: 'Configurações salvas',
        message: 'As configurações foram salvas com sucesso.',
      ),
    );

    Future.delayed(const Duration(milliseconds: 200), () {
      if (!mounted) return;
      context.go('/');
    });
  }

  Widget _buildPageFeedback() {
    if (_validationErrors.isNotEmpty) {
      return DsValidationSummary(
        errors: _validationErrors,
        description:
            'Corrija os itens abaixo e também os campos destacados no formulário.',
        secondaryAction: DsFeedbackAction(
          label: 'Fechar',
          onPressed: () {
            setState(() {
              _validationErrors = const <String>[];
              _pageFeedback = null;
            });
          },
        ),
      );
    }

    if (_pageFeedback == null) {
      return const SizedBox.shrink();
    }

    return DsFeedbackBanner(
      feedback: DsFeedbackMessage(
        severity: _pageFeedback!.severity,
        title: _pageFeedback!.title,
        message: _pageFeedback!.message,
        dismissible: true,
        onDismiss: () => setState(() => _pageFeedback = null),
      ),
      margin: EdgeInsets.zero,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AppSettings>(
      builder: (context, settings, child) {
        final generatedUrl = _generatedLink == null
            ? null
            : _accessLinkRepository.buildShareableUrl(_generatedLink!.token);
        final theme = Theme.of(context);

        Widget surveySelectionChild;
        if (settings.isLoadingSurveys) {
          surveySelectionChild = const Center(
            child: CircularProgressIndicator(),
          );
        } else if (settings.availableSurveys.isEmpty) {
          surveySelectionChild = DsFocusFrame(
            child: Text(
              'Nenhum questionário foi encontrado no servidor. Verifique se o backend está em execução.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          );
        } else {
          surveySelectionChild = Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              DropdownButtonFormField<String>(
                key: ValueKey(settings.selectedSurveyId),
                initialValue: settings.selectedSurveyId,
                isExpanded: true,
                decoration: const InputDecoration(
                  labelText: 'Questionário selecionado *',
                ),
                items: settings.availableSurveys.map<DropdownMenuItem<String>>((
                  survey,
                ) {
                  final displayName = survey.surveyDisplayName.isNotEmpty
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
              DsOutlinedButton(
                label: 'Ver detalhes do questionário',
                icon: Icons.info_outline,
                onPressed: settings.selectedSurvey != null
                    ? () => _showSurveyDetails(settings.selectedSurvey!)
                    : null,
              ),
            ],
          );
        }

        return DsScaffold(
          appBar: const ScreenerNavigationAppBar(
            currentRoute: '/settings',
            title: Text('Configurações'),
          ),
          scrollable: true,
          body: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 700),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (_pageFeedback != null ||
                        _validationErrors.isNotEmpty) ...[
                      _buildPageFeedback(),
                      const SizedBox(height: 24),
                    ],
                    if (settings.isLockedAssessmentMode) ...[
                      _buildLockedModeCard(settings),
                      const SizedBox(height: 24),
                    ],
                    DsSection(
                      eyebrow: 'Questionário ativo',
                      title: 'Seleção do questionário',
                      subtitle: settings.isLockedAssessmentMode
                          ? 'Este questionário foi preparado com antecedência e não pode ser alterado nesta sessão.'
                          : 'Selecione qual questionário será aplicado nesta triagem.',
                      child: surveySelectionChild,
                    ),
                    const SizedBox(height: 24),
                    if (!settings.isLockedAssessmentMode) ...[
                      _buildPreparedLinkSection(settings, generatedUrl),
                      const SizedBox(height: 24),
                    ],
                    DsPanel(
                      tone: DsPanelTone.high,
                      backgroundColor: theme.colorScheme.primaryContainer,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.info_outline,
                                color: theme.colorScheme.onPrimaryContainer,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Status das configurações',
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w700,
                                  color: theme.colorScheme.onPrimaryContainer,
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
                            foregroundColor:
                                theme.colorScheme.onPrimaryContainer,
                          ),
                          _buildStatusItem(
                            'Questionários disponíveis:',
                            '${settings.availableSurveys.length} encontrado(s)',
                            settings.availableSurveys.isNotEmpty,
                            foregroundColor:
                                theme.colorScheme.onPrimaryContainer,
                          ),
                          _buildStatusItem(
                            'Modo preparado:',
                            settings.isLockedAssessmentMode
                                ? 'Ativo'
                                : 'Desativado',
                            true,
                            foregroundColor:
                                theme.colorScheme.onPrimaryContainer,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    DsFocusFrame(
                      child: Row(
                        children: [
                          Icon(
                            Icons.info_outline,
                            color: theme.colorScheme.primary,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              settings.isLockedAssessmentMode
                                  ? 'Esta sessão foi aberta com um link preparado. As configurações ficam protegidas para evitar alterações acidentais.'
                                  : 'Campos marcados com (*) são obrigatórios e serão validados antes de salvar.',
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: DsFilledButton(
                        label: 'Salvar e voltar',
                        onPressed: _submitForm,
                        size: DsButtonSize.large,
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
    return DsPanel(
      tone: DsPanelTone.high,
      backgroundColor: Theme.of(context).colorScheme.primaryContainer,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Sessão preparada',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
              color: Theme.of(context).colorScheme.onPrimaryContainer,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Este acesso foi preparado para ${settings.screenerDisplayName} com o questionário ${settings.selectedSurveyName}.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onPrimaryContainer,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPreparedLinkSection(AppSettings settings, String? generatedUrl) {
    final canGenerate = settings.isLoggedIn && settings.selectedSurvey != null;
    final theme = Theme.of(context);

    return DsSection(
      eyebrow: 'Link preparado',
      title: 'Compartilhamento assistido',
      subtitle:
          'Gere um link direto com avaliador e questionário já preparados para facilitar o uso por pessoas com pouca familiaridade tecnológica.',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            canGenerate
                ? 'O link será criado para ${settings.screenerDisplayName} e o questionário ${settings.selectedSurveyName}.'
                : 'Entre com um avaliador e selecione um questionário para gerar o link preparado.',
            style: theme.textTheme.bodyMedium,
          ),
          const SizedBox(height: 16),
          DsFilledButton(
            label: 'Gerar link do questionário',
            icon: Icons.link,
            onPressed: canGenerate && !_isGeneratingLink
                ? _generatePreparedLink
                : null,
            loading: _isGeneratingLink,
          ),
          if (_generationError != null) ...[
            const SizedBox(height: 12),
            Text(
              _generationError!,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.error,
              ),
            ),
          ],
          if (generatedUrl != null && _generatedLink != null) ...[
            const SizedBox(height: 16),
            DsFocusFrame(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SelectableText(
                    generatedUrl,
                    style: theme.textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 16),
                  Center(
                    child: QrImageView(
                      data: generatedUrl,
                      size: 180,
                      backgroundColor: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                DsOutlinedButton(
                  label: 'Copiar link',
                  icon: Icons.copy,
                  onPressed: () => _copyLink(generatedUrl),
                ),
                DsOutlinedButton(
                  label: 'Salvar texto',
                  icon: Icons.description_outlined,
                  onPressed: () => _saveLinkText(generatedUrl),
                ),
                DsOutlinedButton(
                  label: 'Salvar QR em PNG',
                  icon: Icons.qr_code_2,
                  onPressed: () => _saveQrPng(generatedUrl),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildStatusItem(
    String label,
    String value,
    bool isValid, {
    Color? foregroundColor,
  }) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(
            isValid ? Icons.check_circle : Icons.cancel,
            color: isValid
                ? theme.colorScheme.tertiary
                : theme.colorScheme.error,
            size: 20,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: RichText(
              text: TextSpan(
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: foregroundColor ?? theme.colorScheme.onSurface,
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
