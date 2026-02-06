/// Widget tests for screener registration field validation.
library;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:survey_app/core/providers/api_provider.dart';
import 'package:survey_app/core/providers/app_settings.dart';
import 'package:survey_app/features/screener/pages/screener_registration_page.dart';

Widget _wrapWithProviders(Widget child) {
  return MultiProvider(
    providers: [
      ChangeNotifierProvider(create: (_) => AppSettings()),
      ChangeNotifierProvider(create: (_) => ApiProvider()),
    ],
    child: MaterialApp(home: child),
  );
}

Finder _editableTextByKey(String key) {
  return find.descendant(
    of: find.byKey(ValueKey(key)),
    matching: find.byType(EditableText),
  );
}

Future<void> _enterTextByKey(
  WidgetTester tester,
  String key,
  String text,
) async {
  final field = _editableTextByKey(key);
  await tester.ensureVisible(field);
  await tester.tap(field);
  await tester.enterText(field, text);
  await tester.pumpAndSettle();
}

Future<void> _fillRequiredFields(WidgetTester tester) async {
  await _enterTextByKey(tester, 'screener-registration-cpf', '52998224725');
  await _enterTextByKey(
    tester,
    'screener-registration-first-name',
    'Ana',
  );
  await _enterTextByKey(tester, 'screener-registration-surname', 'Silva');
  await _enterTextByKey(
    tester,
    'screener-registration-email',
    'ana@example.com',
  );
  await _enterTextByKey(
    tester,
    'screener-registration-password',
    'StrongPassword123',
  );
  await _enterTextByKey(
    tester,
    'screener-registration-phone',
    '31988447613',
  );
  await _enterTextByKey(
    tester,
    'screener-registration-postal-code',
    '30140071',
  );
  await _enterTextByKey(tester, 'screener-registration-street', 'Rua Teste');
  await _enterTextByKey(tester, 'screener-registration-number', '123');
  await _enterTextByKey(tester, 'screener-registration-neighborhood', 'Centro');
  await _enterTextByKey(
    tester,
    'screener-registration-city',
    'Belo Horizonte',
  );
  await _enterTextByKey(
    tester,
    'screener-registration-job-title',
    'Psicologo',
  );
  await _enterTextByKey(
    tester,
    'screener-registration-degree',
    'Psicologia',
  );

  // State selection is optional for these tests to avoid dropdown flakiness.
}

void main() {
  testWidgets('CPF invalid message clears when typing again', (tester) async {
    await tester.pumpWidget(_wrapWithProviders(const ScreenerRegistrationPage()));

    final cpfField = _editableTextByKey('screener-registration-cpf');
    final firstNameField = _editableTextByKey('screener-registration-first-name');

    await tester.enterText(cpfField, '11111111111');
    await tester.tap(firstNameField);
    await tester.pumpAndSettle();

    expect(find.text('CPF inválido.'), findsOneWidget);

    await tester.tap(cpfField);
    await tester.pumpAndSettle();
    await tester.enterText(cpfField, '123');
    await tester.pump();

    expect(find.text('CPF inválido.'), findsNothing);
  });

  testWidgets('Telefone input is masked and digits only', (tester) async {
    await tester.pumpWidget(_wrapWithProviders(const ScreenerRegistrationPage()));

    final phoneField = _editableTextByKey('screener-registration-phone');
    await tester.enterText(phoneField, '31a9848b31284');
    await tester.pump();

    final phoneWidget = tester.widget<EditableText>(phoneField);
    expect(phoneWidget.controller.text, '(31) 98483-1284');
  });

  testWidgets('CEP validates for 8 digits on blur', (tester) async {
    await tester.pumpWidget(_wrapWithProviders(const ScreenerRegistrationPage()));

    final cepField = _editableTextByKey('screener-registration-postal-code');
    final streetField = _editableTextByKey('screener-registration-street');

    await tester.enterText(cepField, '123');
    await tester.ensureVisible(streetField);
    await tester.tap(streetField);
    await tester.pumpAndSettle();

    expect(find.text('CEP deve ter 8 dígitos.'), findsOneWidget);
  });

  testWidgets('Conselho registration number accepts only digits', (tester) async {
    await tester.pumpWidget(_wrapWithProviders(const ScreenerRegistrationPage()));

    final councilNumberField =
        _editableTextByKey('screener-registration-council-registration');
    await tester.enterText(councilNumberField, 'ab12cd');
    await tester.pump();

    final fieldWidget = tester.widget<EditableText>(councilNumberField);
    expect(fieldWidget.controller.text, '12');
  });

  testWidgets('Conselho type required when registration is filled', (tester) async {
    await tester.pumpWidget(_wrapWithProviders(const ScreenerRegistrationPage()));

    await _fillRequiredFields(tester);
    await _enterTextByKey(
      tester,
      'screener-registration-council-registration',
      '1234',
    );

    await tester.tap(find.text('Registrar'));
    await tester.pumpAndSettle();

    expect(find.text('Informe o tipo de conselho.'), findsOneWidget);
  });

  testWidgets('Conselho registration required when type is filled', (tester) async {
    await tester.pumpWidget(_wrapWithProviders(const ScreenerRegistrationPage()));

    await _fillRequiredFields(tester);
    await _enterTextByKey(
      tester,
      'screener-registration-council-type',
      'CRM',
    );

    await tester.tap(find.text('Registrar'));
    await tester.pumpAndSettle();

    expect(find.text('Informe o número de registro.'), findsOneWidget);
  });

  testWidgets('Conselho type validates allowed values', (tester) async {
    await tester.pumpWidget(_wrapWithProviders(const ScreenerRegistrationPage()));

    await _fillRequiredFields(tester);
    await _enterTextByKey(
      tester,
      'screener-registration-council-type',
      'ABC',
    );

    await tester.tap(find.text('Registrar'));
    await tester.pumpAndSettle();

    expect(find.text('Tipo de conselho inválido.'), findsOneWidget);
  });
}
