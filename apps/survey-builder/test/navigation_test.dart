import 'package:design_system_flutter/components/admin/ds_admin_shell.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:survey_builder/core/auth/builder_auth_controller.dart';
import 'package:survey_builder/core/auth/builder_auth_models.dart';
import 'package:survey_builder/core/auth/builder_auth_repository.dart';
import 'package:survey_builder/features/auth/pages/builder_login_page.dart';
import 'package:survey_builder/features/survey/pages/task_dashboard_page.dart';

void main() {
  group('Builder navigation', () {
    testWidgets('admin shell updates the selected section', (tester) async {
      await tester.pumpWidget(const MaterialApp(home: _ShellHarness()));

      expect(find.text('Section: dashboard'), findsOneWidget);

      await tester.tap(find.text('Prompts'));
      await tester.pumpAndSettle();

      expect(find.text('Section: prompts'), findsOneWidget);
    });

    testWidgets('dashboard shortcuts call the section callback', (
      tester,
    ) async {
      String? selectedSection;

      await tester.pumpWidget(
        MaterialApp(
          home: TaskDashboardPage(
            embedded: true,
            onTaskSelected: (section) => selectedSection = section,
          ),
        ),
      );

      await tester.ensureVisible(
        find.widgetWithText(OutlinedButton, 'Pontos de acesso'),
      );
      await tester.tap(find.widgetWithText(OutlinedButton, 'Pontos de acesso'));
      await tester.pump();

      expect(selectedSection, 'access-points');
    });
  });

  group('Builder login', () {
    testWidgets('shared login card exposes password visibility toggle', (
      tester,
    ) async {
      final controller = BuilderAuthController(
        repository: _FakeBuilderAuthRepository(),
      );
      addTearDown(controller.dispose);

      await tester.pumpWidget(
        MaterialApp(
          home: BuilderLoginPage(
            controller: controller,
            message: 'Faça login para acessar o construtor administrativo.',
          ),
        ),
      );

      final toggleButton = find.byTooltip('Mostrar senha');
      expect(toggleButton, findsOneWidget);

      await tester.ensureVisible(toggleButton);
      await tester.tap(toggleButton, warnIfMissed: false);
      await tester.pump();

      expect(find.byTooltip('Ocultar senha'), findsOneWidget);
    });
  });
}

class _ShellHarness extends StatefulWidget {
  const _ShellHarness();

  @override
  State<_ShellHarness> createState() => _ShellHarnessState();
}

class _ShellHarnessState extends State<_ShellHarness> {
  String _currentSection = 'dashboard';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: DsAdminShell(
        navigation: const [
          NavigationItem(
            key: 'dashboard',
            label: 'Dashboard',
            icon: Icons.space_dashboard_outlined,
          ),
          NavigationItem(
            key: 'prompts',
            label: 'Prompts',
            icon: Icons.text_fields_outlined,
          ),
        ],
        currentSection: _currentSection,
        onNavigateToSection: (section) {
          setState(() => _currentSection = section);
        },
        child: Center(child: Text('Section: $_currentSection')),
      ),
    );
  }
}

class _FakeBuilderAuthRepository extends BuilderAuthRepository {
  _FakeBuilderAuthRepository()
    : super(
        client: Dio(BaseOptions(baseUrl: 'http://localhost')),
        requestPath: (path, [queryParameters]) => '/$path',
      );

  @override
  Future<BuilderSession> bootstrapSession() {
    throw UnimplementedError();
  }

  @override
  Future<BuilderSession> login({
    required String email,
    required String password,
  }) {
    throw UnimplementedError();
  }

  @override
  void dispose() {}
}
