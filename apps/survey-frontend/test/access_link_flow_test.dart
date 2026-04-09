import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:survey_app/core/models/screener_access_link.dart';
import 'package:survey_app/core/models/screener_profile.dart';
import 'package:survey_app/core/models/survey/instructions.dart';
import 'package:survey_app/core/models/survey/question.dart';
import 'package:survey_app/core/models/survey/survey.dart';
import 'package:survey_app/core/providers/app_settings.dart';
import 'package:survey_app/core/repositories/screener_access_link_repository.dart';
import 'package:survey_app/core/repositories/survey_repository.dart';
import 'package:survey_app/features/access_links/pages/access_link_unavailable_page.dart';
import 'package:survey_app/features/settings/pages/settings_page.dart';
import 'package:survey_backend_api/survey_backend_api.dart' as api;

class _FakeSurveyRepository extends SurveyRepository {
  _FakeSurveyRepository(this.surveys)
    : super(
        apiClient: api.DefaultApi(Dio(), api.standardSerializers),
        rawClient: Dio(),
      );

  final List<Survey> surveys;

  @override
  Future<List<Survey>> fetchAll() async => surveys;
}

class _FakeScreenerAccessLinkRepository extends ScreenerAccessLinkRepository {
  _FakeScreenerAccessLinkRepository(this.link) : super(rawClient: Dio());

  final ScreenerAccessLink link;

  @override
  Future<ScreenerAccessLink> create({
    required String authToken,
    required String surveyId,
  }) async {
    return link;
  }
}

Survey _buildSurvey() {
  return Survey(
    id: 'survey-1',
    surveyDisplayName: 'CHYPS-Br',
    surveyName: 'chyps-br',
    surveyDescription: 'Questionário de teste',
    creatorId: 'creator-1',
    createdAt: DateTime(2026, 1, 1),
    modifiedAt: DateTime(2026, 1, 2),
    instructions: Instructions(
      preamble: '<p>Instruções</p>',
      questionText: 'Tudo certo?',
      answers: <String>['Não', 'Sim'],
    ),
    questions: <Question>[
      Question(id: 1, questionText: 'Pergunta 1', answers: <String>['A', 'B']),
    ],
    prompt: null,
  );
}

ScreenerProfile _buildScreenerProfile() {
  return ScreenerProfile(
    id: 'screener-1',
    cpf: '52998224725',
    firstName: 'Ana',
    surname: 'Silva',
    email: 'ana@example.com',
    phone: '31988447613',
    address: ScreenerAddress(
      postalCode: '30140071',
      street: 'Rua Teste',
      number: '123',
      complement: null,
      neighborhood: 'Centro',
      city: 'Belo Horizonte',
      state: 'MG',
    ),
    professionalCouncil: ScreenerProfessionalCouncil(
      type: 'CRP',
      registrationNumber: '1234',
    ),
    jobTitle: 'Psicóloga',
    degree: 'Psicologia',
    darvCourseYear: 2020,
    initialNoticeAcceptedAt: DateTime(2026, 1, 1),
  );
}

Widget _wrap(Widget child, AppSettings settings) {
  return MultiProvider(
    providers: <ChangeNotifierProvider<AppSettings>>[
      ChangeNotifierProvider<AppSettings>.value(value: settings),
    ],
    child: MaterialApp(home: child),
  );
}

void main() {
  testWidgets('settings page shows export actions after generating link', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(800, 1400));
    final settings = AppSettings(
      surveyRepository: _FakeSurveyRepository(<Survey>[_buildSurvey()]),
    );
    settings.setScreenerSession(
      token: 'token-auth',
      profile: _buildScreenerProfile(),
    );
    final repository = _FakeScreenerAccessLinkRepository(
      ScreenerAccessLink(
        token: 'token-123',
        screenerId: 'screener-1',
        screenerName: 'Ana Silva',
        surveyId: 'survey-1',
        surveyDisplayName: 'CHYPS-Br',
        createdAt: DateTime(2026, 3, 10),
      ),
    );

    await tester.pumpWidget(
      _wrap(SettingsPage(accessLinkRepository: repository), settings),
    );
    await tester.pumpAndSettle();

    final generateButton = find.text('Gerar link do questionário');
    await tester.dragUntilVisible(
      generateButton,
      find.byType(Scrollable),
      const Offset(0, -200),
    );
    await tester.tap(generateButton);
    await tester.pumpAndSettle();

    expect(find.text('Copiar link'), findsOneWidget);
    expect(find.text('Salvar texto'), findsOneWidget);
    expect(find.text('Salvar QR em PNG'), findsOneWidget);
    expect(find.textContaining('token-123'), findsOneWidget);
    addTearDown(() => tester.binding.setSurfaceSize(null));
  });

  testWidgets('settings page explains locked mode and hides generator', (
    tester,
  ) async {
    final settings = AppSettings(
      surveyRepository: _FakeSurveyRepository(<Survey>[_buildSurvey()]),
    );
    settings.applyPreparedAccessLink(
      ScreenerAccessLink(
        token: 'token-123',
        screenerId: 'screener-1',
        screenerName: 'Ana Silva',
        surveyId: 'survey-1',
        surveyDisplayName: 'CHYPS-Br',
        createdAt: DateTime(2026, 3, 10),
      ),
    );

    await tester.pumpWidget(_wrap(const SettingsPage(), settings));
    await tester.pumpAndSettle();

    expect(find.text('Sessão preparada'), findsOneWidget);
    expect(find.textContaining('Ana Silva'), findsWidgets);
    expect(find.text('Gerar link do questionário'), findsNothing);
  });

  testWidgets('unavailable page shows recovery guidance', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(home: AccessLinkUnavailablePage()),
    );

    expect(
      find.text('Este questionário preparado não está mais disponível.'),
      findsOneWidget,
    );
    expect(find.textContaining('lapan.hugodepaula@gmail.com'), findsOneWidget);
  });
}
