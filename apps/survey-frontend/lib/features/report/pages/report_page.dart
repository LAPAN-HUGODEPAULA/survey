import 'dart:convert';
import 'dart:io';

import 'package:design_system_flutter/report/report_models.dart';
import 'package:design_system_flutter/report/report_view.dart';
import 'package:design_system_flutter/widgets.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
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

class ReportPage extends StatefulWidget {
  const ReportPage({
    super.key,
    required this.survey,
    required this.surveyAnswers,
    required this.surveyQuestions,
    required this.onRestartSurvey,
    this.surveyRepository,
  });

  final Survey survey;
  final List<String> surveyAnswers;
  final List<Question> surveyQuestions;
  final Future<void> Function() onRestartSurvey;
  final SurveyRepository? surveyRepository;

  @override
  State<ReportPage> createState() => _ReportPageState();
}

class _ReportPageState extends State<ReportPage> {
  static const int _maxPollingAttempts = 120;
  static const Duration _pollingDelay = Duration(seconds: 1);

  bool _isSaving = false;
  bool _saveSuccess = false;
  bool _isSendingReportEmail = false;
  String? _saveError;
  String? _reportError;
  String? _savedFilePath;
  String? _savedResponseId;
  AgentResponse? _agentResponse;
  late final SurveyRepository _surveyRepository;

  final Set<String> _documentLoadingKeys = <String>{};
  final Map<String, String> _generatedDocumentTexts = <String, String>{};
  final Map<String, String> _documentErrors = <String, String>{};

