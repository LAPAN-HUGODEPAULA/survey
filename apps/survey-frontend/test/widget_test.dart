/// Testes de widgets para a aplicação de questionários.
///
/// Contém testes básicos para verificar o funcionamento correto
/// dos widgets principais da aplicação.
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:survey_app/main.dart';

/// Testes principais da aplicação de questionários.
///
/// Verifica o funcionamento básico da aplicação, incluindo
/// inicialização correta e comportamento esperado dos widgets.
void main() {
  /// Teste básico de funcionamento da aplicação.
  ///
  /// Verifica se a aplicação inicializa corretamente e se os
  /// widgets principais são renderizados sem erros.
  ///
  /// **Nota**: Este teste precisa ser atualizado para refletir
  /// a funcionalidade real da aplicação de questionários, pois
  /// atualmente testa um contador que não existe na aplicação.
  testWidgets('Splash screen renders expected texts', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());

    expect(
      find.text('Laboratório de Pesquisa Aplicada a Neurovisão'),
      findsOneWidget,
    );
    expect(find.text('Prof. Hugo de Paula, Ph. D.'), findsOneWidget);
  });
}
