import 'package:design_system_flutter/theme/app_theme.dart';
import 'package:design_system_flutter/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:survey_builder/core/auth/builder_auth_controller.dart';
import 'package:survey_builder/core/auth/builder_auth_models.dart';
import 'package:survey_builder/core/config/runtime_config.dart';
import 'package:survey_builder/core/services/api_config.dart';
import 'package:survey_builder/features/auth/pages/builder_login_page.dart';
import 'package:survey_builder/features/survey/pages/survey_list_page.dart';
import 'package:survey_builder/features/survey/pages/task_dashboard_page.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await RuntimeConfig.load();
  runApp(const SurveyBuilderApp());
}

class SurveyBuilderApp extends StatefulWidget {
  const SurveyBuilderApp({super.key});

  @override
  State<SurveyBuilderApp> createState() => _SurveyBuilderAppState();
}

class _SurveyBuilderAppState extends State<SurveyBuilderApp> {
  late final BuilderAuthController _authController;

  @override
  void initState() {
    super.initState();
    _authController = BuilderAuthController();
    ApiConfig.configureBuilderAuth(
      csrfTokenProvider: () => _authController.csrfToken,
      onAuthFailure: _authController.handleAuthFailure,
    );
    _authController.bootstrap();
  }

  @override
  void dispose() {
    ApiConfig.clearBuilderAuth();
    _authController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _authController,
      builder: (context, child) {
        return MaterialApp(
          title: 'LAPAN Construtor de Questionários',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.dark(),
          localizationsDelegates: const [
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: const [Locale('pt', 'BR')],
          locale: const Locale('pt', 'BR'),
          builder: (context, child) => DsEmotionalToneProvider(
            profile: DsToneProfile.admin,
            child: child ?? const SizedBox.shrink(),
          ),
          home: _buildHome(),
        );
      },
    );
  }

  Widget _buildHome() {
    switch (_authController.status) {
      case BuilderAuthStatus.loading:
        return const _BuilderLoadingPage();
      case BuilderAuthStatus.authenticated:
        return TaskDashboardPage(authController: _authController);
      case BuilderAuthStatus.unauthenticated:
        return BuilderLoginPage(
          controller: _authController,
          message: _authController.message,
        );
    }
  }
}

class _BuilderLoadingPage extends StatelessWidget {
  const _BuilderLoadingPage();

  @override
  Widget build(BuildContext context) {
    return const DsScaffold(
      title: 'Construtor Administrativo',
      subtitle: 'Validando a sessão administrativa atual.',
      useSafeArea: true,
      body: Center(child: CircularProgressIndicator()),
    );
  }
}
