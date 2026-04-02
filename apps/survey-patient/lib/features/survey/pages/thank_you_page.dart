import 'dart:convert';
import 'dart:math';

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
import 'package:provider/provider.dart';

const _radarPalette = <Color>[
  Color(0xFFEF5350),
  Color(0xFFFFA726),
  Color(0xFF66BB6A),
  Color(0xFF42A5F5),
  Color(0xFF7E57C2),
  Color(0xFF26A69A),
  Color(0xFFFFEB3B),
];

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

class _ThankYouPageState extends State<ThankYouPage> {
  SurveyRepository? _surveyRepository;
  bool _ownsRepository = false;
  bool _isAgentLoading = true;
  String? _agentError;
  AgentResponse? _agentResponse;

  @override
  void initState() {
    super.initState();
    if (!widget.skipAgentFetch) {
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

  Future<void> _loadAgentResponse() async {
    setState(() {
      _isAgentLoading = true;
      _agentError = null;
    });
    final settings = Provider.of<AppSettings>(context, listen: false);
    final surveyResponse = _composeSurveyResponse(settings);
    try {
      final repository = _repository;
      final savedResponse = await repository.submitResponse(surveyResponse);
      AgentResponse? response = savedResponse.agentResponse;
      if (response == null) {
        final payload = jsonEncode(surveyResponse.toJson());
        response = await repository.processClinicalWriter(
          payload,
          promptKey: surveyResponse.promptKey,
        );
      }
      if (!mounted) return;
      setState(() {
        _agentResponse = response;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _agentError =
            'Não foi possível obter a avaliação preliminar. Verifique sua conexão e tente novamente.';
      });
    } finally {
      if (mounted) {
        setState(() => _isAgentLoading = false);
      }
    }
  }

  SurveyResponse _composeSurveyResponse(AppSettings settings) {
    return SurveyResponse(
      surveyId: widget.survey.id,
      creatorId: widget.survey.creatorId,
      testDate: DateTime.now(),
      screenerId: settings.screener.id,
      promptKey: widget.survey.prompt?.promptKey,
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
      final answerIndex = question.answers.indexOf(answer);
      final value = answerIndex >= 0 ? (answerIndex + 1).toDouble() : 0.0;
      final label = (question.label?.trim().isNotEmpty ?? false)
          ? question.label!.trim()
          : 'Q${question.id}';
      summaries.add(
        _AnswerSummary(
          questionText: question.questionText,
          label: label,
          answerText: answer.isNotEmpty ? answer : 'Sem resposta',
          value: value,
          maxValue: question.answers.length,
        ),
      );
    }
    return summaries;
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

  @override
  Widget build(BuildContext context) {
    final summaries = _buildSummaries();
    final maxValue = summaries.isEmpty
        ? 1
        : summaries.map((item) => item.maxValue).reduce(max);
    final values = summaries.map((item) => item.value).toList(growable: false);
    final labels = summaries.map((item) => item.label).toList(growable: false);
    final theme = Theme.of(context);

    return DsScaffold(
      appBar: AppBar(
        title: const Text('Relatório Clínico do Questionário Lapan Q7'),
        automaticallyImplyLeading: false,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 900),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Obrigado por responder!',
                  style: theme.textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Veja o resumo das suas respostas antes de seguir para o relatório.',
                  style: theme.textTheme.bodyLarge,
                ),
                const SizedBox(height: 24),
                Card(
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                    side: BorderSide(color: theme.colorScheme.outline),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Radar das respostas',
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 16),
                        SizedBox(
                          height: 280,
                          child: values.isEmpty
                              ? const Center(
                                  child: Text('Sem respostas para exibir.'),
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
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Card(
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                    side: BorderSide(color: theme.colorScheme.outline),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Avaliação preliminar',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 12),
                        if (_isAgentLoading)
                          Row(
                            children: [
                              const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Text(
                                'Processando análise',
                                style: theme.textTheme.bodyMedium,
                              ),
                            ],
                          )
                        else if (_agentError != null)
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: _withOpacity(
                                theme.colorScheme.error,
                                0.12,
                              ),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: theme.colorScheme.error,
                              ),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.warning_amber_rounded,
                                  color: theme.colorScheme.error,
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    _agentError!,
                                    style: theme.textTheme.bodyMedium,
                                  ),
                                ),
                                TextButton(
                                  onPressed: _loadAgentResponse,
                                  child: const Text('Recarregar'),
                                ),
                              ],
                            ),
                          )
                        else if (_agentResponse != null)
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              LimitedBox(
                                maxHeight: 180,
                                child: SingleChildScrollView(
                                  child: Text(
                                    _agentSummaryText(_agentResponse!),
                                    style: theme.textTheme.bodyMedium,
                                  ),
                                ),
                              ),
                            ],
                          )
                        else
                          Text(
                            'Ainda não conseguimos gerar a avaliação preliminar.',
                            style: theme.textTheme.bodyMedium,
                          ),
                        if (widget.survey.finalNotes != null &&
                            widget.survey.finalNotes!.isNotEmpty) ...[
                          const SizedBox(height: 16),
                          const Divider(),
                          const SizedBox(height: 12),
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
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Card(
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                    side: BorderSide(color: theme.colorScheme.outline),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Quer um relatório mais detalhado?',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Você pode adicionar seus dados pessoais para enriquecer a análise ou seguir direto para o relatório.',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                        const SizedBox(height: 16),
                        DsFilledButton(
                          label: 'Adicionar Informações',
                          onPressed: () => AppNavigator.toDemographics(
                            context,
                            survey: widget.survey,
                            surveyAnswers: widget.surveyAnswers,
                            surveyQuestions: widget.surveyQuestions,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: DsOutlinedButton(
                    label: 'Iniciar nova avaliação',
                    onPressed: () async {
                      final settings = Provider.of<AppSettings>(
                        context,
                        listen: false,
                      );
                      settings.clearPatientData();
                      await settings.clearInitialNoticeAgreement();
                      if (!context.mounted) {
                        return;
                      }
                      AppNavigator.replaceWithEntryGate(context);
                    },
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

class _RadarLegendChip extends StatelessWidget {
  const _RadarLegendChip({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: _withOpacity(color, 0.2),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 6),
          Text(label, style: Theme.of(context).textTheme.bodySmall),
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
          color: theme.colorScheme.onSurfaceVariant,
        ),
        getTitle: (index, angle) {
          final label = labels.isEmpty ? 'Q${index + 1}' : labels[index];
          return RadarChartTitle(text: label, angle: angle);
        },
        titlePositionPercentageOffset: 0.15,
        tickCount: maxValue,
        ticksTextStyle: theme.textTheme.labelSmall?.copyWith(
          color: theme.colorScheme.onSurfaceVariant,
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
    required this.maxValue,
  });

  final String questionText;
  final String label;
  final String answerText;
  final double value;
  final int maxValue;
}
