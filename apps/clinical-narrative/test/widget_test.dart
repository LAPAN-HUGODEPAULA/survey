import 'package:design_system_flutter/theme/app_theme.dart';
import 'package:design_system_flutter/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('Clinical narrative auth shell renders shared status bar', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light(),
        home: DsScaffold(
          appBar: AppBar(title: const Text('Login do Profissional')),
          body: DsProfessionalSignInCard(
            subtitle:
                'Entre com sua conta profissional cadastrada para iniciar sessões e registrar narrativas clínicas.',
            onSubmit: (_) async => const DsAuthOperationResult.success(),
            onShowSignUp: () {},
          ),
        ),
      ),
    );

    expect(find.text('Login do Profissional'), findsOneWidget);
    expect(find.byType(DsScaffold), findsOneWidget);
    expect(find.text(dsSharedStatusBarText), findsOneWidget);
    expect(find.text('Não tem uma conta? Registre-se'), findsOneWidget);
  });
}
