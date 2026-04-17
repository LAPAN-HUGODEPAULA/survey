import 'package:flutter/material.dart';
import 'package:design_system_flutter/widgets.dart';
import 'package:survey_builder/features/survey/pages/task_dashboard_page.dart';

class EmptySectionView extends StatelessWidget {
  const EmptySectionView({
    super.key,
    required this.section,
    required this.onCreate,
    required this.onExplore,
    this.message,
    this.hasData = false,
  });

  final String section;
  final VoidCallback onCreate;
  final VoidCallback onExplore;
  final String? message;
  final bool hasData;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Icon and Title
          Icon(
            _getSectionIcon(),
            size: 80,
            color: Theme.of(context).colorScheme.primary.withOpacity(0.2),
          ),
          const SizedBox(height: 24),
          Text(
            _getTitle(),
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          Text(
            message ?? _getMessage(),
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 48),

          // Primary Action
          SizedBox(
            width: double.infinity,
            child: DsFilledButton(
              label: 'Criar novo $section',
              icon: Icons.add_rounded,
              onPressed: onCreate,
              size: DsButtonSize.large,
            ),
          ),
          const SizedBox(height: 16),

          // Secondary Actions
          if (!hasData) ...[
            SizedBox(
              width: double.infinity,
              child: DsOutlinedButton(
                label: 'Explorar exemplos',
                icon: Icons.explore_rounded,
                onPressed: onExplore,
              ),
            ),
            const SizedBox(height: 24),
          ],

          // Related Links
          Wrap(
            spacing: 12,
            alignment: WrapAlignment.center,
            children: _buildRelatedActions(context),
          ),
        ],
      ),
    );
  }

  IconData _getSectionIcon() {
    switch (section) {
      case 'survey':
      case 'surveys':
        return Icons.assignment_rounded;
      case 'prompt':
      case 'prompts':
        return Icons.text_fields_rounded;
      case 'persona':
      case 'personas':
        return Icons.face_rounded;
      case 'access-point':
      case 'access-points':
        return Icons.hub_rounded;
      default:
        return Icons.folder_rounded;
    }
  }

  String _getTitle() {
    switch (section) {
      case 'survey':
      case 'surveys':
        return 'Nenhum questionário encontrado';
      case 'prompt':
      case 'prompts':
        return 'Nenhum prompt encontrado';
      case 'persona':
      case 'personas':
        return 'Nenhuma persona encontrada';
      case 'access-point':
      case 'access-points':
        return 'Nenhum ponto de acesso encontrado';
      default:
        return 'Nenhum item encontrado';
    }
  }

  String _getMessage() {
    switch (section) {
      case 'survey':
      case 'surveys':
        return 'Comece criando seu primeiro questionário para coletar respostas dos pacientes.';
      case 'prompt':
      case 'prompts':
        return 'Crie prompts de IA para melhorar as respostas e gerar relatórios clínicos.';
      case 'persona':
      case 'personas':
        return 'Defina personas especializadas para personalizar as respostas do assistente.';
      case 'access-point':
      case 'access-points':
        return 'Configure pontos de acesso para integrar o construtor com outros sistemas.';
      default:
        return 'Não há itens nesta categoria ainda.';
    }
  }

  List<Widget> _buildRelatedActions(BuildContext context) {
    switch (section) {
      case 'survey':
      case 'surveys':
        return [
          _buildRelatedButton(
            context,
            icon: Icons.text_fields_rounded,
            label: 'Precisa de prompts?',
            onTap: () => Navigator.of(context).pushNamed('/prompts'),
          ),
          _buildRelatedButton(
            context,
            icon: face_rounded,
            label: 'Ver personas',
            onTap: () => Navigator.of(context).pushNamed('/personas'),
          ),
        ];
      case 'prompt':
      case 'prompts':
        return [
          _buildRelatedButton(
            context,
            icon: Icons.face,
            label: 'Ver personas',
            onTap: () => Navigator.of(context).pushNamed('/personas'),
          ),
          _buildRelatedButton(
            context,
            icon: Icons.help_outline_rounded,
            label: 'Ajuda com prompts',
            onTap: () => _showHelp(context),
          ),
        ];
      case 'persona':
      case 'personas':
        return [
          _buildRelatedButton(
            context,
            icon: Icons.assignment_rounded,
            label: 'Ver questionários',
            onTap: () => Navigator.of(context).pushNamed('/surveys'),
          ),
          _buildRelatedButton(
            context,
            icon: Icons.lightbulb_rounded,
            label: 'Exemplos de personas',
            onTap: () => _showExamples(context),
          ),
        ];
      default:
        return [];
    }
  }

  Widget _buildRelatedButton(
    BuildContext context, {
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          border: Border.all(
            color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
            width: 1,
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 18,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.w500,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showHelp(BuildContext context) {
    showDsDialog(
      context,
      title: 'Criando bons prompts',
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('Bons prompts devem ser específicos e incluir contexto:', style: Theme.of(context).textTheme.bodyMedium),
          const SizedBox(height: 16),
          _buildHelpItem(
            context,
            title: 'Especifique o tom',
            content: 'Use: "responda de forma profissional"',
          ),
          _buildHelpItem(
            context,
            title: 'Inclua exemplos',
            content: 'Forneça exemplos de respostas desejadas',
          ),
          _buildHelpItem(
            context,
            title: 'Defina o formato',
            content: 'Especifique como estruturar a resposta',
          ),
        ],
      ),
      actions: [
        DsTextButton(
          label: 'Entendido',
          onPressed: () => Navigator.of(context).pop(),
        ),
      ],
    );
  }

  void _showExamples(BuildContext context) {
    showDsDialog(
      context,
      title: 'Exemplos de personas',
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('Alguns exemplos de personas comuns:', style: Theme.of(context).textTheme.bodyMedium),
          const SizedBox(height: 16),
          _buildPersonaExample(
            context,
            name: 'Cardiologista',
            description: 'Foco em condições cardiovasculares e prevenção',
          ),
          _buildPersonaExample(
            context,
            name: 'Endocrinologista',
            description: 'Especialista em diabetes e doenças metabólicas',
          ),
          _buildPersonaExample(
            context,
            name: 'Médico Geral',
            description: 'Atendimento primário e saúde preventiva',
          ),
        ],
      ),
      actions: [
        DsTextButton(
          label: 'Fechar',
          onPressed: () => Navigator.of(context).pop(),
        ),
      ],
    );
  }

  Widget _buildHelpItem(BuildContext context, {required String title, required String content}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600)),
          const SizedBox(height: 4),
          Text(content, style: Theme.of(context).textTheme.bodySmall),
        ],
      ),
    );
  }

  Widget _buildPersonaExample(BuildContext context, {required String name, required String description}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(4),
            ),
            child: Icon(
              Icons.person,
              size: 16,
              color: Theme.of(context).colorScheme.onPrimaryContainer,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600)),
                const SizedBox(height: 2),
                Text(description, style: Theme.of(context).textTheme.bodySmall),
              ],
            ),
          ),
        ],
      ),
    );
  }
}