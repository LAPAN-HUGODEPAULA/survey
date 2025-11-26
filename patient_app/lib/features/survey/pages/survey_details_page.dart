library;

import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';

import 'package:patient_app/core/models/survey/survey.dart';

class SurveyDetailsPage extends StatelessWidget {
  const SurveyDetailsPage({super.key, required this.survey});

  final Survey survey;

  String _formatDate(DateTime date) {
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    final year = date.year.toString();
    return '$day/$month/$year';
  }

  Widget _buildDetailRow(String label, String value, BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard(String title, Widget content, BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 8),
            content,
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final displayName = survey.surveyDisplayName.isNotEmpty
        ? survey.surveyDisplayName
        : survey.surveyName;

    return Scaffold(
      appBar: AppBar(title: Text('Detalhes - $displayName')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildInfoCard(
              'Informações Básicas',
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildDetailRow('ID:', survey.id, context),
                  _buildDetailRow('Nome:', survey.surveyName, context),
                  _buildDetailRow('Criador:', survey.creatorName, context),
                  if ((survey.creatorContact ?? '').isNotEmpty)
                    _buildDetailRow('Contato:', survey.creatorContact!, context),
                ],
              ),
              context,
            ),
            _buildInfoCard(
              'Informações Temporais',
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildDetailRow(
                    'Data de Criação:',
                    _formatDate(survey.createdAt),
                    context,
                  ),
                  _buildDetailRow(
                    'Última Modificação:',
                    _formatDate(survey.modifiedAt),
                    context,
                  ),
                ],
              ),
              context,
            ),
            if (survey.surveyDescription.isNotEmpty)
              _buildInfoCard(
                'Descrição',
                Html(
                  data: survey.surveyDescription,
                  style: {
                    'body': Style(
                      fontSize: FontSize(16.0),
                      lineHeight: const LineHeight(1.5),
                    ),
                    'p': Style(margin: Margins.only(bottom: 12.0)),
                  },
                ),
                context,
              ),
            _buildInfoCard(
              'Estatísticas',
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildDetailRow(
                    'Total de Perguntas:',
                    survey.questions.length.toString(),
                    context,
                  ),
                  _buildDetailRow(
                    'Possui notas finais:',
                    survey.finalNotes != null && survey.finalNotes!.isNotEmpty
                        ? 'Sim'
                        : 'Não',
                    context,
                  ),
                ],
              ),
              context,
            ),
          ],
        ),
      ),
    );
  }
}
