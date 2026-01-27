library;

import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:provider/provider.dart';
import 'package:patient_app/core/navigation/app_navigator.dart';
import 'package:patient_app/core/providers/app_settings.dart';
import 'package:patient_app/core/models/survey/question.dart';
import 'package:patient_app/core/models/survey/survey.dart';

class ThankYouPage extends StatelessWidget {
  const ThankYouPage({
    super.key,
    required this.survey,
    required this.surveyAnswers,
    required this.surveyQuestions,
  });

  final Survey survey;
  final List<String> surveyAnswers;
  final List<Question> surveyQuestions;

  List<_AnswerSummary> _buildSummaries() {
    final summaries = <_AnswerSummary>[];
    for (int i = 0; i < surveyQuestions.length; i++) {
      final question = surveyQuestions[i];
      final answer = i < surveyAnswers.length ? surveyAnswers[i] : '';
      final answerIndex = question.answers.indexOf(answer);
      final value = answerIndex >= 0 ? (answerIndex + 1).toDouble() : 0.0;
      summaries.add(
        _AnswerSummary(
          questionText: question.questionText,
          answerText: answer.isNotEmpty ? answer : 'Sem resposta',
          value: value,
          maxValue: question.answers.length,
        ),
      );
    }
    return summaries;
  }

  @override
  Widget build(BuildContext context) {
    final summaries = _buildSummaries();
    final maxValue = summaries.isEmpty
        ? 1
        : summaries.map((item) => item.maxValue).reduce(max);
    final values = summaries.map((item) => item.value).toList(growable: false);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Resumo do Questionario'),
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
                  style: Theme.of(context)
                      .textTheme
                      .headlineMedium
                      ?.copyWith(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 8),
                Text(
                  'Veja o resumo das suas respostas antes de seguir para o relatorio.',
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                const SizedBox(height: 24),
                Card(
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                    side: BorderSide(
                      color: Theme.of(context).colorScheme.outline,
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Radar das respostas',
                          style: Theme.of(context)
                              .textTheme
                              .titleLarge
                              ?.copyWith(fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(height: 16),
                        SizedBox(
                          height: 260,
                          child: values.isEmpty
                              ? const Center(
                                  child: Text('Sem respostas para exibir.'),
                                )
                              : RadarChart(values: values, maxValue: maxValue),
                        ),
                        const SizedBox(height: 24),
                        Text(
                          'Resumo das respostas',
                          style: Theme.of(context)
                              .textTheme
                              .titleMedium
                              ?.copyWith(fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(height: 12),
                        for (final summary in summaries)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  summary.questionText,
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodyMedium
                                      ?.copyWith(
                                        fontWeight: FontWeight.w600,
                                      ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  summary.answerText,
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodyMedium
                                      ?.copyWith(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .onSurfaceVariant,
                                      ),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
                if (survey.finalNotes != null && survey.finalNotes!.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 24.0),
                    child: Card(
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                        side: BorderSide(
                          color: Theme.of(context).colorScheme.outline,
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  Icons.info_outline,
                                  color: Theme.of(context)
                                      .colorScheme
                                      .primary,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'Informacoes importantes',
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleMedium
                                      ?.copyWith(
                                        fontWeight: FontWeight.w600,
                                      ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Html(
                              data: survey.finalNotes!,
                              style: {
                                'body': Style(
                                  fontSize: FontSize(15.0),
                                  lineHeight: const LineHeight(1.5),
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onSurface,
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
                    ),
                  ),
                const SizedBox(height: 24),
                Container(
                  padding: const EdgeInsets.all(20.0),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.secondaryContainer,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: Theme.of(context).colorScheme.outline,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Quer um relatorio mais detalhado?',
                        style: Theme.of(context)
                            .textTheme
                            .titleMedium
                            ?.copyWith(fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Voce pode adicionar seus dados pessoais para enriquecer a analise ou seguir direto para o relatorio.',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () =>
                                  AppNavigator.toDemographics(
                                context,
                                survey: survey,
                                surveyAnswers: surveyAnswers,
                                surveyQuestions: surveyQuestions,
                              ),
                              child: const Text('Adicionar Informacoes'),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () {
                                Provider.of<AppSettings>(
                                  context,
                                  listen: false,
                                ).clearPatientData();
                                AppNavigator.replaceWithReport(
                                  context,
                                  survey: survey,
                                  surveyAnswers: surveyAnswers,
                                  surveyQuestions: surveyQuestions,
                                );
                              },
                              child: const Text('Ver Resultados'),
                            ),
                          ),
                        ],
                      ),
                    ],
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

class _AnswerSummary {
  const _AnswerSummary({
    required this.questionText,
    required this.answerText,
    required this.value,
    required this.maxValue,
  });

  final String questionText;
  final String answerText;
  final double value;
  final int maxValue;
}

class RadarChart extends StatelessWidget {
  const RadarChart({super.key, required this.values, required this.maxValue});

  final List<double> values;
  final int maxValue;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _RadarChartPainter(
        values: values,
        maxValue: maxValue,
        scheme: Theme.of(context).colorScheme,
      ),
      child: const SizedBox.expand(),
    );
  }
}

class _RadarChartPainter extends CustomPainter {
  _RadarChartPainter({
    required this.values,
    required this.maxValue,
    required this.scheme,
  });

  final List<double> values;
  final int maxValue;
  final ColorScheme scheme;

  @override
  void paint(Canvas canvas, Size size) {
    if (values.isEmpty) {
      return;
    }

    final center = Offset(size.width / 2, size.height / 2);
    final radius = min(size.width, size.height) * 0.4;
    final steps = maxValue > 1 ? maxValue : 1;
    final angleStep = (2 * pi) / values.length;

    final gridPaint = Paint()
      ..color = scheme.outlineVariant
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    for (int level = 1; level <= steps; level++) {
      final levelRadius = radius * (level / steps);
      final path = Path();
      for (int i = 0; i < values.length; i++) {
        final angle = -pi / 2 + angleStep * i;
        final point = Offset(
          center.dx + levelRadius * cos(angle),
          center.dy + levelRadius * sin(angle),
        );
        if (i == 0) {
          path.moveTo(point.dx, point.dy);
        } else {
          path.lineTo(point.dx, point.dy);
        }
      }
      path.close();
      canvas.drawPath(path, gridPaint);
    }

    final axisPaint = Paint()
      ..color = scheme.outline
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    for (int i = 0; i < values.length; i++) {
      final angle = -pi / 2 + angleStep * i;
      final endPoint = Offset(
        center.dx + radius * cos(angle),
        center.dy + radius * sin(angle),
      );
      canvas.drawLine(center, endPoint, axisPaint);
    }

    final dataPath = Path();
    for (int i = 0; i < values.length; i++) {
      final normalized = maxValue == 0 ? 0.0 : values[i] / maxValue;
      final pointRadius = radius * normalized;
      final angle = -pi / 2 + angleStep * i;
      final point = Offset(
        center.dx + pointRadius * cos(angle),
        center.dy + pointRadius * sin(angle),
      );
      if (i == 0) {
        dataPath.moveTo(point.dx, point.dy);
      } else {
        dataPath.lineTo(point.dx, point.dy);
      }
    }
    dataPath.close();

    final fillPaint = Paint()
      ..color = scheme.primary.withOpacity(0.2)
      ..style = PaintingStyle.fill;
    final strokePaint = Paint()
      ..color = scheme.primary
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    canvas.drawPath(dataPath, fillPaint);
    canvas.drawPath(dataPath, strokePaint);
  }

  @override
  bool shouldRepaint(covariant _RadarChartPainter oldDelegate) {
    return oldDelegate.values != values ||
        oldDelegate.maxValue != maxValue ||
        oldDelegate.scheme != scheme;
  }
}
