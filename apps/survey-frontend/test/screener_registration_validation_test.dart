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

Finder _fieldByLabel(String label) {
  return find.byWidgetPredicate(
    (widget) =>
        widget is TextFormField && widget.decoration?.labelText == label,
  );
}

void main() {
  testWidgets('CPF invalid message clears when typing again', (tester) async {
    await tester.pumpWidget(_wrapWithProviders(const ScreenerRegistrationPage()));

    final cpfField = _fieldByLabel('CPF');
    final firstNameField = _fieldByLabel('Primeiro Nome');

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

    final phoneField = _fieldByLabel('Telefone');
    await tester.enterText(phoneField, '31a984b31284');
    await tester.pump();

    final phoneWidget = tester.widget<TextFormField>(phoneField);
    expect(phoneWidget.controller?.text, '(31) 98483-1284');
  });

  testWidgets('CEP validates for 8 digits on blur', (tester) async {
    await tester.pumpWidget(_wrapWithProviders(const ScreenerRegistrationPage()));

    final cepField = _fieldByLabel('CEP');
    final streetField = _fieldByLabel('Rua');

    await tester.enterText(cepField, '123');
    await tester.tap(streetField);
    await tester.pumpAndSettle();

    expect(find.text('CEP deve ter 8 dígitos.'), findsOneWidget);
  });

  testWidgets('Conselho registration number accepts only digits', (tester) async {
    await tester.pumpWidget(_wrapWithProviders(const ScreenerRegistrationPage()));

    final councilNumberField = _fieldByLabel('Número de Registro no Conselho');
    await tester.enterText(councilNumberField, 'ab12cd');
    await tester.pump();

    final fieldWidget = tester.widget<TextFormField>(councilNumberField);
    expect(fieldWidget.controller?.text, '12');
  });
}
