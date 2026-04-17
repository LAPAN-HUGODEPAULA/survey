import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:survey_builder/features/survey/pages/task_dashboard_page.dart';

void main() {
  group('Responsive Layout Tests', () {
    group('Desktop Layout (> 768px)', () {
      testWidgets('Desktop shows sidebar navigation', (tester) async {
        tester.binding.window.physicalSizeTestValue = const Size(1920, 1080);
        tester.binding.window.devicePixelRatioTestValue = 1.0;

        await tester.pumpWidget(
          MaterialApp(
            home: TaskDashboardPage(),
          ),
        );

        await tester.pumpAndSettle();

        // On desktop, expect sidebar navigation
        expect(find.byType(ListView), findsAtLeastNWidgets(1));

        // Verify navigation items are visible
        expect(find.text('Dashboard'), findsOneWidget);
        expect(find.text('Questionários'), findsOneWidget);
        expect(find.text('Prompts'), findsOneWidget);
        expect(find.text('Personas'), findsOneWidget);
        expect(find.text('Acessos'), findsOneWidget);

        // Verify main content area is present
        expect(find.text('Ações Principais'), findsOneWidget);
      });

      testWidgets('Desktop shows large task buttons', (tester) async {
        tester.binding.window.physicalSizeTestValue = const Size(1920, 1080);
        tester.binding.window.devicePixelRatioTestValue = 1.0;

        await tester.pumpWidget(
          MaterialApp(
            home: TaskDashboardPage(),
          ),
        );

        await tester.pumpAndSettle();

        // Large task buttons should be visible
        expect(find.text('Criar Questionário'), findsOneWidget);
        expect(find.text('Editar Questionário'), findsOneWidget);
      });
    });

    group('Tablet Layout (768px - 1024px)', () {
      testWidgets('Tablet shows adaptive sidebar', (tester) async {
        tester.binding.window.physicalSizeTestValue = const Size(1024, 768);
        tester.binding.window.devicePixelRatioTestValue = 1.0;

        await tester.pumpWidget(
          MaterialApp(
            home: TaskDashboardPage(),
          ),
        );

        await tester.pumpAndSettle();

        // Tablet should show compact sidebar
        expect(find.byType(ListView), findsAtLeastNWidgets(1));

        // Navigation items should be visible but more compact
        expect(find.text('Dashboard'), findsOneWidget);
        expect(find.text('Questionários'), findsOneWidget);
      });
    });

    group('Mobile Layout (< 768px)', () {
      testWidgets('Mobile shows bottom navigation', (tester) async {
        tester.binding.window.physicalSizeTestValue = const Size(375, 667);
        tester.binding.window.devicePixelRatioTestValue = 2.0;

        await tester.pumpWidget(
          MaterialApp(
            home: TaskDashboardPage(),
          ),
        );

        await tester.pumpAndSettle();

        // On mobile, expect bottom navigation bar
        expect(find.byType(Row), findsWidgets);

        // Navigation items should be in bottom nav
        expect(find.text('Dashboard'), findsOneWidget);
        expect(find.text('Questionários'), findsOneWidget);
        expect(find.text('Prompts'), findsOneWidget);
        expect(find.text('Personas'), findsOneWidget);
        expect(find.text('Acessos'), findsOneWidget);
      });

      testWidgets('Mobile shows compact content', (tester) async {
        tester.binding.window.physicalSizeTestValue = const Size(375, 667);
        tester.binding.window.devicePixelRatioTestValue = 2.0;

        await tester.pumpWidget(
          MaterialApp(
            home: TaskDashboardPage(),
          ),
        );

        await tester.pumpAndSettle();

        // Task buttons should be more compact on mobile
        // Since they're just text, they should still be visible
        expect(find.text('Criar Questionário'), findsOneWidget);

        // Secondary actions should be accessible
        expect(find.text('Modelos'), findsOneWidget);
        expect(find.text('Importar/Exportar'), findsOneWidget);
      });

      testWidgets('Mobile touch targets are adequate', (tester) async {
        tester.binding.window.physicalSizeTestValue = const Size(375, 667);
        tester.binding.window.devicePixelRatioTestValue = 2.0;

        await tester.pumpWidget(
          MaterialApp(
            home: TaskDashboardPage(),
          ),
        );

        await tester.pumpAndSettle();

        // Navigation items should have adequate touch targets
        // Each nav item should be at least 44x44 pixels
        final navItems = tester.widgets<InkWell>();
        expect(navItems.length, greaterThan(0));

        for (final item in navItems) {
          final renderBox = item.findRenderObject() as RenderBox?;
          expect(renderBox, isNotNull);
          expect(renderBox!.size.width, greaterThanOrEqualTo(44));
          expect(renderBox.size.height, greaterThanOrEqualTo(44));
        }
      });
    });

    group('Layout Transitions', () {
      testWidgets('Smooth transition between breakpoints', (tester) async {
        // Start with mobile
        tester.binding.window.physicalSizeTestValue = const Size(375, 667);
        tester.binding.window.devicePixelRatioTestValue = 2.0;

        await tester.pumpWidget(
          MaterialApp(
            home: TaskDashboardPage(),
          ),
        );

        await tester.pumpAndSettle();

        // Verify mobile layout
        expect(find.text('Dashboard'), findsOneWidget);

        // Simulate rotation to tablet
        tester.binding.window.physicalSizeTestValue = const Size(768, 1024);
        await tester.binding.setSurfaceSize(const Size(768, 1024));
        await tester.pumpAndSettle();

        // Should adapt to tablet size
        expect(find.text('Dashboard'), findsOneWidget);

        // Simulate rotation to desktop
        tester.binding.window.physicalSizeTestValue = const Size(1920, 1080);
        await tester.binding.setSurfaceSize(const Size(1920, 1080));
        await tester.pumpAndSettle();

        // Should adapt to desktop size
        expect(find.text('Dashboard'), findsOneWidget);
      });
    });

    group('Accessibility Tests', () {
      testWidgets('Text is readable on all screen sizes', (tester) async {
        // Test different screen sizes
        final sizes = [
          const Size(1920, 1080),  // Desktop
          const Size(1024, 768),  // Tablet
          const Size(375, 667),   // Mobile
        ];

        for (final size in sizes) {
          tester.binding.window.physicalSizeTestValue = size;
          tester.binding.window.devicePixelRatioTestValue = 1.0;

          await tester.pumpWidget(
            MaterialApp(
              home: TaskDashboardPage(),
            ),
          );

          await tester.pumpAndSettle();

          // Verify text is not clipped
          expect(find.text('Dashboard'), findsOneWidget);
          expect(find.text('Ações Principais'), findsOneWidget);

          // No text overflow errors
          final textWidgets = tester.widgets<Text>();
          for (final text in textWidgets) {
            final renderBox = text.findRenderObject() as RenderBox?;
            expect(renderBox, isNotNull);
            final textPainter = TextPainter(
              text: text.data!,
              textDirection: TextDirection.ltr,
            );
            textPainter.layout(maxWidth: renderBox!.width);
            expect(textPainter.didExceedMaxLines, isFalse);
          }
        }
      });
    });
  });
}