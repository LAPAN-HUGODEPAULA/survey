/// Testes de widgets para a aplicação de questionários.
///
/// Contém testes básicos para verificar o funcionamento correto
/// dos widgets principais da aplicação.
library;

import 'package:design_system_flutter/theme/app_theme.dart';
import 'package:design_system_flutter/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:survey_app/core/providers/api_provider.dart';
import 'package:survey_app/core/providers/app_settings.dart';
import 'package:survey_app/features/screener/pages/screener_login_page.dart';

/// Testes principais da aplicação de questionários.
///
/// Verifica o funcionamento básico da aplicação, incluindo
/// inicialização correta e comportamento esperado dos widgets.
void main() {
  testWidgets('unauthenticated app boots into the screener login flow', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => AppSettings()),
          ChangeNotifierProvider(create: (_) => ApiProvider()),
        ],
        child: MaterialApp(
          theme: AppTheme.light(),
          home: const ScreenerLoginPage(),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('Login do Avaliador'), findsOneWidget);
    expect(find.text('Não tem uma conta? Registre-se'), findsOneWidget);
    expect(find.byType(DsScaffold), findsOneWidget);
    expect(find.text(dsSharedStatusBarText), findsOneWidget);
  });
}
