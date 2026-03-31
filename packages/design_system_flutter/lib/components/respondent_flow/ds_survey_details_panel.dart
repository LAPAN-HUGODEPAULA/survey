import 'package:design_system_flutter/components/respondent_flow/respondent_flow_models.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';

class DsSurveyDetailsPanel extends StatelessWidget {
  const DsSurveyDetailsPanel({
    super.key,
    required this.details,
  });

  final DsSurveyDetailsData details;

  String _formatDate(DateTime date) {
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    final year = date.year.toString();
    return '$day/$month/$year';
  }

  Widget _buildDetailRow(String label, String value, BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
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
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
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
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildInfoCard(
            'Informações Básicas',
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildDetailRow('ID:', details.id, context),
                _buildDetailRow('Nome:', details.surveyName, context),
                _buildDetailRow('Criador:', details.creatorId, context),
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
                  _formatDate(details.createdAt),
                  context,
                ),
                _buildDetailRow(
                  'Última Modificação:',
                  _formatDate(details.modifiedAt),
                  context,
                ),
              ],
            ),
            context,
          ),
          if (details.descriptionHtml.isNotEmpty)
            _buildInfoCard(
              'Descrição',
              Html(
                data: details.descriptionHtml,
                style: {
                  'body': Style(
                    fontSize: FontSize(16),
                    lineHeight: const LineHeight(1.5),
                  ),
                  'p': Style(margin: Margins.only(bottom: 12)),
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
                  details.totalQuestions.toString(),
                  context,
                ),
                _buildDetailRow(
                  'Possui notas finais:',
                  details.hasFinalNotes ? 'Sim' : 'Não',
                  context,
                ),
              ],
            ),
            context,
          ),
        ],
      ),
    );
  }
}
