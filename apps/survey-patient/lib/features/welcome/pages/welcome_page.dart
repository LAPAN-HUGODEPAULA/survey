import 'package:design_system_flutter/widgets.dart';
import 'package:flutter/material.dart';
import 'package:patient_app/core/navigation/app_navigator.dart';
import 'package:patient_app/core/providers/app_settings.dart';
import 'package:patient_app/shared/widgets/patient_journey_stepper.dart';
import 'package:provider/provider.dart';

class WelcomePage extends StatefulWidget {
  const WelcomePage({super.key});

  @override
  State<WelcomePage> createState() => _WelcomePageState();
}

class _WelcomePageState extends State<WelcomePage> {
  bool _initialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_initialized) return;
    _initialized = true;

    final settings = Provider.of<AppSettings>(context, listen: false);
    settings
        .loadAvailableSurveys()
        .then((_) {
          if (!mounted) return;
          final surveys = settings.availableSurveys;
          if (surveys.isNotEmpty && settings.selectedSurveyId == null) {
            settings.selectSurvey(surveys.first.id);
          }
          setState(() {});
        })
        .catchError((_) {
          if (!mounted) return;
          setState(() {});
        });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AppSettings>(
      builder: (context, settings, _) {
        final survey = settings.selectedSurvey;
        final error = settings.surveyLoadError;
        final isLoading =
            settings.isLoadingSurveys && settings.availableSurveys.isEmpty;
        final tone = DsEmotionalToneProvider.resolveTokens(context);
        debugPrint(
          'WelcomePage.build: loading=$isLoading survey=${survey?.id} error=$error total=${settings.availableSurveys.length}',
        );

        return DsScaffold(
          title: 'Questionário de triagem de paciente',
          subtitle:
              'Bem vindo! Vamos iniciar a triagem. Reserve o tempo que precisar.',
          userName: settings.patient.name,
          showAmbientGreeting: false,
          scrollable: true,
          body: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const PatientJourneyStepper(
                currentStep: PatientJourneyStep.boasVindas,
              ),
              if (isLoading && survey == null) ...[
                DsSection(
                  eyebrow: 'Preparando jornada',
                  title: 'Carregando questionário',
                  subtitle:
                      'Estamos preparando a próxima etapa após o seu aceite.',
                  child: DsPanel(
                    tone: DsPanelTone.high,
                    child: Row(
                      children: [
                        const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(strokeWidth: 2.5),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Text(
                            'Buscando o questionário disponível. Se isso demorar, você poderá tentar novamente sem voltar ao aviso.',
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ] else if (error != null) ...[
                DsSection(
                  eyebrow: 'Conexao',
                  title: 'Nao foi possivel carregar o questionario',
                  subtitle:
                      'O aceite foi concluído, mas a aplicação não conseguiu buscar a próxima etapa.',
                  child: DsError(
                    message: 'Falha ao carregar questionário: $error',
                    onRetry: settings.loadAvailableSurveys,
                  ),
                ),
              ] else if (survey == null) ...[
                DsSection(
                  eyebrow: 'Conexao',
                  title: 'Nenhum questionário disponível',
                  subtitle:
                      'Verifique sua conexão com a internet e tente carregar novamente.',
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: DsFilledButton(
                      label: 'Tentar novamente',
                      icon: Icons.refresh,
                      onPressed: settings.loadAvailableSurveys,
                    ),
                  ),
                ),
              ] else ...[
                DsSection(
                  eyebrow: 'Questionario ativo',
                  title: survey.surveyDisplayName.isNotEmpty
                      ? survey.surveyDisplayName
                      : survey.surveyName,
                  subtitle: 'Revise o contexto antes de iniciar a triagem.',
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (survey.surveyDescription.isNotEmpty)
                        Text(
                          _plainText(survey.surveyDescription),
                          style: Theme.of(
                            context,
                          ).textTheme.bodyMedium?.copyWith(height: 1.5),
                        ),
                      DsPanel(
                        tone: DsPanelTone.high,
                        backgroundColor: Theme.of(
                          context,
                        ).colorScheme.primaryContainer,
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          children: [
                            Icon(
                              Icons.info_outline,
                              color: Theme.of(
                                context,
                              ).colorScheme.onPrimaryContainer,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                'Você responderá 7 perguntas rápidas. ${tone.waitingSupportMessage}',
                                style: Theme.of(context).textTheme.bodyMedium
                                    ?.copyWith(
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.onPrimaryContainer,
                                    ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: DsFilledButton(
                    label: 'Iniciar questionário',
                    icon: Icons.play_arrow,
                    size: DsButtonSize.large,
                    onPressed: () => AppNavigator.toInstructions(context),
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}

String _plainText(String html) {
  return html
      .replaceAll(RegExp(r'<br\s*/?>', caseSensitive: false), '\n')
      .replaceAll(RegExp(r'</p>', caseSensitive: false), '\n\n')
      .replaceAll(RegExp(r'<[^>]+>'), '')
      .replaceAll('&nbsp;', ' ')
      .replaceAll('&amp;', '&')
      .replaceAll('&quot;', '"')
      .replaceAll('&#39;', "'")
      .replaceAll('&lt;', '<')
      .replaceAll('&gt;', '>')
      .replaceAll(RegExp(r'\n{3,}'), '\n\n')
      .trim();
}
