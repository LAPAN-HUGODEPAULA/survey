import 'package:design_system_flutter/components/respondent_flow/respondent_flow_models.dart';
import 'package:design_system_flutter/widgets/ds_buttons.dart';
import 'package:design_system_flutter/widgets/ds_surface.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';

class DsSurveyInstructionGate extends StatefulWidget {
  const DsSurveyInstructionGate({
    super.key,
    required this.instructions,
    required this.onContinue,
    this.buttonLabel = 'Iniciar Questionário',
  });

  final DsSurveyInstructionData instructions;
  final VoidCallback onContinue;
  final String buttonLabel;

  @override
  State<DsSurveyInstructionGate> createState() =>
      _DsSurveyInstructionGateState();
}

class _DsSurveyInstructionGateState extends State<DsSurveyInstructionGate> {
  String? _selectedAnswer;
  bool _showError = false;

  void _tryContinue() {
    if (_selectedAnswer == widget.instructions.correctAnswer) {
      setState(() => _showError = false);
      widget.onContinue();
      return;
    }
    setState(() => _showError = true);
  }

  Widget _buildAnswerTile(String option) {
    final theme = Theme.of(context);
    final isSelected = _selectedAnswer == option;
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(
        isSelected ? Icons.radio_button_checked : Icons.radio_button_off,
        color:
            isSelected ? theme.colorScheme.primary : theme.colorScheme.outline,
      ),
      title: Text(option),
      onTap: () => setState(() {
        _selectedAnswer = option;
        _showError = false;
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return DsSection(
      eyebrow: 'Antes de começar',
      title: 'Confirme as instruções',
      subtitle:
          'Selecione a resposta correta para prosseguir com o questionário.',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          DsFocusFrame(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 360),
              child: Scrollbar(
                thumbVisibility: true,
                child: SingleChildScrollView(
                  child: Html(
                    data: widget.instructions.preambleHtml,
                    style: {
                      'body': Style(
                        fontSize: FontSize(16),
                        lineHeight: const LineHeight(1.4),
                      ),
                      'p': Style(margin: Margins.only(bottom: 12)),
                      'ul': Style(
                        margin: Margins.symmetric(vertical: 8),
                        padding: HtmlPaddings.only(left: 20),
                      ),
                      'li': Style(margin: Margins.only(bottom: 4)),
                    },
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            widget.instructions.questionText,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
          ),
          const SizedBox(height: 16),
          ...widget.instructions.answers.map(_buildAnswerTile),
          if (_showError)
            Padding(
              padding: const EdgeInsets.only(top: 16),
              child: DsPanel(
                tone: DsPanelTone.high,
                backgroundColor: colorScheme.errorContainer,
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    Icon(
                      Icons.error_outline,
                      color: colorScheme.onErrorContainer,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Por favor, selecione a resposta correta para continuar.',
                        style: TextStyle(
                          color: colorScheme.onErrorContainer,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: DsFilledButton(
              label: widget.buttonLabel,
              onPressed: _tryContinue,
              size: DsButtonSize.large,
            ),
          ),
        ],
      ),
    );
  }
}
