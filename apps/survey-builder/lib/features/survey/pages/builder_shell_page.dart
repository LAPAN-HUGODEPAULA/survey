import 'package:design_system_flutter/widgets.dart';
import 'package:flutter/material.dart';
import 'package:survey_builder/core/auth/builder_auth_controller.dart';
import 'package:survey_builder/features/survey/pages/agent_access_point_list_page.dart';
import 'package:survey_builder/features/survey/pages/persona_skill_list_page.dart';
import 'package:survey_builder/features/survey/pages/screener_settings_page.dart';
import 'package:survey_builder/features/survey/pages/survey_list_page.dart';
import 'package:survey_builder/features/survey/pages/survey_prompt_list_page.dart';
import 'package:survey_builder/features/survey/pages/task_dashboard_page.dart';

class BuilderShellPage extends StatefulWidget {
  const BuilderShellPage({super.key, required this.authController});

  final BuilderAuthController authController;

  @override
  State<BuilderShellPage> createState() => _BuilderShellPageState();
}

class _BuilderShellPageState extends State<BuilderShellPage> {
  static const _dashboardSection = 'dashboard';
  static const _surveysSection = 'surveys';
  static const _promptsSection = 'prompts';
  static const _personasSection = 'personas';
  static const _accessPointsSection = 'access-points';
  static const _screenerSettingsSection = 'screener-settings';

  String _currentSection = _dashboardSection;
  int _refreshVersion = 0;

  List<NavigationItem> get _navigation => const [
    NavigationItem(
      key: _dashboardSection,
      label: 'Dashboard',
      icon: Icons.space_dashboard_outlined,
    ),
    NavigationItem(
      key: _surveysSection,
      label: 'Questionários',
      icon: Icons.assignment_outlined,
    ),
    NavigationItem(
      key: _promptsSection,
      label: 'Prompts',
      icon: Icons.text_fields_outlined,
    ),
    NavigationItem(
      key: _personasSection,
      label: 'Personas',
      icon: Icons.psychology_alt_outlined,
    ),
    NavigationItem(
      key: _accessPointsSection,
      label: 'Acessos',
      icon: Icons.hub_outlined,
    ),
    NavigationItem(
      key: _screenerSettingsSection,
      label: 'Configurações',
      icon: Icons.settings_outlined,
    ),
  ];

  void _handleNavigateToSection(String section) {
    if (section == _currentSection) {
      _refreshCurrentSection();
      return;
    }
    setState(() => _currentSection = section);
  }

  void _refreshCurrentSection() {
    setState(() => _refreshVersion += 1);
  }

  Widget _buildCurrentSection() {
    final sectionKey = ValueKey<String>('$_currentSection-$_refreshVersion');
    switch (_currentSection) {
      case _surveysSection:
        return SurveyListPage(
          key: sectionKey,
          embedded: true,
          onNavigateSection: _handleNavigateToSection,
        );
      case _promptsSection:
        return SurveyPromptListPage(key: sectionKey, embedded: true);
      case _personasSection:
        return PersonaSkillListPage(key: sectionKey, embedded: true);
      case _accessPointsSection:
        return AgentAccessPointListPage(key: sectionKey, embedded: true);
      case _screenerSettingsSection:
        return ScreenerSettingsPage(key: sectionKey, embedded: true);
      case _dashboardSection:
        return TaskDashboardPage(
          key: sectionKey,
          authController: widget.authController,
          onTaskSelected: _handleNavigateToSection,
          embedded: true,
        );
    }
    return const SizedBox.shrink();
  }

  Widget _buildUserProfile(BuildContext context) {
    final profile = widget.authController.profile;
    if (profile == null) {
      return const SizedBox.shrink();
    }
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            profile.fullName.isEmpty ? profile.email : profile.fullName,
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            profile.email,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 12),
          DsTextButton(
            label: 'Encerrar sessão',
            icon: Icons.logout_rounded,
            onPressed: widget.authController.logout,
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return DsScaffold(
      useSafeArea: true,
      bodyPadding: EdgeInsets.zero,
      maxBodyWidth: 1920,
      body: DsAdminShell(
        navigation: _navigation,
        currentSection: _currentSection,
        onNavigateToSection: _handleNavigateToSection,
        onRefresh: _refreshCurrentSection,
        userProfile: _buildUserProfile(context),
        headerActions: [
          IconButton(
            tooltip: 'Encerrar sessão',
            onPressed: widget.authController.logout,
            icon: const Icon(Icons.logout),
          ),
        ],
        child: _buildCurrentSection(),
      ),
    );
  }
}