  @override
  void initState() {
    super.initState();
    _surveyRepository = widget.surveyRepository ?? SurveyRepository();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _submitResponse();
    });
  }

  @override
  void dispose() {
    _surveyRepository.dispose();
    super.dispose();
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

  SurveyResponse _composeSurveyResponse(
    AppSettings settings, {
    required String accessPointKey,
  }) {
    return SurveyResponse(
      surveyId: widget.survey.id,
      creatorId: widget.survey.creatorId,
      testDate: DateTime.now(),
      screenerId: settings.screenerId,
      accessLinkToken: settings.accessLinkToken,
      accessPointKey: accessPointKey,
      patient: settings.patient.withClinicalData(
        familyHistory: settings.clinicalData.familyHistory,
        socialHistory: settings.clinicalData.socialData,
        medicalHistory: settings.clinicalData.medicalHistory,
        medicationHistory: settings.clinicalData.medicationHistory,
      ),
      answers: _buildAnswers(),
    );
  }

  Future<void> _submitResponse() async {
    setState(() {
      _isSaving = true;
      _saveSuccess = false;
      _saveError = null;
      _reportError = null;
      _savedFilePath = null;
      _savedResponseId = null;
      _agentResponse = null;
    });

    var responseSavedRemotely = false;
    try {
      final settings = Provider.of<AppSettings>(context, listen: false);
      final surveyResponse = _composeSurveyResponse(
        settings,
        accessPointKey: RuntimeAccessPointCatalog
            .screenerReportDetailedAnalysis
            .accessPointKey,
      );

      final saved = await _surveyRepository.submitResponse(surveyResponse);
      if (!mounted) {
        return;
      }
      setState(() {
        _saveSuccess = true;
        _savedResponseId = saved.id;
        _agentResponse = saved.agentResponse;
      });
      responseSavedRemotely = true;

      if (saved.agentResponse == null) {
        final response = await _startAndPollAgentResponse(
          surveyResponse,
          accessPointKey: RuntimeAccessPointCatalog
              .screenerReportDetailedAnalysis
              .accessPointKey,
          flowKey: RuntimeAccessPointCatalog.screenerReportDetailedAnalysis.flowKey,
        );
        if (!mounted) {
          return;
        }
        setState(() {
          _agentResponse = response;
        });
      }
      setState(() {
        _isSaving = false;
      });
    } on _ReportPollingException catch (error) {
      if (!mounted) {
        return;
      }
      if (responseSavedRemotely) {
        setState(() {
          _isSaving = false;
          _reportError = error.message;
        });
        return;
      }
      await _fallbackToLocalSave(error);
    } catch (e) {
      if (responseSavedRemotely) {
        if (!mounted) {
          return;
        }
        setState(() {
          _isSaving = false;
          _reportError =
              'Não foi possível concluir a geração do relatório. Tente novamente.';
        });
        return;
      }
      await _fallbackToLocalSave(e);
    }
  }

  Future<AgentResponse> _startAndPollAgentResponse(
    SurveyResponse surveyResponse, {
    required String accessPointKey,
    required String flowKey,
  }) async {
    final payload = jsonEncode(surveyResponse.toJson());
    final taskStart = await _surveyRepository.startClinicalWriterTask(
      payload,
      accessPointKey: accessPointKey,
      surveyId: surveyResponse.surveyId,
      flowKey: flowKey,
    );
    final taskId =
        taskStart['taskId']?.toString() ?? taskStart['task_id']?.toString();
    if (taskId == null || taskId.isEmpty) {
      throw const _ReportPollingException(
        'Não foi possível iniciar a geração assíncrona do relatório.',
      );
    }

    for (var attempt = 0; attempt < _maxPollingAttempts; attempt++) {
      await Future<void>.delayed(_pollingDelay);
      final statusPayload = await _surveyRepository.getClinicalWriterTaskStatus(
        taskId,
      );
      final status = statusPayload['status']?.toString() ?? '';

      if (status == 'completed' &&
          statusPayload['result'] is Map<String, dynamic>) {
        return AgentResponse.fromJson(
          statusPayload['result'] as Map<String, dynamic>,
        );
      }

      if (status == 'failed') {
        final errorPayload = statusPayload['error'];
        if (errorPayload is Map<String, dynamic>) {
          throw _ReportPollingException(
            errorPayload['userMessage']?.toString() ??
                'Não foi possível gerar o documento solicitado.',
          );
        }
        throw const _ReportPollingException(
          'Não foi possível gerar o documento solicitado.',
        );
      }
    }

    throw const _ReportPollingException(
      'A geração está demorando mais que o esperado. Tente novamente.',
    );
  }

  Future<void> _retryReportGeneration() async {
    await _submitResponse();
  }

  Future<void> _fallbackToLocalSave(Object originalError) async {
    try {
      final settings = Provider.of<AppSettings>(context, listen: false);
      final surveyResponse = _composeSurveyResponse(
        settings,
        accessPointKey: RuntimeAccessPointCatalog
            .screenerReportDetailedAnalysis
            .accessPointKey,
      );

      final fileName = _generateFileName(widget.survey.id, settings.patient.name);
      final filePath = await _writeResponseFile(fileName, surveyResponse.toJson());

      setState(() {
        _isSaving = false;
        _reportError = null;
        _saveSuccess = true;
        _savedFilePath = filePath;
        _saveError =
            'Não foi possível enviar para o servidor (${originalError.toString()}). '
            'As respostas foram salvas localmente.';
      });
    } catch (fallbackError) {
      setState(() {
        _isSaving = false;
        _reportError = null;
        _saveError =
            'Erro ao enviar para o servidor: $originalError\n'
            'Falha ao salvar localmente: $fallbackError';
      });
    }
  }

  Future<void> _sendReportByEmail(
    AppSettings settings,
    ReportDocument report,
  ) async {
    final responseId = _savedResponseId;
    if (responseId == null || responseId.isEmpty) {
      return;
    }

    final patientEmail = settings.patient.email.trim();
    if (patientEmail.isEmpty) {
      return;
    }

    setState(() => _isSendingReportEmail = true);
    try {
      await _surveyRepository.sendReportEmail(
        responseId: responseId,
        reportText: _buildReportText(report),
      );
      if (!mounted) {
        return;
      }
      showDsToast(
        context,
        feedback: const DsFeedbackMessage(
          severity: DsStatusType.success,
          title: 'Relatório enviado',
          message: 'O relatório em PDF foi enviado para o e-mail informado.',
        ),
      );
    } catch (error) {
      if (!mounted) {
        return;
      }
      showDsToast(
        context,
        feedback: DsFeedbackMessage(
          severity: DsStatusType.error,
          title: 'Falha no envio do relatório',
          message: 'Não foi possível enviar o e-mail: $error',
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isSendingReportEmail = false);
      }
    }
  }

  Future<void> _generateDocument({
    required RuntimeAccessPointDescriptor descriptor,
  }) async {
    if (_documentLoadingKeys.contains(descriptor.accessPointKey)) {
      return;
    }
    setState(() {
      _documentLoadingKeys.add(descriptor.accessPointKey);
      _documentErrors.remove(descriptor.accessPointKey);
    });

    try {
      final settings = Provider.of<AppSettings>(context, listen: false);
      final surveyResponse = _composeSurveyResponse(
        settings,
        accessPointKey: descriptor.accessPointKey,
      );
      final response = await _startAndPollAgentResponse(
        surveyResponse,
        accessPointKey: descriptor.accessPointKey,
        flowKey: descriptor.flowKey,
      );
      final text = _agentSummaryText(response);
      if (!mounted) {
        return;
      }
      setState(() {
        _generatedDocumentTexts[descriptor.accessPointKey] = text;
      });
    } catch (error) {
      if (!mounted) {
        return;
      }
      setState(() {
        _documentErrors[descriptor.accessPointKey] = error.toString();
      });
    } finally {
      if (mounted) {
        setState(() {
          _documentLoadingKeys.remove(descriptor.accessPointKey);
        });
      }
    }
  }

  String _agentSummaryText(AgentResponse response) {
    final report = response.report;
    if (report != null) {
      final text = report.toPlainText();
      if (text.trim().isNotEmpty) {
        return text;
      }
    }
    final medicalRecord = response.medicalRecord?.trim();
    if (medicalRecord != null && medicalRecord.isNotEmpty) {
      return medicalRecord;
    }
    final errorMessage = response.errorMessage?.trim();
    if (errorMessage != null && errorMessage.isNotEmpty) {
      return errorMessage;
    }
    return 'O documento foi gerado, mas não retornou conteúdo textual.';
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

  String _generateFileName(String surveyId, String patientName) {
    final safeName = patientName.trim().isEmpty ? 'anon' : patientName;
    final cleanName = safeName
        .toLowerCase()
        .replaceAll(' ', '_')
        .replaceAll(RegExp(r'[^\w\s]'), '');
    return '${surveyId}_$cleanName.json';
  }

  Future<String> _writeResponseFile(
    String fileName,
    Map<String, dynamic> data,
  ) async {
    final jsonString = const JsonEncoder.withIndent('    ').convert(data);
    if (kIsWeb) {
      return 'Exportação local indisponível fora do navegador neste ambiente.';
    }
    final tempDir = Directory.systemTemp;
    final responsesDir = Directory(path.join(tempDir.path, 'survey_responses'));
    if (!await responsesDir.exists()) {
      await responsesDir.create(recursive: true);
    }
    final file = File(path.join(responsesDir.path, fileName));
    await file.writeAsString(jsonString);
    return file.path;
  }

  @override
  Widget build(BuildContext context) {
    final settings = Provider.of<AppSettings>(context);
    final reportDocument = _agentResponse == null
        ? null
        : _resolveReportDocument(settings, _agentResponse!);
    final reportForEmail = reportDocument;
    final patientEmail = settings.patient.email.trim();
    final hasPatientEmail = patientEmail.isNotEmpty;
    final canSendReportEmail =
        !_isSendingReportEmail &&
        reportDocument != null &&
        hasPatientEmail &&
        _savedResponseId != null;
    final displayName = widget.survey.surveyDisplayName.isNotEmpty
        ? widget.survey.surveyDisplayName
        : widget.survey.surveyName;

    final documentDescriptors = <RuntimeAccessPointDescriptor>[
      RuntimeAccessPointCatalog.screenerDocumentClinicalReferral,
      RuntimeAccessPointCatalog.screenerDocumentSchoolReferral,
      RuntimeAccessPointCatalog.screenerDocumentParentOrientation,
    ];

    return DsScaffold(
      title: 'Relatório',
      subtitle: 'Análise consolidada do questionário $displayName.',
      onBack: () => Navigator.of(context).pop(),
      backLabel: 'Voltar',
      scrollable: true,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const AssessmentFlowStepper(
            currentStep: AssessmentFlowStep.relatorio,
          ),
          if (_isSaving) ...[
            const Center(child: DsLoading()),
            const SizedBox(height: 16),
            const DsInlineMessage(
              feedback: DsFeedbackMessage(
                severity: DsStatusType.info,
                title: 'Preparando relatório',
                message: 'Respostas registradas. Relatório em preparo.',
              ),
              margin: EdgeInsets.zero,
            ),
            const SizedBox(height: 24),
          ],
          if (_saveSuccess && !_isSaving)
            DsMessageBanner(
              feedback: DsFeedbackMessage(
                severity: DsStatusType.success,
                title: _savedResponseId != null
                    ? 'Respostas enviadas'
                    : 'Respostas salvas localmente',
                message: _savedResponseId != null
                    ? 'Agora você pode visualizar e compartilhar o relatório.'
                    : 'Não conseguimos enviar ao servidor, mas os dados foram preservados localmente.',
              ),
              footer: (_savedResponseId != null || _savedFilePath != null)
                  ? Text(
                      _savedResponseId != null
                          ? 'Protocolo: $_savedResponseId'
                          : 'Arquivo salvo em: $_savedFilePath',
                    )
                  : null,
            ),
          if (_saveError != null)
            Padding(
              padding: const EdgeInsets.only(top: 16.0),
              child: DsMessageBanner(
                feedback: DsFeedbackMessage(
                  severity: DsStatusType.warning,
                  title: 'Envio com ressalvas',
                  message: _saveError!,
                ),
              ),
            ),
          if (_reportError != null)
            Padding(
              padding: const EdgeInsets.only(top: 16.0),
              child: DsMessageBanner(
                feedback: DsFeedbackMessage(
                  severity: DsStatusType.warning,
                  title: 'Relatório indisponível no momento',
                  message: _reportError!,
                  primaryAction: DsFeedbackAction(
                    label: 'Tentar novamente',
                    icon: Icons.refresh,
                    onPressed: _retryReportGeneration,
                  ),
                ),
              ),
            ),
          const SizedBox(height: 16),
          if (reportDocument != null) ...[
            ReportView(
              report: reportDocument,
              footer:
                  'Gerado por LAPAN - Laboratório de Pesquisa Aplicada à Neurociência da Visão',
            ),
            const SizedBox(height: 16),
          ],
          SizedBox(
            width: double.infinity,
            child: DsFilledButton(
              label: _isSendingReportEmail
                  ? 'Enviando relatório...'
                  : 'Enviar relatório por e-mail',
              icon: Icons.email_outlined,
              onPressed: canSendReportEmail && reportForEmail != null
                  ? () => _sendReportByEmail(settings, reportForEmail)
                  : null,
            ),
          ),
          if (!hasPatientEmail) ...[
            const SizedBox(height: 8),
            Text(
              'Informe um e-mail na identificação do paciente para habilitar o envio do relatório.',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
          const SizedBox(height: 24),
          DsSection(
            eyebrow: 'Documentos complementares',
            title: 'Geração assistida de cartas',
            subtitle:
                'Use os botões abaixo para gerar documentos de encaminhamento e orientação.',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                for (final descriptor in documentDescriptors) ...[
                  DsOutlinedButton(
                    label: descriptor.name,
                    icon: Icons.description_outlined,
                    onPressed: _documentLoadingKeys.contains(
                      descriptor.accessPointKey,
                    )
                        ? null
                        : () => _generateDocument(descriptor: descriptor),
                  ),
                  if (_documentErrors.containsKey(descriptor.accessPointKey))
                    Padding(
                      padding: const EdgeInsets.only(top: 8, bottom: 12),
                      child: DsInlineMessage(
                        feedback: DsFeedbackMessage(
                          severity: DsStatusType.error,
                          title: 'Falha ao gerar documento',
                          message:
                              _documentErrors[descriptor.accessPointKey] ?? '',
                        ),
                        margin: EdgeInsets.zero,
                      ),
                    )
                  else if (_generatedDocumentTexts.containsKey(
                    descriptor.accessPointKey,
                  ))
                    Padding(
                      padding: const EdgeInsets.only(top: 8, bottom: 12),
                      child: DsClinicalContentCard(
                        title: descriptor.name,
                        child: Text(
                          _generatedDocumentTexts[descriptor.accessPointKey]!,
                          maxLines: 8,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    )
                  else
                    const SizedBox(height: 12),
                ],
              ],
            ),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: DsOutlinedButton(
              label: 'Iniciar nova avaliação',
              onPressed: widget.onRestartSurvey,
            ),
          ),
        ],
      ),
    );
  }
}

class _ReportPollingException implements Exception {
  const _ReportPollingException(this.message);

  final String message;

  @override
  String toString() => message;
}
