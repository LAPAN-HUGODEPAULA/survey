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
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:path/path.dart' as path;
import 'package:provider/provider.dart';
import 'package:runtime_agent_access_points/runtime_agent_access_points.dart';
import 'package:survey_app/core/models/agent_response.dart';
import 'package:survey_app/core/models/survey/question.dart';
import 'package:survey_app/core/models/survey/survey.dart';
import 'package:survey_app/core/models/survey_response.dart';
import 'package:survey_app/core/providers/app_settings.dart';
import 'package:survey_app/core/repositories/survey_repository.dart';
import 'package:survey_app/shared/widgets/assessment_flow_stepper.dart';
import 'package:survey_responses_shared/answer.dart' as shared;
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

enum AssessmentHandoffState { registering, registered, analyzing, ready }

const _radarPalette = <Color>[
  Color(0xFFEF5350),
  Color(0xFFFFA726),
  Color(0xFF66BB6A),
  Color(0xFF42A5F5),
  Color(0xFF7E57C2),
  Color(0xFF26A69A),
  Color(0xFFFFEB3B),
];

const _radarOptionScores = <String, double>{
  'quase nunca': 0.0,
  'ocasionalmente': 1.0,
  'frequentemente': 2.0,
  'quase sempre': 3.0,
};

Color _withOpacity(Color base, double opacity) {
  final alpha = (opacity.clamp(0.0, 1.0) * 255).clamp(0.0, 255.0);
  return base.withValues(alpha: alpha);
}

Color _darken(Color color, [double amount = 0.42]) {
  final hsl = HSLColor.fromColor(color);
  final lightness = (hsl.lightness - amount).clamp(0.0, 1.0);
  return hsl.withLightness(lightness).toColor();
}

class _ThankYouPageState extends State<ThankYouPage> {
  AssessmentHandoffState _handoffState = AssessmentHandoffState.registering;
  bool _saveSuccess = false;
  String? _saveError;
  String? _savedFilePath;
  String? _savedResponseId;
  AgentResponse? _agentResponse;
  bool _isAgentLoading = false;
  bool _agentRetryable = false;
  AIProgress? _aiProgress;
  ReportDocument? _demoReport;
  String? _demoReportError;
  final SurveyRepository _surveyRepository = SurveyRepository();

