import 'package:clinical_narrative_app/features/clinician/pages/clinician_login_page.dart';
import 'package:design_system_flutter/theme/app_theme.dart';
import 'package:design_system_flutter/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('Clinician login page renders shared status bar', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light(),
        home: const ClinicianLoginPage(),
      ),
    );

    expect(find.text('Credenciais do Profissional'), findsOneWidget);
    expect(find.byType(DsScaffold), findsOneWidget);
    expect(find.text(dsSharedStatusBarText), findsOneWidget);
  });
}
