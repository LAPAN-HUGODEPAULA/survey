import 'package:design_system_flutter/components/admin/ds_admin_shell.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('DsAdminShell responsive layout', () {
    testWidgets('desktop layout renders the sidebar navigation', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(1440, 1024);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DsAdminShell(
              navigation: _navigation,
              currentSection: 'dashboard',
              onNavigateToSection: (_) {},
              child: const SizedBox.expand(),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Survey Builder'), findsOneWidget);
      expect(find.text('Dashboard'), findsAtLeastNWidgets(1));
      expect(find.text('Questionários'), findsOneWidget);
      expect(find.text('Prompts'), findsOneWidget);
    });

    testWidgets('mobile layout renders a back action for secondary sections', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DsAdminShell(
              navigation: _navigation,
              currentSection: 'prompts',
              onNavigateToSection: (_) {},
              child: const SizedBox.expand(),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byTooltip('Voltar ao dashboard'), findsOneWidget);
      expect(find.text('Prompts'), findsWidgets);
    });
  });
}

const _navigation = [
  NavigationItem(
    key: 'dashboard',
    label: 'Dashboard',
    icon: Icons.space_dashboard_outlined,
  ),
  NavigationItem(
    key: 'surveys',
    label: 'Questionários',
    icon: Icons.assignment_outlined,
  ),
  NavigationItem(
    key: 'prompts',
    label: 'Prompts',
    icon: Icons.text_fields_outlined,
  ),
];
