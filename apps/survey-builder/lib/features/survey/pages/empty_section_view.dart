import 'package:design_system_flutter/widgets.dart';
import 'package:flutter/material.dart';

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
        children: [
          Expanded(
            child: DsEmptyState(
              visual: Icon(
                _sectionIcon(),
                size: 64,
                color: Theme.of(context).colorScheme.primary,
              ),
              title: _title(),
              description: message ?? _description(),
              actionLabel: 'Criar novo ${_sectionLabel()}',
              onAction: onCreate,
            ),
          ),
          if (!hasData) ...[
            const SizedBox(height: 16),
            DsOutlinedButton(
              label: 'Explorar exemplos',
              icon: Icons.explore_rounded,
              onPressed: onExplore,
            ),
          ],
          const SizedBox(height: 16),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            alignment: WrapAlignment.center,
            children: _relatedActions(context),
          ),
        ],
      ),
    );
  }

  IconData _sectionIcon() {
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
        return Icons.folder_open_rounded;
    }
  }

  String _sectionLabel() {
    switch (section) {
      case 'surveys':
        return 'questionario';
      case 'prompts':
        return 'prompt';
      case 'personas':
        return 'persona';
      case 'access-points':
        return 'ponto de acesso';
      default:
        return 'item';
    }
  }

  String _title() {
    switch (section) {
      case 'survey':
      case 'surveys':
        return 'Nenhum questionario encontrado';
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

  String _description() {
    switch (section) {
      case 'survey':
      case 'surveys':
        return 'Comece criando seu primeiro questionario para coletar respostas dos pacientes.';
      case 'prompt':
      case 'prompts':
        return 'Crie prompts reutilizaveis para orientar respostas e relatorios clinicos.';
      case 'persona':
      case 'personas':
        return 'Defina personas especializadas para padronizar o tom e o foco clinico.';
      case 'access-point':
      case 'access-points':
        return 'Configure pontos de acesso para mapear prompts e personas por fluxo.';
      default:
        return 'Nao ha itens nesta categoria ainda.';
    }
  }

  List<Widget> _relatedActions(BuildContext context) {
    switch (section) {
      case 'prompt':
      case 'prompts':
        return [
          DsTextButton(
            label: 'Ajuda com prompts',
            onPressed: () => _showDialog(
              context,
              title: 'Criando bons prompts',
              child: const Text(
                'Prompts eficazes explicam contexto, formato esperado e criterio clinico de resposta.',
              ),
            ),
          ),
        ];
      case 'persona':
      case 'personas':
        return [
          DsTextButton(
            label: 'Exemplos de personas',
            onPressed: () => _showDialog(
              context,
              title: 'Exemplos de personas',
              child: const Text(
                'Cardiologista, endocrinologista e clinico geral sao exemplos de perfis reutilizaveis.',
              ),
            ),
          ),
        ];
      default:
        return const [];
    }
  }

  Future<void> _showDialog(
    BuildContext context, {
    required String title,
    required Widget child,
  }) {
    return showDialog<void>(
      context: context,
      builder: (dialogContext) => DsDialog(
        title: title,
        content: child,
        actions: [
          DsTextButton(
            label: 'Fechar',
            onPressed: () => Navigator.of(dialogContext).pop(),
          ),
        ],
      ),
    );
  }
}
