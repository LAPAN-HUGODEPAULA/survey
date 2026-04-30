import 'dart:convert';

import 'package:design_system_flutter/widgets.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:patient_app/core/models/agent_response.dart';
import 'package:patient_app/core/models/patient.dart';
import 'package:patient_app/core/models/survey/question.dart';
import 'package:patient_app/core/models/survey/survey.dart';
import 'package:patient_app/core/models/survey_response.dart';
import 'package:patient_app/core/navigation/app_navigator.dart';
import 'package:patient_app/core/providers/app_settings.dart';
import 'package:patient_app/core/repositories/survey_repository.dart';
import 'package:patient_app/shared/widgets/patient_journey_stepper.dart';
import 'package:provider/provider.dart';
import 'package:runtime_agent_access_points/runtime_agent_access_points.dart';
import 'package:url_launcher/url_launcher.dart';

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

class ThankYouPage extends StatefulWidget {
  const ThankYouPage({
    super.key,
    required this.survey,
    required this.surveyAnswers,
    required this.surveyQuestions,
    this.surveyRepository,
    this.skipAgentFetch = false,
  });

  final Survey survey;
  final List<String> surveyAnswers;
  final List<Question> surveyQuestions;
  final SurveyRepository? surveyRepository;
  final bool skipAgentFetch;

  @override
  State<ThankYouPage> createState() => _ThankYouPageState();
}

enum HandoffState { registering, registered, analyzing, ready }

class _ThankYouPageState extends State<ThankYouPage> {
  static final Uri _specialistUri = Uri.parse(
    'https://chatgpt.com/g/g-699b668db91c8191877e65ba10726cd2-irlen-syndrome-for-teachers-and-educators',
  );

  SurveyRepository? _surveyRepository;
  bool _ownsRepository = false;
  HandoffState _handoffState = HandoffState.registering;
  String? _agentError;
  bool _agentRetryable = false;
  AgentResponse? _agentResponse;
  AIProgress? _aiProgress;
  String? _savedResponseId;

  @override
  void initState() {
    super.initState();
    if (widget.skipAgentFetch) {
      _handoffState = HandoffState.registered;
    } else {
      WidgetsBinding.instance.addPostFrameCallback((_) => _loadAgentResponse());
    }
  }

  @override
  void dispose() {
    if (_ownsRepository) {
      _surveyRepository?.dispose();
    }
    super.dispose();
  }

  SurveyRepository get _repository {
    if (_surveyRepository != null) {
      return _surveyRepository!;
    }
    if (widget.surveyRepository != null) {
      _surveyRepository = widget.surveyRepository;
      _ownsRepository = false;
    } else {
      _surveyRepository = SurveyRepository();
      _ownsRepository = true;
    }
    return _surveyRepository!;
  }

  Future<void> _showRegisteredStep() async {
    if (!mounted) {
      return;
    }
    setState(() {
      _handoffState = HandoffState.registered;
    });
    await Future<void>.delayed(const Duration(milliseconds: 350));
    if (!mounted || _agentResponse != null) {
      return;
    }
    setState(() {
      _handoffState = HandoffState.analyzing;
    });
  }

  Future<void> _loadAgentResponse() async {
    setState(() {
      _handoffState = HandoffState.registering;
      _agentError = null;
      _agentRetryable = false;
      _aiProgress = const AIProgress(stage: 'organizing_data');
    });
    final settings = Provider.of<AppSettings>(context, listen: false);
    final surveyResponse = _composeSurveyResponse(settings);
    try {
      final repository = _repository;
      final savedResponse = await repository.submitResponse(surveyResponse);
      if (!mounted) return;
      setState(() {
        _savedResponseId = savedResponse.id;
      });
      await _showRegisteredStep();
      AgentResponse? response = savedResponse.agentResponse;
      response ??= await _startAndPollAgentResponse(repository, surveyResponse);
      if (!mounted) return;
      setState(() {
        _agentResponse = response;
        _aiProgress = response?.aiProgress ?? _aiProgress;
        if (_agentError == null && response != null) {
          _handoffState = HandoffState.ready;
        }
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _handoffState = _savedResponseId != null
            ? HandoffState.analyzing
            : HandoffState.registering;
        _agentError =
            'Não foi possível obter a avaliação preliminar. Verifique sua conexão e tente novamente.';
        _agentRetryable = true;
      });
    }
  }