  Future<void> _showRegisteredStep() async {
    if (!mounted) {
      return;
    }
    setState(() {
      _handoffState = AssessmentHandoffState.registered;
    });
    await Future<void>.delayed(const Duration(milliseconds: 350));
    if (!mounted || _agentResponse != null) {
      return;
    }
    setState(() {
      _handoffState = AssessmentHandoffState.analyzing;
    });
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _submitResponse();
    });
  }

  List<shared.Answer> _buildAnswers() {
    final answers = <shared.Answer>[];

    for (int i = 0; i < widget.surveyAnswers.length; i++) {
      if (i < widget.surveyQuestions.length) {
        answers.add(
          shared.Answer(
            id: widget.surveyQuestions[i].id,
            answer: widget.surveyAnswers[i],
          ),
        );
      }
    }

    return answers;
  }

  List<_AnswerSummary> _buildSummaries() {
    final summaries = <_AnswerSummary>[];
    for (var index = 0; index < widget.surveyQuestions.length; index++) {
      final question = widget.surveyQuestions[index];
      final answer = index < widget.surveyAnswers.length
          ? widget.surveyAnswers[index]
          : '';
      final label = 'Q${index + 1}';
      summaries.add(
        _AnswerSummary(
          questionText: question.questionText,
          label: label,
          answerText: answer.isNotEmpty ? answer : 'Sem resposta',
          value: _resolveRadarScore(question, answer),
        ),
      );
    }
    return summaries;
  }

  double _resolveRadarScore(Question question, String answer) {
    final normalizedAnswer = answer.trim().toLowerCase();
    final mapped = _radarOptionScores[normalizedAnswer];
    if (mapped != null) {
      return mapped;
    }

    final index = question.answers.indexWhere(
      (candidate) => candidate.trim().toLowerCase() == normalizedAnswer,
    );
    if (index < 0) {
      return 0.0;
    }
    if (question.answers.length <= 1) {
      return 0.0;
    }
    if (question.answers.length == 4) {
      return index.clamp(0, 3).toDouble();
    }
    return (index * (3 / (question.answers.length - 1))).clamp(0.0, 3.0);
  }

  @override
  void dispose() {
    _surveyRepository.dispose();
    super.dispose();
  }

  Future<void> _submitResponse() async {
    setState(() {
      _saveError = null;
      _handoffState = AssessmentHandoffState.registering;
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
        accessPointKey: RuntimeAccessPointCatalog
            .surveyFrontendThankYouAutoAnalysis
            .accessPointKey,
        patient: patient,
        answers: _buildAnswers(),
      );

      final saved = await _surveyRepository.submitResponse(surveyResponse);
      setState(() {
        _saveSuccess = true;
        _savedResponseId = saved.id;
        _agentResponse = saved.agentResponse;
        _isAgentLoading = saved.agentResponse == null;
        _aiProgress = saved.agentResponse?.aiProgress;
        if (saved.agentResponse != null) {
          _handoffState = AssessmentHandoffState.ready;
        }
      });
      if (saved.agentResponse == null) {
        await _showRegisteredStep();
      }
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
        _isAgentLoading = false;
        _aiProgress = agentResponse.aiProgress;
        _handoffState = AssessmentHandoffState.ready;
      });
      return;
    }

    try {
      final response = await _startAndPollAgentResponse(surveyResponse);
      if (!mounted) {
        return;
      }
      setState(() {
        _agentResponse = response;
        _isAgentLoading = false;
        _aiProgress = response?.aiProgress;
        if (response != null) {
          _handoffState = AssessmentHandoffState.ready;
        }
      });
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Clinical writer fallback failed: $e');
      }
      if (mounted) {
        setState(() {
          _isAgentLoading = false;
          _agentRetryable = true;
          _saveError = 'Não foi possível concluir a análise automática agora.';
          _handoffState = AssessmentHandoffState.analyzing;
        });
      }
    }
  }

  Future<AgentResponse?> _startAndPollAgentResponse(
    SurveyResponse surveyResponse,
  ) async {
    final content = jsonEncode(surveyResponse.toJson());
    final taskStart = await _surveyRepository.startClinicalWriterTask(
      content,
      accessPointKey: surveyResponse.accessPointKey,
      surveyId: surveyResponse.surveyId,
    );
    final taskId =
        taskStart['taskId']?.toString() ?? taskStart['task_id']?.toString();
    if (taskId == null || taskId.isEmpty) {
      return _surveyRepository.processClinicalWriter(
        content,
        accessPointKey: surveyResponse.accessPointKey,
        surveyId: surveyResponse.surveyId,
      );
    }

    final startProgress = taskStart['aiProgress'] ?? taskStart['ai_progress'];
    if (startProgress is Map<String, dynamic> && mounted) {
      setState(() {
        _aiProgress = AIProgress.fromJson(startProgress);
      });
    }

    for (var attempt = 0; attempt < 120; attempt++) {
      await Future<void>.delayed(const Duration(seconds: 1));
      final statusPayload = await _surveyRepository.getClinicalWriterTaskStatus(
        taskId,
      );
      final progressPayload =
          statusPayload['aiProgress'] ?? statusPayload['ai_progress'];
      if (progressPayload is Map<String, dynamic> && mounted) {
        setState(() {
          _aiProgress = AIProgress.fromJson(progressPayload);
        });
      }
      final status = statusPayload['status']?.toString() ?? '';
      if (status == 'completed' &&
          statusPayload['result'] is Map<String, dynamic>) {
        return AgentResponse.fromJson(
          statusPayload['result'] as Map<String, dynamic>,
        );
      }
      if (status == 'failed') {
        final errorPayload = statusPayload['error'];
        _agentRetryable = false;
        if (errorPayload is Map<String, dynamic>) {
          _agentRetryable = errorPayload['retryable'] as bool? ?? false;
          _saveError =
              errorPayload['userMessage']?.toString() ??
              'Não conseguimos gerar a análise automática para este caso.';
        } else {
          _saveError =
              'Não conseguimos gerar a análise automática para este caso.';
        }
        return null;
      }
    }

    _agentRetryable = true;
    _saveError =
        'A análise está demorando mais que o esperado. Tente novamente em instantes.';
    return null;
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
        accessPointKey: RuntimeAccessPointCatalog
            .surveyFrontendThankYouAutoAnalysis
            .accessPointKey,
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
        _saveSuccess = true;
        _savedFilePath = filePath;
        _saveError =
            'Não foi possível enviar para o servidor (${originalError.toString()}). '
            'As respostas foram salvas localmente.';
        _handoffState = AssessmentHandoffState.registered;
      });
    } catch (fallbackError) {
      setState(() {
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

    showDsToast(
      context,
      feedback: DsFeedbackMessage(
        severity: DsStatusType.success,
        title: 'Exportação concluída',
        message: result,
      ),
    );
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
    final tone = DsEmotionalToneProvider.resolveTokens(context);
    final summaries = _buildSummaries();
    const maxValue = 3;
    final values = summaries.map((item) => item.value).toList(growable: false);
    final labels = summaries.map((item) => item.label).toList(growable: false);
    final reportDocument = _agentResponse == null
        ? null
        : _resolveReportDocument(settings, _agentResponse!);
    final theme = Theme.of(context);
    final displayName = widget.survey.surveyDisplayName.isNotEmpty
        ? widget.survey.surveyDisplayName
        : widget.survey.surveyName;
    final handoffState = _handoffState;

    return DsScaffold(
      title: 'Avaliação finalizada',
      subtitle: 'Revise o envio e os próximos passos clínicos com segurança.',
      onBack: () => Navigator.of(context).pop(),
      backLabel: 'Voltar para o questionário',
      userName: settings.screenerDisplayName,
      showAmbientGreeting: true,
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 900),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const AssessmentFlowStepper(
                  currentStep: AssessmentFlowStep.relatorio,
                ),
                if (_saveError != null && !_saveSuccess) ...[
                  Icon(
                    Icons.error_outline,
                    color: Theme.of(context).colorScheme.error,
                    size: 100,
                  ),
                  const SizedBox(height: 16),
                  DsMessageBanner(
                    feedback: DsFeedbackMessage(
                      severity: DsStatusType.error,
                      title: 'Falha ao registrar respostas',
                      message: _saveError!,
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
                DsHandoffStatusRow(
                  stage: switch (handoffState) {
                    AssessmentHandoffState.registering =>
                      DsHandoffStage.registered,
                    AssessmentHandoffState.registered =>
                      DsHandoffStage.registered,
                    AssessmentHandoffState.analyzing =>
                      DsHandoffStage.analyzing,
                    AssessmentHandoffState.ready => DsHandoffStage.ready,
                  },
                  liveRegion: true,
                ),
                const SizedBox(height: 16),
                if (_saveSuccess) ...[
                  DsMessageBanner(
                    feedback: DsFeedbackMessage(
                      severity: DsStatusType.success,
                      title: DsHandoffCopy.registeredLabel,
                      message: tone.completionAcknowledgement,
                    ),
                    footer: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Questionário: $displayName'),
                        if (_savedResponseId != null) ...[
                          const SizedBox(height: 8),
                          Text(DsHandoffCopy.referenceIdContext),
                          const SizedBox(height: 8),
                          SelectableText(
                            _savedResponseId!,
                            style: theme.textTheme.bodySmall?.copyWith(
                              fontFamily: 'monospace',
                            ),
                          ),
                        ] else if (_savedFilePath != null) ...[
                          const SizedBox(height: 8),
                          Text('Arquivo salvo em: $_savedFilePath'),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
                DsSection(
                  eyebrow: 'Resumo visual',
                  title: 'Radar das respostas',
                  subtitle:
                      'Compare as respostas e revise o que foi registrado em cada pergunta.',
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        height: 280,
                        child: values.isEmpty
                            ? const Center(
                                child: Text('Sem respostas para exibir.'),
                              )
                            : values.length < 3
                            ? const Center(
                                child: Text(
                                  'O radar será exibido quando houver pelo menos 3 respostas.',
                                ),
                              )
                            : _SurveyRadarChart(
                                values: values,
                                maxValue: maxValue,
                                labels: labels,
                              ),
                      ),
                      if (labels.isNotEmpty) ...[
                        const SizedBox(height: 12),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: List.generate(labels.length, (index) {
                            final color =
                                _radarPalette[index % _radarPalette.length];
                            return _RadarLegendChip(
                              label: labels[index],
                              color: color,
                            );
                          }),
                        ),
                      ],
                      const SizedBox(height: 24),
                      Text(
                        'Resumo das respostas',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 12),
                      for (final summary in summaries)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 16),
                          child: DsFocusFrame(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  summary.label,
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    fontWeight: FontWeight.w600,
                                    color: theme.colorScheme.primary,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  summary.questionText,
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  summary.answerText,
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    color: theme.colorScheme.onSurfaceVariant,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                if (handoffState == AssessmentHandoffState.analyzing) ...[
                  DsSection(
                    tone: DsPanelTone.high,
                    padding: const EdgeInsets.all(16),
                    title: DsHandoffCopy.analyzingLabel,
                    subtitle:
                        'As respostas já foram registradas. Agora estamos finalizando a leitura clínica inicial.',
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (_isAgentLoading)
                          Row(
                            children: [
                              const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2.4,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  _aiProgress?.stageLabel ??
                                      DsHandoffCopy.analyzingLabel,
                                  style: theme.textTheme.bodyMedium,
                                ),
                              ),
                            ],
                          ),
                        if (!_isAgentLoading && _saveError != null)
                          DsInlineMessage(
                            feedback: DsFeedbackMessage(
                              severity: _agentRetryable
                                  ? DsStatusType.warning
                                  : DsStatusType.error,
                              title:
                                  'Não foi possível concluir a análise automática agora.',
                              message: _saveError!,
                              primaryAction: _agentRetryable
                                  ? DsFeedbackAction(
                                      label: 'Tentar novamente',
                                      onPressed: _submitResponse,
                                      icon: Icons.refresh,
                                    )
                                  : null,
                            ),
                            margin: EdgeInsets.zero,
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
                if (handoffState == AssessmentHandoffState.ready &&
                    reportDocument != null) ...[
                  DsClinicalContentCard(
                    title: DsHandoffCopy.readyLabel,
                    subtitle:
                        'O conteúdo clínico abaixo está disponível para revisão, impressão ou exportação.',
                    child: Text(
                      reportDocument.toPlainText(),
                      maxLines: 8,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodyMedium,
                    ),
                  ),
                  const SizedBox(height: 24),
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
                  DsOutlinedButton(
                    onPressed: _loadDemoReport,
                    icon: Icons.visibility_outlined,
                    label: 'Carregar relatório de exemplo',
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
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w700,
                                color: theme.colorScheme.onSecondaryContainer,
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
                              color: theme.colorScheme.onSurface,
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
                DsFilledButton(
                  label: 'Iniciar nova avaliação',
                  onPressed: () {
                    // Clear shared patient state before returning to the first screen.
                    final settings = Provider.of<AppSettings>(
                      context,
                      listen: false,
                    );
                    settings.clearPatientData();

                    Navigator.of(context).popUntil((route) => route.isFirst);
                  },
                  size: DsButtonSize.large,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _RadarLegendChip extends StatelessWidget {
  const _RadarLegendChip({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final badgeColor = _darken(color, 0.44);
    return DsPanel(
      tone: DsPanelTone.high,
      backgroundColor: badgeColor,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      borderRadius: BorderRadius.circular(16),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: Colors.white),
          ),
        ],
      ),
    );
  }
}

class _SurveyRadarChart extends StatelessWidget {
  const _SurveyRadarChart({
    required this.values,
    required this.maxValue,
    required this.labels,
  });

  final List<double> values;
  final int maxValue;
  final List<String> labels;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final borderColor = theme.colorScheme.primary;
    final fillColor = _withOpacity(borderColor, 0.25);

    return RadarChart(
      RadarChartData(
        radarBorderData: BorderSide(
          color: _withOpacity(theme.colorScheme.onSurface, 0.3),
        ),
        dataSets: [
          RadarDataSet(
            fillColor: fillColor,
            borderColor: borderColor,
            borderWidth: 2,
            entryRadius: 3,
            dataEntries: values
                .map((value) => RadarEntry(value: value))
                .toList(),
          ),
        ],
        titleTextStyle: theme.textTheme.bodySmall?.copyWith(
          color: Colors.white,
          fontWeight: FontWeight.w700,
        ),
        getTitle: (int index, double angle) {
          final label = labels.isEmpty ? 'Q${index + 1}' : labels[index];
          return RadarChartTitle(text: label, angle: angle);
        },
        titlePositionPercentageOffset: 0.15,
        tickCount: maxValue,
        ticksTextStyle: theme.textTheme.labelSmall?.copyWith(
          color: const Color(0xFFFDF7F0),
          fontWeight: FontWeight.w700,
        ),
        gridBorderData: BorderSide(
          color: theme.colorScheme.outlineVariant,
          width: 1,
        ),
      ),
      duration: const Duration(milliseconds: 400),
    );
  }
}

class _AnswerSummary {
  const _AnswerSummary({
    required this.questionText,
    required this.label,
    required this.answerText,
    required this.value,
  });

  final String questionText;
  final String label;
  final String answerText;
  final double value;
}
