/// Final screen shown after the respondent completes the survey.
///
/// The page persists responses, optionally renders final notes, and offers
/// export actions once the submission lifecycle has finished.
library;

import 'dart:convert';
import 'dart:io';
import 'dart:js_interop';

import 'package:design_system_flutter/report/report_models.dart';
import 'package:design_system_flutter/report/report_view.dart';
import 'package:design_system_flutter/widgets.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:path/path.dart' as path;
import 'package:provider/provider.dart';
import 'package:survey_app/core/models/agent_response.dart';
import 'package:survey_app/core/models/survey/question.dart';
import 'package:survey_app/core/models/survey/survey.dart';
import 'package:survey_app/core/models/survey_response.dart';
import 'package:survey_app/core/providers/app_settings.dart';
import 'package:survey_app/core/repositories/survey_repository.dart';
import 'package:web/web.dart' as web;

/// Confirms submission state and handles post-survey exports.
class ThankYouPage extends StatefulWidget {
  /// Creates the terminal survey screen with the completed response payload.
  const ThankYouPage({
    super.key,
    required this.survey,
    required this.surveyAnswers,
    required this.surveyQuestions,
  });
  final Survey survey;

  /// Ordered answers captured during the survey flow.
  final List<String> surveyAnswers;

  /// Question definitions used to rebuild the exported answer structure.
  final List<Question> surveyQuestions;

  @override
  State<ThankYouPage> createState() => _ThankYouPageState();
}

class _ThankYouPageState extends State<ThankYouPage> {
  bool _isSaving = false;
  bool _saveSuccess = false;
  String? _saveError;
  String? _savedFilePath;
  String? _savedResponseId;
  AgentResponse? _agentResponse;
  String? _selectedPromptKey;
  ReportDocument? _demoReport;
  String? _demoReportError;
  final SurveyRepository _surveyRepository = SurveyRepository();