  Future<AgentResponse?> _startAndPollAgentResponse(
    SurveyRepository repository,
    SurveyResponse surveyResponse,
  ) async {
    final payload = jsonEncode(surveyResponse.toJson());
    final taskStart = await repository.startClinicalWriterTask(
      payload,
      accessPointKey: surveyResponse.accessPointKey,
      surveyId: surveyResponse.surveyId,
    );
    final taskId =
        taskStart['taskId']?.toString() ?? taskStart['task_id']?.toString();
    if (taskId == null || taskId.isEmpty) {
      return repository.processClinicalWriter(
        payload,
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
      final statusPayload = await repository.getClinicalWriterTaskStatus(
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
        if (errorPayload is Map<String, dynamic>) {
          _agentRetryable = errorPayload['retryable'] as bool? ?? false;
          _agentError =
              errorPayload['userMessage']?.toString() ??
              'Não foi possível gerar a análise automática para este caso.';
        }
        return null;
      }
    }

    _agentRetryable = true;
    _agentError =
        'A análise está demorando mais que o esperado. Tente novamente em instantes.';
    return null;
  }

  SurveyResponse _composeSurveyResponse(AppSettings settings) {
    return SurveyResponse(
      surveyId: widget.survey.id,
      creatorId: widget.survey.creatorId,
      testDate: DateTime.now(),
      screenerId: settings.screener.id,
      accessPointKey: RuntimeAccessPointCatalog
          .surveyPatientThankYouAutoAnalysis
          .accessPointKey,
      patient: _resolvePatient(settings),
      answers: _buildAnswers(),
    );
  }

  Patient? _resolvePatient(AppSettings settings) {
    final patient = settings.patient;
    final hasData =
        patient.name.isNotEmpty ||
        patient.email.isNotEmpty ||
        patient.birthDate.isNotEmpty ||
        patient.gender.isNotEmpty ||
        patient.ethnicity.isNotEmpty ||
        patient.educationLevel.isNotEmpty ||
        patient.profession.isNotEmpty ||
        patient.medication.isNotEmpty ||
        patient.diagnoses.isNotEmpty;
    return hasData ? patient : null;
  }

  List<Answer> _buildAnswers() {
    final answers = <Answer>[];
    for (var index = 0; index < widget.surveyAnswers.length; index++) {
      if (index < widget.surveyQuestions.length) {
        answers.add(
          Answer(
            id: widget.surveyQuestions[index].id,
            answer: widget.surveyAnswers[index],
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
      final value = _resolveRadarScore(question, answer);
      final label = (question.label?.trim().isNotEmpty ?? false)
          ? question.label!.trim()
          : 'Q${index + 1}';
      summaries.add(_AnswerSummary(label: label, value: value));
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

  String _agentSummaryText(AgentResponse response) {
    final document = response.report;
    if (document != null) {
      final text = document.toPlainText();
      if (text.isNotEmpty) {
        return text;
      }
    }
    if (response.medicalRecord?.trim().isNotEmpty == true) {
      return response.medicalRecord!.trim();
    }
    if (response.errorMessage?.trim().isNotEmpty == true) {
      return response.errorMessage!.trim();
    }
    return 'A avaliação preliminar foi concluída mas ainda não retornou texto.';
  }

  Future<void> _restartSurveyFlow() async {
    final appSettings = Provider.of<AppSettings>(context, listen: false);
    await appSettings.restartAssessmentFlow();
    if (!mounted) {
      return;
    }
    AppNavigator.replaceWithEntryGate(context);
  }

  Future<void> _openSpecialistAssistant() async {
    final opened = await launchUrl(
      _specialistUri,
      mode: LaunchMode.externalApplication,
      webOnlyWindowName: '_blank',
    );
    if (opened || !mounted) {
      return;
    }
    showDsToast(
      context,
      feedback: const DsFeedbackMessage(
        severity: DsStatusType.error,
        title: 'Não foi possível abrir o link',
        message: 'Tente novamente em alguns instantes.',
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<AppSettings>();
    final summaries = _buildSummaries();
    const maxValue = 3;
    final values = summaries.map((item) => item.value).toList(growable: false);
    final labels = summaries.map((item) => item.label).toList(growable: false);
    final theme = Theme.of(context);
    final displayName = widget.survey.surveyDisplayName.isNotEmpty
        ? widget.survey.surveyDisplayName
        : widget.survey.surveyName;

    return DsScaffold(
      title: 'Obrigado por sua colaboração',
      subtitle:
          'Suas respostas no questionário $displayName ajudam a construir um cuidado mais atento.',
      onBack: () => Navigator.of(context).pop(),
      backLabel: 'Voltar para o questionário',
      userName: settings.patient.name,
      showAmbientGreeting: true,
      scrollable: true,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const PatientJourneyStepper(
            currentStep: PatientJourneyStep.relatorio,
          ),
          const DsInlineMessage(
            feedback: DsFeedbackMessage(
              severity: DsStatusType.success,
              title: DsHandoffCopy.registeredLabel,
              message: DsHandoffCopy.effortAcknowledgement,
            ),
            margin: EdgeInsets.zero,
          ),
          const SizedBox(height: 16),
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
                      ? const Center(child: Text('Sem respostas para exibir.'))
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
              ],
            ),
          ),
          const SizedBox(height: 16),
          DsSection(
            eyebrow: 'Leitura clínica',
            title: 'Avaliação preliminar',
            subtitle:
                'A síntese abaixo acompanha o andamento entre o envio das respostas e a disponibilidade do relatório.',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                DsHandoffStatusRow(
                  stage: switch (_handoffState) {
                    HandoffState.registering => DsHandoffStage.registered,
                    HandoffState.registered => DsHandoffStage.registered,
                    HandoffState.analyzing => DsHandoffStage.analyzing,
                    HandoffState.ready => DsHandoffStage.ready,
                  },
                  liveRegion: true,
                ),
                const SizedBox(height: 12),
                if (_handoffState == HandoffState.registered ||
                    _handoffState == HandoffState.analyzing ||
                    _handoffState == HandoffState.ready)
                  DsMessageBanner(
                    feedback: DsFeedbackMessage(
                      severity: DsStatusType.info,
                      title: DsHandoffCopy.registeredLabel,
                      message: DsHandoffCopy.effortAcknowledgement,
                    ),
                    margin: EdgeInsets.zero,
                    footer: _savedResponseId == null
                        ? null
                        : Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                DsHandoffCopy.referenceIdContext,
                                style: theme.textTheme.bodyMedium,
                              ),
                              const SizedBox(height: 8),
                              SelectableText(
                                _savedResponseId!,
                                style: theme.textTheme.bodySmall?.copyWith(
                                  fontFamily: 'monospace',
                                  color: theme.colorScheme.onSurface,
                                ),
                              ),
                            ],
                          ),
                  ),
                if (_handoffState == HandoffState.analyzing) ...[
                  const SizedBox(height: 16),
                  DsSection(
                    padding: const EdgeInsets.all(16),
                    tone: DsPanelTone.high,
                    title: DsHandoffCopy.analyzingLabel,
                    subtitle:
                        'Sua avaliação foi salva. Agora estamos organizando os dados para apresentar a síntese inicial.',
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        DsHandoffStatusRow(
                          stage: DsHandoffStage.analyzing,
                          liveRegion: true,
                        ),
                        const SizedBox(height: 12),
                        if (_agentError != null)
                          DsInlineMessage(
                            feedback: DsFeedbackMessage(
                              severity: _agentRetryable
                                  ? DsStatusType.warning
                                  : DsStatusType.error,
                              title:
                                  'Não foi possível obter a avaliação preliminar.',
                              message: _agentError!,
                              primaryAction: _agentRetryable
                                  ? DsFeedbackAction(
                                      label: 'Tentar novamente',
                                      onPressed: _loadAgentResponse,
                                      icon: Icons.refresh,
                                    )
                                  : null,
                            ),
                            margin: EdgeInsets.zero,
                          )
                        else
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
                      ],
                    ),
                  ),
                ],
                if (_handoffState == HandoffState.ready &&
                    _agentResponse != null) ...[
                  const SizedBox(height: 16),
                  DsClinicalContentCard(
                    title: DsHandoffCopy.readyLabel,
                    subtitle:
                        'A síntese clínica abaixo foi gerada com base nas respostas registradas.',
                    child: LimitedBox(
                      maxHeight: 220,
                      child: SingleChildScrollView(
                        child: Text(
                          _agentSummaryText(_agentResponse!),
                          style: theme.textTheme.bodyMedium,
                        ),
                      ),
                    ),
                  ),
                ],
                if (_handoffState == HandoffState.registered &&
                    _savedResponseId == null)
                  Text(
                    'Estamos concluindo o registro da avaliação.',
                    style: theme.textTheme.bodyMedium,
                  ),
                if (widget.survey.finalNotes != null &&
                    widget.survey.finalNotes!.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  DsFocusFrame(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.info_outline,
                              color: theme.colorScheme.primary,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Notas finais',
                              style: theme.textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Html(
                          data: widget.survey.finalNotes!,
                          style: {
                            'body': Style(
                              fontSize: FontSize(15.0),
                              lineHeight: const LineHeight(1.5),
                              color: theme.colorScheme.onSurface,
                            ),
                            'p': Style(margin: Margins.only(bottom: 12.0)),
                            'a': Style(
                              textDecoration: TextDecoration.underline,
                            ),
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 16),
          DsSection(
            eyebrow: 'Apoio externo',
            title: 'Converse com o especialista',
            subtitle:
                'Este GPT é um projeto externo da LAPAN com orientações sobre desconforto visual e aprendizagem.',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Ele pode oferecer dicas úteis para situações de sensibilidade visual e dificuldades relacionadas ao ambiente de estudo.',
                  style: theme.textTheme.bodyMedium,
                ),
                const SizedBox(height: 12),
                DsOutlinedButton(
                  label: 'Abrir especialista Irlen',
                  icon: Icons.open_in_new,
                  onPressed: _openSpecialistAssistant,
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          DsHandoffFork(
            title: 'O que você deseja fazer agora?',
            subtitle:
                'Você pode continuar para complementar a avaliação ou iniciar uma nova triagem.',
            actions: [
              DsHandoffForkAction(
                title: 'Adicionar informações para melhores insights',
                description:
                    'Estas informações opcionais ajudam em pesquisas estatísticas, mas você pode pular esta etapa se preferir.',
                primaryLabel: 'Adicionar informações',
                onPrimaryPressed: () => AppNavigator.toDemographics(
                  context,
                  survey: widget.survey,
                  surveyAnswers: widget.surveyAnswers,
                  surveyQuestions: widget.surveyQuestions,
                ),
                icon: Icons.person_add_alt_1_outlined,
              ),
              DsHandoffForkAction(
                title: 'Gerar relatório com as respostas atuais',
                description:
                    'Siga direto para o relatório clínico com base nas respostas já registradas.',
                primaryLabel: 'Gerar relatório',
                onPrimaryPressed: () => AppNavigator.toReport(
                  context,
                  survey: widget.survey,
                  surveyAnswers: widget.surveyAnswers,
                  surveyQuestions: widget.surveyQuestions,
                  onRestartSurvey: _restartSurveyFlow,
                ),
                icon: Icons.description_outlined,
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: DsOutlinedButton(
              label: 'Iniciar nova avaliação',
              onPressed: _restartSurveyFlow,
            ),
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
        getTitle: (index, angle) {
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
  const _AnswerSummary({required this.label, required this.value});

  final String label;
  final double value;
}
