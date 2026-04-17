import 'package:flutter/material.dart';
import 'package:design_system_flutter/widgets.dart';
import 'package:survey_builder/core/auth/builder_auth_controller.dart';
import 'package:survey_builder/features/survey/pages/survey_form_page.dart';

class TaskDashboardPage extends StatelessWidget {
  const TaskDashboardPage({
    super.key,
    this.authController,
    this.onTaskSelected,
  });

  final BuilderAuthController? authController;
  final Function(String)? onTaskSelected;

  @override
  Widget build(BuildContext context) {
    return DsScaffold(
      title: 'Dashboard',
      subtitle: 'Central de administração',
      showAmbientGreeting: true,
      userName: authController?.profile?.fullName,
      useSafeArea: true,
      actions: [
        IconButton(
          tooltip: 'Encerrar sessão',
          onPressed: authController == null
              ? null
              : () => authController!.logout(),
          icon: const Icon(Icons.logout),
        ),
      ],
      body: DsAdminShell(
        navigation: _getNavigationItems(),
        currentSection: 'dashboard',
        userProfile: _buildUserProfile(context),
        recentUpdates: _getRecentUpdates(),
        child: _buildDashboardContent(context),
      ),
    );
  }

  List<NavigationItem> _getNavigationItems() {
    return [
      NavigationItem(
        key: 'dashboard',
        label: 'Dashboard',
        icon: Icons.dashboard,
        emotion: DsEmotion.neutral,
        hasChildren: false,
      ),
      NavigationItem(
        key: 'surveys',
        label: 'Questionários',
        icon: Icons.assignment,
        emotion: DsEmotion.neutral,
        hasChildren: true,
      ),
      NavigationItem(
        key: 'prompts',
        label: 'Prompts',
        icon: Icons.text_fields,
        emotion: DsEmotion.neutral,
        hasChildren: false,
      ),
      NavigationItem(
        key: 'personas',
        label: 'Personas',
        icon: Icons.face,
        emotion: DsEmotion.neutral,
        hasChildren: true,
      ),
      NavigationItem(
        key: 'access-points',
        label: 'Acessos',
        icon: Icons.hub,
        emotion: DsEmotion.neutral,
        hasChildren: false,
      ),
    ];
  }

  Widget _buildUserProfile(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: Theme.of(context).colorScheme.primary,
            child: Text(
              (authController?.profile?.fullName ?? 'Usuário')
                  .characters
                  .first
                  .toUpperCase(),
              style: const TextStyle(color: Colors.white),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  authController?.profile?.fullName ?? 'Usuário',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                Text(
                  authController?.profile?.email ?? '',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            tooltip: 'Configurações',
            icon: const Icon(Icons.settings),
            onPressed: () {},
          ),
        ],
      ),
    );
  }

  List<RecentUpdate> _getRecentUpdates() {
    return [
      RecentUpdate(
        title: 'Questionário atualizado',
        description: 'Questionário "Diabetes Screening" foi modificado há 2 horas',
        time: '2h atrás',
      ),
      RecentUpdate(
        title: 'Prompt criado',
        description: 'Novo prompt "Resumo Clínico" criado ontem',
        time: 'Ontem',
      ),
      RecentUpdate(
        title: 'Persona compartilhada',
        description: 'Persona "Cardiologista" compartilhada com a equipe',
        time: '2 dias atrás',
      ),
    ];
  }

  Widget _buildDashboardContent(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Welcome Message
          Text(
            'Bem-vindo de volta, ${authController?.profile?.fullName ?? 'Administrador'}',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            'Aqui estão suas tarefas administrativas mais recentes',
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          const SizedBox(height: 32),

          // Primary Actions
          Text(
            'Ações Principais',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 16,
            runSpacing: 16,
            children: [
              _buildTaskButton(
                context,
                icon: Icons.add_rounded,
                label: 'Criar Questionário',
                color: Theme.of(context).colorScheme.primary,
                onTap: () => _createSurvey(context),
              ),
              _buildTaskButton(
                context,
                icon: Icons.edit_rounded,
                label: 'Editar Questionário',
                color: Theme.of(context).colorScheme.secondary,
                onTap: () => _editSurvey(context),
              ),
              _buildTaskButton(
                context,
                icon: Icons.lightbulb_rounded,
                label: 'Quick Prompts',
                color: Theme.of(context).colorScheme.tertiary,
                onTap: () => _quickPrompts(context),
              ),
              _buildTaskButton(
                context,
                icon: Icons.people_rounded,
                label: 'Gerenciar Personas',
                color: Theme.of(context).colorScheme.outline,
                onTap: () => _managePersonas(context),
              ),
            ],
          ),
          const SizedBox(height: 32),

          // Secondary Actions
          Text(
            'Outras Ações',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              _buildSecondaryTaskButton(
                context,
                icon: Icons.description_rounded,
                label: 'Modelos',
                onTap: () => _showTemplates(context),
              ),
              _buildSecondaryTaskButton(
                context,
                icon: Icons.file_download_rounded,
                label: 'Importar/Exportar',
                onTap: () => _showImportExport(context),
              ),
              _buildSecondaryTaskButton(
                context,
                icon: Icons.settings_rounded,
                label: 'Configurações',
                onTap: () => _showSettings(context),
              ),
              _buildSecondaryTaskButton(
                context,
                icon: Icons.help_outline_rounded,
                label: 'Ajuda',
                onTap: () => _showHelp(context),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTaskButton(
    BuildContext context, {
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return SizedBox(
      width: 200,
      child: DsTaskButton(
        icon: icon,
        label: label,
        onTap: onTap,
        emotion: DsEmotion.neutral,
        size: DsTaskButtonSize.large,
      ),
    );
  }

  Widget _buildSecondaryTaskButton(
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
              size: 20,
              color: Theme.of(context).colorScheme.onSurface,
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _createSurvey(BuildContext context) async {
    final changed = await Navigator.of(context).push<bool>(
      MaterialPageRoute<bool>(
        builder: (_) => SurveyFormPage(initialDraft: null),
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

  void _editSurvey(BuildContext context) {
    // Navigate to survey list with edit mode
    onTaskSelected?.call('surveys');
  }

  void _quickPrompts(BuildContext context) {
    // Navigate directly to prompt creation with quick access
    onTaskSelected?.call('prompts');
  }

  void _managePersonas(BuildContext context) {
    // Navigate to persona management
    onTaskSelected?.call('personas');
  }

  void _showTemplates(BuildContext context) {
    // TODO: Implement templates view
    showDsToast(
      context,
      feedback: const DsFeedbackMessage(
        severity: DsStatusType.info,
        title: 'Modelos',
        message: 'Visualização de modelos em desenvolvimento.',
      ),
    );
  }

  void _showImportExport(BuildContext context) {
    // TODO: Implement import/export functionality
    showDsToast(
      context,
      feedback: const DsFeedbackMessage(
        severity: DsStatusType.info,
        title: 'Importar/Exportar',
        message: 'Funcionalidade de importação/exportação em desenvolvimento.',
      ),
    );
  }

  void _showSettings(BuildContext context) {
    // TODO: Implement settings page
    showDsToast(
      context,
      feedback: const DsFeedbackMessage(
        severity: DsStatusType.info,
        title: 'Configurações',
        message: 'Página de configurações em desenvolvimento.',
      ),
    );
  }

  void _showHelp(BuildContext context) {
    // TODO: Implement help page
    showDsToast(
      context,
      feedback: const DsFeedbackMessage(
        severity: DsStatusType.info,
        title: 'Ajuda',
        message: 'Sistema de ajuda em desenvolvimento.',
      ),
    );
  }
}