  @override
  void initState() {
    super.initState();
    final promptAssociations = widget.survey.promptAssociations;
    if (promptAssociations.length <= 1) {
      _selectedPromptKey = promptAssociations.isEmpty
          ? null
          : promptAssociations.first.promptKey;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _submitResponse();
      });
    }
  }

  List<Answer> _buildAnswers() {
    final answers = <Answer>[];

    for (int i = 0; i < widget.surveyAnswers.length; i++) {
      if (i < widget.surveyQuestions.length) {
        answers.add(
          Answer(
            id: widget.surveyQuestions[i].id,
            answer: widget.surveyAnswers[i],
          ),
        );
      }
    }

    return answers;
  }

  @override
  void dispose() {
    _surveyRepository.dispose();
    super.dispose();
  }

  Future<void> _submitResponse() async {
    setState(() {
      _isSaving = true;
      _saveError = null;
    });

    try {
      final settings = Provider.of<AppSettings>(context, listen: false);

      final patient = settings.patient.withClinicalData(
        familyHistory: settings.clinicalData.familyHistory,
        socialHistory: settings.clinicalData.socialData,
        medicalHistory: settings.clinicalData.medicalHistory,
        medicationHistory: settings.clinicalData.medicationHistory,
      );

      final surveyResponse = SurveyResponse(
        surveyId: widget.survey.id,
        creatorId: widget.survey.creatorId,
        testDate: DateTime.now(),
        screenerId: settings.screenerId,
        accessLinkToken: settings.accessLinkToken,
        promptKey: _selectedPromptKey,
        patient: patient,
        answers: _buildAnswers(),
      );

      final saved = await _surveyRepository.submitResponse(surveyResponse);
      setState(() {
        _isSaving = false;
        _saveSuccess = true;
        _savedResponseId = saved.id;
        _agentResponse = saved.agentResponse;
      });
      await _maybeFetchAgentResponse(surveyResponse, saved.agentResponse);
    } catch (e) {
      await _fallbackToLocalSave(e);
    }
  }

  Future<void> _maybeFetchAgentResponse(
    SurveyResponse surveyResponse,
    AgentResponse? agentResponse,
  ) async {
    if (!mounted) {
      return;
    }

    if (agentResponse != null) {
      setState(() {
        _agentResponse = agentResponse;
      });
      return;
    }

    try {
      final content = jsonEncode(surveyResponse.toJson());
      final response = await _surveyRepository.processClinicalWriter(
        content,
        promptKey: surveyResponse.promptKey,
      );
      if (!mounted) {
        return;
      }
      setState(() {
        _agentResponse = response;
      });
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Clinical writer fallback failed: $e');
      }
    }
  }

  Future<void> _fallbackToLocalSave(Object originalError) async {
    try {
      final settings = Provider.of<AppSettings>(context, listen: false);
      final surveyResponse = SurveyResponse(
        surveyId: widget.survey.id,
        creatorId: widget.survey.creatorId,
        testDate: DateTime.now(),
        screenerId: settings.screenerId,
        accessLinkToken: settings.accessLinkToken,
        promptKey: _selectedPromptKey,
        patient: settings.patient.withClinicalData(
          familyHistory: settings.clinicalData.familyHistory,
          socialHistory: settings.clinicalData.socialData,
          medicalHistory: settings.clinicalData.medicalHistory,
          medicationHistory: settings.clinicalData.medicationHistory,
        ),
        answers: _buildAnswers(),
      );

      final fileName = _generateFileName(
        widget.survey.id,
        settings.patient.name,
      );
      final filePath = await _writeResponseFile(
        fileName,
        surveyResponse.toJson(),
      );

      setState(() {
        _isSaving = false;
        _saveSuccess = true;
        _savedFilePath = filePath;
        _saveError =
            'Não foi possível enviar para o servidor (${originalError.toString()}). '
            'As respostas foram salvas localmente.';
      });
    } catch (fallbackError) {
      setState(() {
        _isSaving = false;
        _saveError =
            'Erro ao enviar para o servidor: $originalError\n'
            'Falha ao salvar localmente: $fallbackError';
      });
    }
  }

  /// Builds a stable export filename from the survey id and patient name.
  String _generateFileName(String surveyId, String patientName) {
    final cleanName = patientName
        .toLowerCase()
        .replaceAll(' ', '_')
        .replaceAll(RegExp(r'[^\w\s]'), '');
    return '${surveyId}_$cleanName.json';
  }

  /// Writes the response export using the best storage option per platform.
  Future<String> _writeResponseFile(
    String fileName,
    Map<String, dynamic> data,
  ) async {
    final jsonString = const JsonEncoder.withIndent('    ').convert(data);

    try {
      if (kIsWeb) {
        // Browsers can only persist the export through a download flow.
        return await _saveToWebBrowser(fileName, jsonString);
      } else {
        // Native targets can write to a temporary local directory.
        return await _saveToNativeDirectory(fileName, jsonString);
      }
    } catch (e) {
      // Fall back to the simplest available storage path before surfacing an error.
      return await _saveWithFallback(fileName, jsonString);
    }
  }

  /// Starts a browser download for web builds.
  Future<String> _saveToWebBrowser(String fileName, String jsonString) async {
    try {
      // Use a Blob URL so the browser treats the generated JSON as a file.
      final parts = <web.BlobPart>[jsonString.toJS as web.BlobPart].toJS;
      final blob = web.Blob(
        parts,
        web.BlobPropertyBag(type: 'application/json'),
      );
      final url = web.URL.createObjectURL(blob);
      final anchor = web.HTMLAnchorElement()
        ..href = url
        ..download = fileName
        ..style.display = 'none';

      web.document.body?.appendChild(anchor);
      anchor.click();
      anchor.remove();
      web.URL.revokeObjectURL(url);

      return 'Download iniciado: $fileName';
    } catch (e) {
      throw Exception('Erro ao iniciar download: $e');
    }
  }

  /// Stores the generated JSON in a temporary native directory.
  Future<String> _saveToNativeDirectory(
    String fileName,
    String jsonString,
  ) async {
    try {
      // Keep exports in a dedicated temp subdirectory to avoid collisions.
      final tempDir = Directory.systemTemp;
      final responsesDir = Directory(
        path.join(tempDir.path, 'survey_responses'),
      );

      if (!await responsesDir.exists()) {
        await responsesDir.create(recursive: true);
      }

      final file = File(path.join(responsesDir.path, fileName));
      await file.writeAsString(jsonString);

      return file.path;
    } catch (e) {
      // Fallback to temp directory without subdirectory
      final tempDir = Directory.systemTemp;
      final file = File(path.join(tempDir.path, fileName));
      await file.writeAsString(jsonString);

      return file.path;
    }
  }

  /// Fallback method for saving files.
  Future<String> _saveWithFallback(String fileName, String jsonString) async {
    if (kIsWeb) {
      // Web fallback - try to save to browser storage or show data
      try {
        web.window.localStorage.setItem(
          'survey_response_$fileName',
          jsonString,
        );
        return 'Salvo no armazenamento do navegador: $fileName';
      } catch (e) {
        return 'Dados preparados (não foi possível salvar): $fileName';
      }
    } else {
      // Native fallback - just indicate the data is ready
      return 'Dados preparados para salvamento: $fileName';
    }
  }

  Future<void> _loadDemoReport() async {
    try {
      final raw = await rootBundle.loadString('assets/data/report_demo.json');
      final json = jsonDecode(raw) as Map<String, dynamic>;
      if (!mounted) {
        return;
      }
      setState(() {
        _demoReport = ReportDocument.fromJson(json);
        _demoReportError = null;
      });
    } catch (e) {
      if (!mounted) {
        return;
      }
      setState(() {
        _demoReportError = 'Falha ao carregar relatório de exemplo.';
      });
    }
  }

  ReportDocument? _resolveReportDocument(
    AppSettings settings,
    AgentResponse response,
  ) {
    final errorMessage = response.errorMessage?.trim();
    if (errorMessage != null && errorMessage.isNotEmpty) {
      return ReportDocument.fromError(errorMessage);
    }

    if (response.report != null) {
      return response.report;
    }

    final medicalRecord = response.medicalRecord?.trim();
    if (medicalRecord != null && medicalRecord.isNotEmpty) {
      return ReportDocument.fromPlainText(
        text: medicalRecord,
        title: 'Relatório de Triagem Sensorial',
        subtitle: settings.isLoggedIn
            ? 'Para: ${settings.screenerDisplayName}'
            : 'Para: Especialista responsável',
        patient: ReportPatientInfo(
          name: settings.patient.name,
          reference: _savedResponseId,
          birthDate: settings.patient.birthDate,
          sex: settings.patient.gender,
        ),
      );
    }

    return null;
  }

  String _buildReportText(ReportDocument report) {
    return report.toPlainText(
      footer:
          'Gerado por LAPAN - Laboratório de Pesquisa Aplicada à Neurociência da Visão',
    );
  }

  String _generateReportFileName(String surveyId, String patientName) {
    final baseName = _generateFileName(
      surveyId,
      patientName,
    ).replaceAll('.json', '');
    return '${baseName}_relatorio.txt';
  }

  Future<void> _exportReport(
    AppSettings settings,
    ReportDocument report,
  ) async {
    final fileName = _generateReportFileName(
      widget.survey.id,
      settings.patient.name,
    );
    final reportText = _buildReportText(report);
    final result = await _writeReportFile(fileName, reportText);

    if (!mounted) {
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(result)));
  }

  void _printReport() {
    if (kIsWeb) {
      web.window.print();
    }
  }

  Future<String> _writeReportFile(String fileName, String content) async {
    try {
      if (kIsWeb) {
        return await _saveReportToWebBrowser(fileName, content);
      }
      return await _saveReportToNativeDirectory(fileName, content);
    } catch (e) {
      return 'Falha ao exportar relatório: $e';
    }
  }

  Future<String> _saveReportToWebBrowser(
    String fileName,
    String content,
  ) async {
    final parts = <web.BlobPart>[content.toJS as web.BlobPart].toJS;
    final blob = web.Blob(parts, web.BlobPropertyBag(type: 'text/plain'));
    final url = web.URL.createObjectURL(blob);
    final anchor = web.HTMLAnchorElement()
      ..href = url
      ..download = fileName
      ..style.display = 'none';

    web.document.body?.appendChild(anchor);
    anchor.click();
    anchor.remove();
    web.URL.revokeObjectURL(url);

    return 'Download iniciado: $fileName';
  }

  Future<String> _saveReportToNativeDirectory(
    String fileName,
    String content,
  ) async {
    final tempDir = Directory.systemTemp;
    final reportsDir = Directory(path.join(tempDir.path, 'survey_reports'));

    if (!await reportsDir.exists()) {
      await reportsDir.create(recursive: true);
    }

    final file = File(path.join(reportsDir.path, fileName));
    await file.writeAsString(content);
    return file.path;
  }

  @override
  Widget build(BuildContext context) {
    final settings = Provider.of<AppSettings>(context);
    final promptAssociations = widget.survey.promptAssociations;
    final reportDocument = _agentResponse == null
        ? null
        : _resolveReportDocument(settings, _agentResponse!);

    return DsScaffold(
      appBar: AppBar(
        title: const Text('Finalizado'),
        backgroundColor: Colors.orange,
        // Hide back navigation because the survey flow is complete here.
        automaticallyImplyLeading: false,
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 900),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Surface submission progress before the final confirmation UI.
                if (_isSaving) ...[
                  const CircularProgressIndicator(),
                  const SizedBox(height: 16),
                  const Text(
                    'Salvando respostas...',
                    style: TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 24),
                ] else if (!_saveSuccess && promptAssociations.length > 1) ...[
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: Theme.of(context).colorScheme.outline,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Escolha o tipo de relatório',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 8),
                        DropdownButtonFormField<String>(
                          initialValue: _selectedPromptKey,
                          decoration: const InputDecoration(
                            labelText: 'Resultado desejado',
                          ),
                          items: promptAssociations
                              .map(
                                (prompt) => DropdownMenuItem<String>(
                                  value: prompt.promptKey,
                                  child: Text(prompt.name),
                                ),
                              )
                              .toList(growable: false),
                          onChanged: (value) {
                            setState(() => _selectedPromptKey = value);
                          },
                        ),
                        const SizedBox(height: 12),
                        DsFilledButton(
                          label: 'Gerar relatório',
                          onPressed: _selectedPromptKey == null
                              ? null
                              : _submitResponse,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                ] else if (_saveSuccess) ...[
                  Icon(
                    Icons.check_circle_outline,
                    color: Theme.of(context).colorScheme.tertiary,
                    size: 100,
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(16.0),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.tertiaryContainer,
                      border: Border.all(
                        color: Theme.of(context).colorScheme.outline,
                      ),
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.save_alt,
                              color: Theme.of(
                                context,
                              ).colorScheme.onTertiaryContainer,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                _savedResponseId != null
                                    ? 'Respostas enviadas para o servidor com sucesso!'
                                    : 'Respostas salvas localmente.',
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Questionário: ${widget.survey.surveyDisplayName.isNotEmpty ? widget.survey.surveyDisplayName : widget.survey.surveyName}',
                          style: TextStyle(
                            fontSize: 14,
                            color: Theme.of(
                              context,
                            ).colorScheme.onTertiaryContainer,
                          ),
                        ),
                        if (_savedResponseId != null) ...[
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  'Protocolo da submissão: $_savedResponseId',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.onTertiaryContainer,
                                    fontFamily: 'monospace',
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ] else if (_savedFilePath != null) ...[
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  'Arquivo salvo em: $_savedFilePath',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.onTertiaryContainer,
                                    fontFamily: 'monospace',
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                        if (_saveError != null) ...[
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  _saveError!,
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.onTertiaryContainer,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  if (reportDocument != null) ...[
                    ReportView(
                      report: reportDocument,
                      footer:
                          'Gerado por LAPAN - Laboratório de Pesquisa Aplicada à Neurociência da Visão',
                      onPrint: kIsWeb ? _printReport : null,
                      onExport: () => _exportReport(settings, reportDocument),
                    ),
                    const SizedBox(height: 24),
                  ],
                  if (reportDocument == null && kDebugMode) ...[
                    OutlinedButton.icon(
                      onPressed: _loadDemoReport,
                      icon: const Icon(Icons.visibility_outlined),
                      label: const Text('Carregar relatorio de exemplo'),
                    ),
                    if (_demoReportError != null) ...[
                      const SizedBox(height: 8),
                      Text(
                        _demoReportError!,
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.error,
                        ),
                      ),
                    ],
                    if (_demoReport != null) ...[
                      const SizedBox(height: 16),
                      ReportView(
                        report: _demoReport!,
                        footer: 'Exemplo local - não representa dados reais.',
                      ),
                      const SizedBox(height: 24),
                    ],
                  ],
                ] else if (_saveError != null) ...[
                  Icon(
                    Icons.error_outline,
                    color: Theme.of(context).colorScheme.error,
                    size: 100,
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(16.0),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.errorContainer,
                      border: Border.all(
                        color: Theme.of(context).colorScheme.outline,
                      ),
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.warning,
                          color: Theme.of(context).colorScheme.onErrorContainer,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            _saveError!,
                            style: const TextStyle(fontSize: 14),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                ],

                // Keep the success icon visible unless a richer success panel already shows it.
                if (!_isSaving && _saveSuccess)
                  const SizedBox.shrink()
                else if (!_isSaving)
                  const Column(
                    children: [
                      Icon(
                        Icons.check_circle_outline,
                        color: Colors.orange,
                        size: 100,
                      ),
                      SizedBox(height: 24),
                    ],
                  ),

                // Primary confirmation message shown for every completion state.
                Text(
                  'Obrigado por responder!',
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),

                // Include the survey name when it helps disambiguate the completed form.
                Text(
                  widget.survey.surveyDisplayName.isNotEmpty
                      ? 'Suas respostas para o questionário "${widget.survey.surveyDisplayName}" foram registradas.'
                      : 'Suas respostas foram registradas com sucesso.',
                  style: const TextStyle(fontSize: 18),
                  textAlign: TextAlign.center,
                ),

                // Render optional survey-specific closing guidance supplied by the backend.
                if (widget.survey.finalNotes != null &&
                    widget.survey.finalNotes!.isNotEmpty) ...[
                  const SizedBox(height: 32),
                  Container(
                    padding: const EdgeInsets.all(20.0),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.secondaryContainer,
                      border: Border.all(
                        color: Theme.of(context).colorScheme.outline,
                      ),
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.info_outline,
                              color: Theme.of(
                                context,
                              ).colorScheme.onSecondaryContainer,
                              size: 24,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Informações Importantes',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Theme.of(
                                  context,
                                ).colorScheme.onSecondaryContainer,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Html(
                          data: widget.survey.finalNotes!,
                          style: {
                            "body": Style(
                              fontSize: FontSize(16.0),
                              lineHeight: const LineHeight(1.5),
                              color: Colors.black87,
                            ),
                            "p": Style(margin: Margins.only(bottom: 12.0)),
                            "strong": Style(fontWeight: FontWeight.bold),
                            "a": Style(
                              textDecoration: TextDecoration.underline,
                            ),
                            "br": Style(margin: Margins.only(bottom: 8.0)),
                          },
                        ),
                      ],
                    ),
                  ),
                ],

                const SizedBox(height: 40),

                // Let staff reset the workflow for the next respondent.
                ElevatedButton(
                  onPressed: () {
                    // Clear shared patient state before returning to the first screen.
                    final settings = Provider.of<AppSettings>(
                      context,
                      listen: false,
                    );
                    settings.clearPatientData();

                    Navigator.of(context).popUntil((route) => route.isFirst);
                  },
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    'Iniciar Nova Avaliação',
                    style: TextStyle(fontSize: 16),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
