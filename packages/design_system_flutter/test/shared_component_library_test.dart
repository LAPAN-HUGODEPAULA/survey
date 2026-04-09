import 'dart:math';

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

double _relativeLuminance(Color color) {
  double transform(double channel) {
    final value = channel;
    if (value <= 0.03928) {
      return value / 12.92;
    }
    return pow((value + 0.055) / 1.055, 2.4).toDouble();
  }

  return 0.2126 * transform(color.r) +
      0.7152 * transform(color.g) +
      0.0722 * transform(color.b);
}

double _contrastRatio(Color first, Color second) {
  final luminanceA = _relativeLuminance(first);
  final luminanceB = _relativeLuminance(second);
  final lighter = max(luminanceA, luminanceB);
  final darker = min(luminanceA, luminanceB);
  return (lighter + 0.05) / (darker + 0.05);
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
    var backPressed = 0;

    await tester.pumpWidget(
      _wrap(
        DsPageHeader(
          eyebrow: 'Paciente',
          title: 'Tela principal',
          subtitle: 'Cabecalho compartilhado.',
          breadcrumbs: const [
            DsBreadcrumbItem(label: 'Início'),
            DsBreadcrumbItem(label: 'Tela principal', isCurrent: true),
          ],
          onBack: () {
            backPressed += 1;
          },
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
    expect(find.text('Tela principal'), findsWidgets);
    expect(find.text('Início'), findsOneWidget);

    await tester.tap(find.text('Voltar'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Acao'));
    await tester.pumpAndSettle();

    expect(backPressed, 1);
    expect(pressed, 1);
  });

  testWidgets('DsStepper renders progress text and step labels', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      _wrap(
        const SizedBox(
          width: 900,
          child: DsStepper(
            steps: [
              DsStepData(label: 'Aviso', state: DsStepState.done),
              DsStepData(label: 'Instruções', state: DsStepState.active),
              DsStepData(label: 'Questionário', state: DsStepState.todo),
            ],
          ),
        ),
      ),
    );

    expect(find.text('Passo 2 de 3'), findsOneWidget);
    expect(find.text('Aviso'), findsOneWidget);
    expect(find.text('Instruções'), findsWidgets);
    expect(find.text('Questionário'), findsOneWidget);
  });

  testWidgets('DsBreadcrumbs supports clickable parent items', (
    WidgetTester tester,
  ) async {
    var tapped = 0;

    await tester.pumpWidget(
      _wrap(
        DsBreadcrumbs(
          items: [
            DsBreadcrumbItem(
              label: 'Questionários',
              onPressed: () {
                tapped += 1;
              },
            ),
            const DsBreadcrumbItem(label: 'Editar', isCurrent: true),
          ],
        ),
      ),
    );

    await tester.tap(find.text('Questionários'));
    await tester.pumpAndSettle();

    expect(tapped, 1);
    expect(find.text('Editar'), findsOneWidget);
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

  testWidgets('DsValidatedTextFormField validates after blur', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      _wrap(
        const Form(
          child: Column(
            children: [
              DsValidatedTextFormField(
                decoration: InputDecoration(labelText: 'Campo'),
                validator: DsFormValidators.validateRequired,
              ),
              DsValidatedTextFormField(
                decoration: InputDecoration(labelText: 'Outro campo'),
              ),
            ],
          ),
        ),
      ),
    );

    expect(find.text('Campo'), findsOneWidget);
    expect(find.text('Campo obrigatório.'), findsNothing);

    await tester.tap(find.widgetWithText(TextField, 'Campo'));
    await tester.pump();
    await tester.tap(find.widgetWithText(TextField, 'Outro campo'));
    await tester.pumpAndSettle();

    expect(find.text('Campo obrigatório'), findsOneWidget);
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

  testWidgets('DsMessageBanner renders severity title, icon, and semantics', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      _wrap(
        const DsMessageBanner(
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

  testWidgets('DsMessageBanner renders retry button from onRetry callback', (
    WidgetTester tester,
  ) async {
    var retryTapCount = 0;
    await tester.pumpWidget(
      _wrap(
        DsMessageBanner(
          feedback: DsFeedbackMessage(
            severity: DsStatusType.error,
            title: 'Falha na conexão',
            message: 'Não foi possível carregar os dados.',
            onRetry: () {
              retryTapCount += 1;
            },
          ),
          margin: EdgeInsets.zero,
        ),
      ),
    );

    expect(find.text('Tentar Novamente'), findsOneWidget);
    await tester.tap(find.text('Tentar Novamente'));
    await tester.pumpAndSettle();
    expect(retryTapCount, 1);
  });

  testWidgets('DsEmptyState renders title, description and primary action', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      _wrap(
        DsEmptyState(
          title: 'Nenhum questionário encontrado.',
          description:
              'Nenhum questionário encontrado. Crie o primeiro questionário para começar.',
          actionLabel: 'Novo Questionário',
          onAction: () {},
        ),
      ),
    );

    expect(find.text('Nenhum questionário encontrado.'), findsOneWidget);
    expect(
      find.text(
        'Nenhum questionário encontrado. Crie o primeiro questionário para começar.',
      ),
      findsOneWidget,
    );
    expect(find.text('Novo Questionário'), findsOneWidget);
  });

  test('DsErrorMapper maps timeout and server status to friendly pt-BR', () {
    expect(
      DsErrorMapper.toUserMessage('ConnectionTimeout while loading data'),
      'A conexão demorou mais que o esperado. Verifique sua internet e tente novamente.',
    );
    expect(
      DsErrorMapper.toUserMessage(
          'DioException [bad response]: status code 500'),
      'Não foi possível completar esta ação agora. Nossos sistemas estão temporariamente indisponíveis. Tente novamente em alguns instantes.',
    );
  });

  testWidgets('showDsToast renders toast content in a live region', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      _wrap(
        Builder(
          builder: (BuildContext context) {
            return DsFilledButton(
              label: 'Mostrar toast',
              onPressed: () {
                showDsToast(
                  context,
                  feedback: const DsFeedbackMessage(
                    severity: DsStatusType.success,
                    title: 'Alterações salvas',
                    message: 'As configurações foram atualizadas.',
                  ),
                );
              },
            );
          },
        ),
      ),
    );

    await tester.tap(find.text('Mostrar toast'));
    await tester.pumpAndSettle();

    expect(find.text('Alterações salvas'), findsOneWidget);
    expect(find.text('As configurações foram atualizadas.'), findsOneWidget);
    final semanticsWidgets = tester
        .widgetList<Semantics>(find.byType(Semantics))
        .toList(growable: false);
    expect(
      semanticsWidgets.any((widget) => widget.properties.liveRegion == true),
      isTrue,
    );
  });

  testWidgets('feedback severity palette respects WCAG contrast target', (
    WidgetTester tester,
  ) async {
    late BuildContext context;
    await tester.pumpWidget(
      _wrap(
        Builder(
          builder: (BuildContext builderContext) {
            context = builderContext;
            return const SizedBox.shrink();
          },
        ),
      ),
    );

    for (final severity in DsStatusType.values) {
      final ratio = _contrastRatio(
        dsFeedbackBackgroundColor(context, severity),
        dsFeedbackForegroundColor(context, severity),
      );
      expect(
        ratio,
        greaterThanOrEqualTo(4.5),
        reason: 'Contrast ratio for $severity is below 4.5:1',
      );
    }
  });

  testWidgets(
      'DsAIProgressIndicator renders pt-BR stage microcopy and retry action', (
    WidgetTester tester,
  ) async {
    var retryTapCount = 0;
    await tester.pumpWidget(
      _wrap(
        DsAIProgressIndicator(
          stage: 'analyzing_signals',
          severity: 'warning',
          retryable: true,
          onRetry: () {
            retryTapCount += 1;
          },
        ),
      ),
    );

    expect(find.text('Analisando sinais clínicos'), findsOneWidget);
    expect(
      find.text(
        'Estamos analisando os sinais principais para uma leitura clínica consistente.',
      ),
      findsOneWidget,
    );
    expect(find.text('Tentar Novamente'), findsOneWidget);

    await tester.tap(find.text('Tentar Novamente'));
    await tester.pumpAndSettle();
    expect(retryTapCount, 1);
  });

  testWidgets(
      'DsAIProgressIndicator renders critical failure guidance and retry action',
      (WidgetTester tester) async {
    var retryTapCount = 0;
    await tester.pumpWidget(
      _wrap(
        DsAIProgressIndicator(
          stage: 'reviewing_content',
          severity: 'critical',
          retryable: true,
          onRetry: () {
            retryTapCount += 1;
          },
        ),
      ),
    );

    expect(
      find.text('Não foi possível concluir a geração automática agora'),
      findsOneWidget,
    );
    expect(
      find.text(
        'Você pode continuar sem o resultado automático e revisar as respostas originais.',
      ),
      findsOneWidget,
    );
    expect(find.text('Tentar Novamente'), findsOneWidget);

    await tester.tap(find.text('Tentar Novamente'));
    await tester.pumpAndSettle();
    expect(retryTapCount, 1);
  });

  testWidgets('DsAssistantStatus renders mapped steps and control actions', (
    WidgetTester tester,
  ) async {
    var retryTapCount = 0;
    var cancelTapCount = 0;

    await tester.pumpWidget(
      _wrap(
        DsAssistantStatus(
          currentPhaseLabel: 'Avaliação Clínica',
          currentMessage: 'Analisando sinais clínicos',
          steps: const [
            DsStepData(label: 'Anamnese', state: DsStepState.done),
            DsStepData(label: 'Avaliação Clínica', state: DsStepState.active),
            DsStepData(label: 'Planejamento', state: DsStepState.todo),
            DsStepData(label: 'Encerramento', state: DsStepState.todo),
          ],
          processing: true,
          initiallyExpanded: true,
          retryAction: DsFeedbackAction(
            label: 'Tentar Novamente',
            onPressed: () {
              retryTapCount += 1;
            },
            icon: Icons.refresh_rounded,
          ),
          cancelAction: DsFeedbackAction(
            label: 'Cancelar',
            onPressed: () {
              cancelTapCount += 1;
            },
            icon: Icons.close_rounded,
          ),
        ),
      ),
    );

    expect(find.text('Status do Assistente'), findsOneWidget);
    expect(find.text('Avaliação Clínica'), findsAtLeastNWidgets(1));
    expect(find.text('Anamnese'), findsOneWidget);
    expect(find.text('Planejamento'), findsOneWidget);
    expect(find.text('Encerramento'), findsOneWidget);

    await tester.tap(find.text('Tentar Novamente'));
    await tester.pumpAndSettle();
    expect(retryTapCount, 1);

    await tester.tap(find.text('Cancelar'));
    await tester.pumpAndSettle();
    expect(cancelTapCount, 1);
  });

  testWidgets('DsAssistantStatus exposes live-region semantics', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      _wrap(
        const DsAssistantStatus(
          currentPhaseLabel: 'Anamnese',
          currentMessage: 'Organizando a anamnese',
          processing: true,
          liveRegion: true,
          initiallyExpanded: true,
        ),
      ),
    );

    final semanticsWidgets = tester
        .widgetList<Semantics>(find.byType(Semantics))
        .toList(growable: false);
    expect(
      semanticsWidgets.any((widget) => widget.properties.liveRegion == true),
      isTrue,
    );
  });

  testWidgets('DsAIInsightCard maps semantic types to expected titles', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      _wrap(
        Column(
          children: const [
            DsAIInsightCard(
              type: DsAIInsightType.suggestion,
              message: 'Considere investigar fatores desencadeantes.',
            ),
            DsAIInsightCard(
              type: DsAIInsightType.alert,
              message: 'Sinal de risco identificado.',
            ),
            DsAIInsightCard(
              type: DsAIInsightType.hypothesis,
              message: 'Possível diagnóstico diferencial.',
            ),
          ],
        ),
      ),
    );

    expect(find.text('Sugestão do Assistente'), findsOneWidget);
    expect(find.text('Alerta Clínico'), findsOneWidget);
    expect(find.text('Hipótese Clínica'), findsOneWidget);
    expect(find.byIcon(Icons.lightbulb_outline), findsOneWidget);
    expect(find.byIcon(Icons.warning_amber_rounded), findsOneWidget);
    expect(find.byIcon(Icons.psychology_alt_outlined), findsOneWidget);
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

  testWidgets('DsValidationSummary renders labeled tappable items', (
    WidgetTester tester,
  ) async {
    var tapped = 0;

    await tester.pumpWidget(
      _wrap(
        DsValidationSummary(
          items: <DsValidationSummaryItem>[
            DsValidationSummaryItem(
              label: 'E-mail',
              message: 'Informe um e-mail válido.',
              onTap: () {
                tapped += 1;
              },
            ),
          ],
        ),
      ),
    );

    expect(find.text('E-mail: Informe um e-mail válido.'), findsOneWidget);

    await tester.tap(find.text('E-mail: Informe um e-mail válido.'));
    await tester.pumpAndSettle();

    expect(tapped, 1);
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

  test('DsToneTokens keeps pt-BR greeting fallback and named greeting', () {
    expect(
      DsToneTokens.patient.greetingFor(null),
      'Olá! Estamos com você em cada etapa.',
    );
    expect(
      DsToneTokens.professional.greetingFor('Dra. Helena'),
      'Olá, Dra. Helena. Seguimos com clareza para a próxima etapa clínica.',
    );
  });

  testWidgets(
    'DsScaffold ambient greeting personalizes header without extra action steps',
    (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.dark(),
          home: DsEmotionalToneProvider(
            profile: DsToneProfile.patient,
            child: DsScaffold(
              title: 'Painel',
              showAmbientGreeting: true,
              userName: 'Ana',
              body: Center(
                child: DsFilledButton(
                  label: 'Continuar',
                  onPressed: () {},
                ),
              ),
            ),
          ),
        ),
      );

      expect(find.textContaining('Olá, Ana.'), findsOneWidget);
      expect(find.byType(DsFilledButton), findsOneWidget);
      expect(find.text('Continuar'), findsOneWidget);
    },
  );

  testWidgets('DsFeedback applies greeting fallback in pt-BR microcopy', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.dark(),
        home: DsEmotionalToneProvider(
          profile: DsToneProfile.professional,
          child: Scaffold(
            body: DsInlineMessage(
              feedback: const DsFeedbackMessage(
                severity: DsStatusType.info,
                title: 'Status',
                message: 'Estamos consolidando os dados.',
                includeGreeting: true,
              ),
            ),
          ),
        ),
      ),
    );

    expect(find.textContaining('Olá. Seguimos com clareza'), findsOneWidget);
  });

  testWidgets(
    'DsAmbientDelight uses primitive animation widgets and resolves within frame budgets',
    (WidgetTester tester) async {
      late Duration patientDuration;
      late Duration adminDuration;

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.dark(),
          home: Column(
            children: [
              DsEmotionalToneProvider(
                profile: DsToneProfile.patient,
                child: Builder(
                  builder: (context) {
                    patientDuration =
                        DsEmotionalToneProvider.resolveMotionDuration(
                      context,
                      base: const Duration(milliseconds: 260),
                    );
                    return const DsAmbientDelight(
                      child: Text('Paciente'),
                    );
                  },
                ),
              ),
              DsEmotionalToneProvider(
                profile: DsToneProfile.admin,
                child: Builder(
                  builder: (context) {
                    adminDuration =
                        DsEmotionalToneProvider.resolveMotionDuration(
                      context,
                      base: const Duration(milliseconds: 260),
                    );
                    return const DsAmbientDelight(
                      child: Text('Admin'),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      );

      await tester.pump(const Duration(milliseconds: 350));

      expect(find.byType(AnimatedContainer), findsWidgets);
      expect(find.byType(Opacity), findsWidgets);
      expect(find.byType(Transform), findsWidgets);

      final patientFrames60 = patientDuration.inMicroseconds / 16667;
      final patientFrames90 = patientDuration.inMicroseconds / 11111;
      final adminFrames60 = adminDuration.inMicroseconds / 16667;
      final adminFrames90 = adminDuration.inMicroseconds / 11111;

      expect(patientFrames60, lessThanOrEqualTo(22));
      expect(patientFrames90, lessThanOrEqualTo(33));
      expect(adminFrames60, lessThanOrEqualTo(22));
      expect(adminFrames90, lessThanOrEqualTo(33));
    },
  );

  testWidgets(
      'DsAIProgressIndicator humanizes wait labels with supportive tone', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.dark(),
        home: DsEmotionalToneProvider(
          profile: DsToneProfile.patient,
          child: const Scaffold(
            body: DsAIProgressIndicator(
              stage: 'analyzing_signals',
              userName: 'Marina',
            ),
          ),
        ),
      ),
    );

    expect(find.text('Analisando sinais'), findsWidgets);
    expect(find.textContaining('Olá, Marina.'), findsOneWidget);
    expect(find.textContaining('leitura inicial cuidadosa'), findsOneWidget);
  });
}
