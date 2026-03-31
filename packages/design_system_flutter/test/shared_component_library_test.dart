import 'package:design_system_flutter/theme/app_theme.dart';
import 'package:design_system_flutter/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Widget _wrap(Widget child) {
  return MaterialApp(
    theme: AppTheme.light(),
    home: Scaffold(body: child),
  );
}

void main() {
  testWidgets(
      'DsSurveyInstructionGate blocks continue until the correct answer is selected',
      (
    WidgetTester tester,
  ) async {
    var continueCount = 0;

    await tester.pumpWidget(
      _wrap(
        DsSurveyInstructionGate(
          instructions: const DsSurveyInstructionData(
            preambleHtml: '<p>Leia com atenção.</p>',
            questionText: 'Qual resposta libera o fluxo?',
            answers: <String>['Errada', 'Correta'],
            correctAnswer: 'Correta',
          ),
          onContinue: () {
            continueCount += 1;
          },
        ),
      ),
    );

    await tester.tap(find.text('Iniciar Questionário'));
    await tester.pumpAndSettle();

    expect(
      find.text('Por favor, selecione a resposta correta para continuar.'),
      findsOneWidget,
    );
    expect(continueCount, 0);

    await tester.tap(find.text('Correta'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Iniciar Questionário'));
    await tester.pumpAndSettle();

    expect(continueCount, 1);
  });

  testWidgets('DsPatientIdentitySection renders the requested patient fields', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      _wrap(
        DsPatientIdentitySection(
          nameController: TextEditingController(),
          medicalRecordIdController: TextEditingController(),
          showMedicalRecordId: true,
        ),
      ),
    );

    expect(find.text('Nome Completo *'), findsOneWidget);
    expect(find.text('Número do prontuário *'), findsOneWidget);
    expect(find.text('E-mail *'), findsNothing);
  });

  testWidgets('DsAdminCatalogShell renders empty and create states', (
    WidgetTester tester,
  ) async {
    var createTapCount = 0;

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light(),
        home: Scaffold(
          body: DsAdminCatalogShell<String>(
            heading: 'Catálogo',
            createLabel: 'Criar item',
            isLoading: false,
            items: const <String>[],
            emptyMessage: 'Nada cadastrado.',
            onCreate: () {
              createTapCount += 1;
            },
            onRefresh: () {},
            itemBuilder: (BuildContext context, String item) => Text(item),
          ),
        ),
      ),
    );

    expect(find.text('Nada cadastrado.'), findsOneWidget);

    await tester.tap(find.text('Criar item'));
    await tester.pumpAndSettle();

    expect(createTapCount, 1);
  });

  testWidgets('DsProfessionalSignInCard renders auth actions', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      _wrap(
        DsProfessionalSignInCard(
          onSubmit: (_) async => const DsAuthOperationResult.error('Falhou'),
          onForgotPassword: (_) async => const DsAuthOperationResult.success(
            'Senha enviada.',
          ),
          onShowSignUp: () {},
        ),
      ),
    );

    expect(find.text('Entrar'), findsWidgets);
    expect(find.text('Esqueceu a senha?'), findsOneWidget);
    expect(find.text('Não tem uma conta? Registre-se'), findsOneWidget);
  });

  testWidgets('DsAccountMenuButton shows configured actions', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      _wrap(
        DsAccountMenuButton<String>(
          items: const [
            DsAccountMenuItem(
              value: 'login',
              label: 'Entrar',
              icon: Icons.login,
            ),
            DsAccountMenuItem(
              value: 'register',
              label: 'Criar conta',
              icon: Icons.person_add_alt_1,
            ),
          ],
          onSelected: (_) {},
        ),
      ),
    );

    await tester.tap(find.byType(IconButton).first);
    await tester.pumpAndSettle();

    expect(find.text('Entrar'), findsOneWidget);
    expect(find.text('Criar conta'), findsOneWidget);
  });
}
