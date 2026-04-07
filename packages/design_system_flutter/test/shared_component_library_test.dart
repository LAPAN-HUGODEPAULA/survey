import 'package:design_system_flutter/theme/app_theme.dart';
import 'package:design_system_flutter/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Widget _wrap(Widget child) {
  return MaterialApp(
    theme: AppTheme.dark(),
    home: Scaffold(body: child),
  );
}

void main() {
  testWidgets('surface primitives render shared content and helper text', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      _wrap(
        DsSection(
          eyebrow: 'Clinico',
          title: 'Resumo',
          subtitle: 'Superficie tonal compartilhada.',
          child: const DsFieldChrome(
            label: 'Campo',
            supportingText: 'Ajuda compartilhada.',
            child: Text('Conteudo'),
          ),
        ),
      ),
    );

    expect(find.text('Clinico'), findsOneWidget);
    expect(find.text('Resumo'), findsOneWidget);
    expect(find.text('Ajuda compartilhada.'), findsOneWidget);
    expect(find.text('Conteudo'), findsOneWidget);
  });

  testWidgets('DsPageHeader renders eyebrow and shared actions', (
    WidgetTester tester,
  ) async {
    var pressed = 0;

    await tester.pumpWidget(
      _wrap(
        DsPageHeader(
          eyebrow: 'Paciente',
          title: 'Tela principal',
          subtitle: 'Cabecalho compartilhado.',
          actions: [
            DsFilledButton(
              label: 'Acao',
              onPressed: () {
                pressed += 1;
              },
            ),
          ],
        ),
      ),
    );

    expect(find.text('Paciente'), findsOneWidget);
    expect(find.text('Tela principal'), findsOneWidget);

    await tester.tap(find.text('Acao'));
    await tester.pumpAndSettle();

    expect(pressed, 1);
  });

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
        theme: AppTheme.dark(),
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

  testWidgets('DsProfessionalSignInCard starts obscured and toggles visibility',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      _wrap(
        DsProfessionalSignInCard(
          onSubmit: (_) async => const DsAuthOperationResult.success(),
        ),
      ),
    );

    final passwordFieldFinder = find.byWidgetPredicate(
      (widget) =>
          widget is TextField && widget.decoration?.labelText == 'Senha',
    );

    final initialField = tester.widget<TextField>(passwordFieldFinder);
    expect(initialField.obscureText, isTrue);
    expect(initialField.autofillHints, contains(AutofillHints.password));
    expect(find.byIcon(Icons.visibility_off_outlined), findsOneWidget);

    await tester.tap(find.byTooltip('Mostrar senha'));
    await tester.pumpAndSettle();

    final toggledField = tester.widget<TextField>(passwordFieldFinder);
    expect(toggledField.obscureText, isFalse);
    expect(find.byIcon(Icons.visibility_outlined), findsOneWidget);
  });

  testWidgets(
      'DsProfessionalSignInCard preserves the password cursor when toggling',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      _wrap(
        DsProfessionalSignInCard(
          onSubmit: (_) async => const DsAuthOperationResult.success(),
        ),
      ),
    );

    final passwordFieldFinder = find.byWidgetPredicate(
      (widget) =>
          widget is TextField && widget.decoration?.labelText == 'Senha',
    );
    final passwordField = tester.widget<TextField>(passwordFieldFinder);
    final controller = passwordField.controller!;

    controller
      ..text = 'segredo123'
      ..selection = const TextSelection.collapsed(offset: 4);
    await tester.pump();

    await tester.tap(find.byTooltip('Mostrar senha'));
    await tester.pump();
    await tester.pump();

    expect(controller.selection, const TextSelection.collapsed(offset: 4));
  });

  testWidgets(
      'DsProfessionalSignUpCard shows password guidance and supports autofill',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      _wrap(
        DsProfessionalSignUpCard(
          onSubmit: (_) async => const DsAuthOperationResult.success(),
        ),
      ),
    );

    expect(find.text('Use pelo menos 8 caracteres'), findsOneWidget);

    final passwordFieldFinder = find.descendant(
      of: find.byKey(const ValueKey('screener-registration-password')),
      matching: find.byType(TextField),
    );

    final initialField = tester.widget<TextField>(passwordFieldFinder);
    expect(initialField.obscureText, isTrue);
    expect(initialField.autofillHints, contains(AutofillHints.newPassword));

    await tester.tap(find.byTooltip('Mostrar senha'));
    await tester.pumpAndSettle();

    final toggledField = tester.widget<TextField>(passwordFieldFinder);
    expect(toggledField.obscureText, isFalse);
  });

  testWidgets('DsFeedbackBanner renders severity title, icon, and semantics', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      _wrap(
        const DsFeedbackBanner(
          feedback: DsFeedbackMessage(
            severity: DsStatusType.warning,
            title: 'Atenção',
            message: 'Revise os campos antes de continuar.',
          ),
          margin: EdgeInsets.zero,
        ),
      ),
    );

    expect(find.text('Atenção'), findsOneWidget);
    expect(find.text('Revise os campos antes de continuar.'), findsOneWidget);
    expect(find.byIcon(Icons.warning_amber_rounded), findsOneWidget);
    final semanticsWidgets = tester
        .widgetList<Semantics>(find.byType(Semantics))
        .toList(growable: false);
    expect(
      semanticsWidgets.any((widget) => widget.properties.liveRegion == true),
      isTrue,
    );
    expect(
      semanticsWidgets.any(
        (widget) =>
            widget.properties.label ==
            'Mensagem de alerta: Atenção. Revise os campos antes de continuar.',
      ),
      isTrue,
    );
  });

  testWidgets('DsValidationSummary renders each validation item', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      _wrap(
        const DsValidationSummary(
          errors: <String>[
            'Informe o e-mail.',
            'Selecione um questionário.',
          ],
        ),
      ),
    );

    expect(find.text('Revise os campos obrigatórios'), findsOneWidget);
    expect(find.text('Informe o e-mail.'), findsOneWidget);
    expect(find.text('Selecione um questionário.'), findsOneWidget);
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
