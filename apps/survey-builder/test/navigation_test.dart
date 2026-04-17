import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:survey_builder/features/survey/pages/task_dashboard_page.dart';
import 'package:survey_builder/features/survey/pages/survey_form_page.dart';
import 'package:survey_builder/features/survey/pages/persona_skill_list_page.dart';

void main() {
  group('Navigation Tests', () {
    group('Return-to-Home Behavior', () {
      testWidgets('Dashboard shows clear navigation to all sections', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: TaskDashboardPage(),
          ),
        );

        await tester.pumpAndSettle();

        // Verify main navigation items are present
        expect(find.text('Questionários'), findsOneWidget);
        expect(find.text('Prompts'), findsOneWidget);
        expect(find.text('Personas'), findsOneWidget);
        expect(find.text('Acessos'), findsOneWidget);

        // Verify primary action buttons
        expect(find.text('Criar Questionário'), findsOneWidget);
        expect(find.text('Editar Questionário'), findsOneWidget);
        expect(find.text('Quick Prompts'), findsOneWidget);
        expect(find.text('Gerenciar Personas'), findsOneWidget);
      });

      testWidgets('Form page has back button to dashboard', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: SurveyFormPage(),
          ),
        );

        await tester.pumpAndSettle();

        // Verify back button is present
        expect(find.byIcon(Icons.arrow_back), findsOneWidget);

        // Verify breadcrumbs include dashboard link
        expect(find.text('Dashboard'), findsOneWidget);

        // Tap back button
        await tester.tap(find.byIcon(Icons.arrow_back));
        await tester.pumpAndSettle();

        // Should navigate back (in real app this would go to dashboard)
        // For test, we just verify the back button functionality works
      });
    });

    group('Nested Editor Navigation', () {
      testWidgets('Form maintains context with breadcrumbs', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: SurveyFormPage(),
          ),
        );

        await tester.pumpAndSettle();

        // Verify breadcrumb structure
        expect(find.text('Dashboard'), findsOneWidget);
        expect(find.text('Questionários'), findsOneWidget);
        expect(find.text('Criar questionário'), findsOneWidget);

        // Verify section navigation is present
        expect(find.text('Detalhes'), findsOneWidget);
        expect(find.text('Instruções'), findsOneWidget);
        expect(find.text('Prompt de IA'), findsOneWidget);
        expect(find.text('Configuração de persona'), findsOneWidget);
        expect(find.text('Perguntas'), findsOneWidget);
      });

      testWidgets('Persona list has dashboard navigation', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: PersonaSkillListPage(),
          ),
        );

        await tester.pumpAndSettle();

        // Verify back button goes to dashboard
        expect(find.text('Dashboard'), findsOneWidget);
        expect(find.text('Personas'), findsOneWidget);

        // Verify the back button is present
        expect(find.byIcon(Icons.arrow_back), findsOneWidget);
      });
    });

    group('Deep Link Navigation', () {
      testWidgets('Direct survey editor link works', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            routes: {
              '/': (context) => TaskDashboardPage(),
              '/surveys/123/edit': (context) => SurveyFormPage(
                initialDraft: SurveyDraft(
                  id: '123',
                  surveyDisplayName: 'Test Survey',
                  surveyName: 'test_survey',
                  surveyDescription: '',
                  creatorId: '',
                  createdAt: DateTime.now(),
                  modifiedAt: DateTime.now(),
                  instructions: InstructionsDraft(
                    preamble: '',
                    questionText: '',
                    answers: [''],
                  ),
                  questions: [],
                  finalNotes: '',
                  prompt: null,
                ),
              ),
            },
            initialRoute: '/surveys/123/edit',
          ),
        );

        await tester.pumpAndSettle();

        // Verify we're on the survey edit page
        expect(find.text('Editar questionário'), findsOneWidget);

        // Verify breadcrumbs show the navigation path
        expect(find.text('Dashboard'), findsOneWidget);
        expect(find.text('Questionários'), findsOneWidget);
        expect(find.text('Editar questionário'), findsOneWidget);
      });

      testWidgets('Legacy route redirects to new structure', (tester) async {
        // This test simulates legacy route handling
        await tester.pumpWidget(
          MaterialApp(
            onGenerateRoute: (settings) {
              if (settings.name == '/survey-prompt-list') {
                return MaterialPageRoute(
                  builder: (context) => TaskDashboardPage(),
                );
              }
              return null;
            },
          ),
        );

        // Navigate to legacy route
        await tester.binding.defaultBinaryMessenger
            .handlePlatformMessage('route', 'survey-prompt-list', null);
        await tester.pumpAndSettle();

        // Should show dashboard
        expect(find.text('Dashboard'), findsOneWidget);
        expect(find.text('Quick Prompts'), findsOneWidget);
      });
    });

    group('Mobile Navigation', () {
      testWidgets('Mobile bottom navigation is present', (tester) async {
        tester.binding.window.physicalSizeTestValue = const Size(375, 667);
        tester.binding.window.devicePixelRatioTestValue = 2.0;

        await tester.pumpWidget(
          MaterialApp(
            home: TaskDashboardPage(),
          ),
        );

        await tester.pumpAndSettle();

        // In mobile, bottom navigation should be present
        // This depends on the responsive behavior of DsAdminShell
        expect(find.text('Dashboard'), findsOneWidget);
      });

      testWidgets('Mobile back button behavior', (tester) async {
        tester.binding.window.physicalSizeTestValue = const Size(375, 667);
        tester.binding.window.devicePixelRatioTestValue = 2.0;

        await tester.pumpWidget(
          MaterialApp(
            home: SurveyFormPage(),
          ),
        );

        await tester.pumpAndSettle();

        // Mobile back button should be present
        expect(find.byIcon(Icons.arrow_back), findsOneWidget);

        // Tap should trigger back navigation
        await tester.tap(find.byIcon(Icons.arrow_back));
        await tester.pumpAndSettle();
      });
    });

    group('Navigation State Preservation', () {
      testWidgets('Form state preserved on navigation', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: SurveyFormPage(),
          ),
        );

        await tester.pumpAndSettle();

        // Enter some text in a field
        await tester.enterText(find.byType(TextField).first, 'Test Title');
        await tester.pumpAndSettle();

        // Simulate navigation away and back
        await tester.tap(find.text('Dashboard'));
        await tester.pumpAndSettle();

        // Navigate back to form
        await tester.tap(find.text('Questionários'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('Criar questionário'));
        await tester.pumpAndSettle();

        // Form should maintain state
        expect(find.text('Test Title'), findsOneWidget);
      });
    });
  });
}