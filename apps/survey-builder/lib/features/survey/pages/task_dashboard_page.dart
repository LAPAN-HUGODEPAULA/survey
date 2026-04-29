import 'package:design_system_flutter/widgets.dart';
import 'package:flutter/material.dart';
import 'package:survey_builder/core/auth/builder_auth_controller.dart';
import 'package:survey_builder/features/survey/pages/survey_form_page.dart';

class TaskDashboardPage extends StatelessWidget {
  const TaskDashboardPage({
    super.key,
    this.authController,
    this.onTaskSelected,
    this.embedded = false,
  });

  final BuilderAuthController? authController;
  final void Function(String section)? onTaskSelected;
  final bool embedded;

  @override
  Widget build(BuildContext context) {
    if (embedded) {
      return _DashboardContent(
        authController: authController,
        onTaskSelected: onTaskSelected,
      );
    }
    return DsScaffold(
      title: 'Dashboard',
      subtitle: 'Central de administração',
      showAmbientGreeting: true,
      userName: authController?.profile?.fullName,
      useSafeArea: true,
      actions: [
        IconButton(
          tooltip: 'Encerrar sessão',
          onPressed: authController?.logout,
          icon: const Icon(Icons.logout),
        ),
      ],
      body: _DashboardContent(
        authController: authController,
        onTaskSelected: onTaskSelected,
      ),
    );
  }
}

class _DashboardContent extends StatelessWidget {
  const _DashboardContent({this.authController, this.onTaskSelected});

  final BuilderAuthController? authController;
  final void Function(String section)? onTaskSelected;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final name = authController?.profile?.fullName;

    return LayoutBuilder(
      builder: (context, constraints) {
        final availableWidth = constraints.maxWidth;
        final columnCount = availableWidth >= 1480
            ? 4
            : availableWidth >= 1080
                ? 3
                : availableWidth >= 760
                    ? 2
                    : 1;
        final cardWidth = columnCount == 1
            ? availableWidth
            : (availableWidth - (16 * (columnCount - 1))) / columnCount;

        return SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              DsSection(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name == null || name.isEmpty
                          ? 'Painel administrativo'
                          : 'Bem-vindo de volta, $name',
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Acesse rapidamente questionários, prompts, personas e pontos de acesso.',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'Ações principais',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 16,
                runSpacing: 16,
                children: [
                  SizedBox(
                    width: cardWidth,
                    child: _PrimaryActionCard(
                      icon: Icons.add_task_rounded,
                      title: 'Criar questionário',
                      description:
                          'Abrir o formulário de criação com rascunho vazio.',
                      onTap: () => _createSurvey(context),
                    ),
                  ),
                  SizedBox(
                    width: cardWidth,
                    child: _PrimaryActionCard(
                      icon: Icons.assignment_rounded,
                      title: 'Gerenciar questionários',
                      description:
                          'Voltar para o catálogo principal do construtor.',
                      onTap: () => onTaskSelected?.call('surveys'),
                    ),
                  ),
                  SizedBox(
                    width: cardWidth,
                    child: _PrimaryActionCard(
                      icon: Icons.text_fields_rounded,
                      title: 'Abrir prompts',
                      description: 'Revisar catálogo de prompts reutilizáveis.',
                      onTap: () => onTaskSelected?.call('prompts'),
                    ),
                  ),
                  SizedBox(
                    width: cardWidth,
                    child: _PrimaryActionCard(
                      icon: Icons.psychology_alt_rounded,
                      title: 'Gerenciar personas',
                      description:
                          'Atualizar perfis de saída e instruções editoriais.',
                      onTap: () => onTaskSelected?.call('personas'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Text(
                'Atalhos',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: [
                  DsOutlinedButton(
                    label: 'Pontos de acesso',
                    icon: Icons.hub_rounded,
                    onPressed: () => onTaskSelected?.call('access-points'),
                  ),
                  DsOutlinedButton(
                    label: 'Sair',
                    icon: Icons.logout_rounded,
                    onPressed: authController?.logout,
                  ),
                ],
              ),
              const SizedBox(height: 24),
              const _RecentUpdatesSection(),
            ],
          ),
        );
      },
    );
  }

  Future<void> _createSurvey(BuildContext context) async {
    final changed = await Navigator.of(context).push<bool>(
      MaterialPageRoute<bool>(
        builder: (_) => const SurveyFormPage(initialDraft: null),
      ),
    );

    if (changed == true && context.mounted) {
      showDsToast(
        context,
        feedback: const DsFeedbackMessage(
          severity: DsStatusType.success,
          title: 'Questionário criado',
          message: 'Novo questionário criado com sucesso.',
        ),
      );
    }
  }
}

class _PrimaryActionCard extends StatelessWidget {
  const _PrimaryActionCard({
    required this.icon,
    required this.title,
    required this.description,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String description;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return DsSection(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 28, color: theme.colorScheme.primary),
          const SizedBox(height: 12),
          Text(
            title,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            description,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 16),
          DsFilledButton(
            label: 'Abrir',
            icon: Icons.arrow_forward_rounded,
            onPressed: onTap,
          ),
        ],
      ),
    );
  }
}

class _RecentUpdatesSection extends StatelessWidget {
  const _RecentUpdatesSection();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    const updates = [
      (
        title: 'Questionários',
        detail: 'Revise questionários publicados e rascunhos pendentes.',
      ),
      (
        title: 'Prompts',
        detail: 'Compare textos reutilizáveis com as personas padrão.',
      ),
      (
        title: 'Governança',
        detail: 'Audite acessos administrativos e integrações ativas.',
      ),
    ];

    return DsSection(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Resumo operacional',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 16),
          for (final update in updates) ...[
            Text(
              update.title,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              update.detail,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            if (update != updates.last) const SizedBox(height: 16),
          ],
        ],
      ),
    );
  }
}
