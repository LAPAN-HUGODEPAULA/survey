import 'package:design_system_flutter/widgets.dart';
import 'package:flutter/material.dart';

class AgentAccessPointListPage extends StatelessWidget {
  const AgentAccessPointListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const DsScaffold(
      title: 'Pontos de acesso',
      subtitle: 'Gerencie os vínculos entre fluxos, prompts e personas.',
      body: DsEmptyState(
        title: 'Catálogo em preparação',
        description:
            'Os contratos de pontos de acesso já estão no repositório, mas a tela administrativa ainda não foi implementada neste app.',
      ),
    );
  }
}
