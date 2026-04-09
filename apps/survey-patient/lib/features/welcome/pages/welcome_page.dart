import 'package:design_system_flutter/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
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
    settings.loadAvailableSurveys().then((_) {
      final surveys = settings.availableSurveys;
      if (surveys.isNotEmpty && settings.selectedSurveyId == null) {
        settings.selectSurvey(surveys.first.id);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AppSettings>(
      builder: (context, settings, _) {
        final survey = settings.selectedSurvey;
        final error = settings.surveyLoadError;
        final isLoading = settings.isLoadingSurveys;
        final tone = DsEmotionalToneProvider.resolveTokens(context);

        return DsScaffold(
          isLoading: isLoading,
          error: error != null
              ? 'Falha ao carregar questionário: $error'
              : survey == null
              ? 'Nenhum questionário disponível. Verifique sua conexão com a internet.'
              : null,
          errorWidget: error == null
              ? null
              : DsError(
                  message: 'Falha ao carregar questionário: $error',
                  onRetry: settings.loadAvailableSurveys,
                ),
          title: 'Bem-vindo',
          subtitle:
              'Reserve o tempo que precisar. Vamos conduzir a triagem com cuidado e clareza.',
          userName: settings.patient.name,
          showAmbientGreeting: true,
          scrollable: true,
          body: survey == null
              ? const SizedBox.shrink()
              : Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 720),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const PatientJourneyStepper(
                          currentStep: PatientJourneyStep.boasVindas,
                        ),
                        DsSection(
                          eyebrow: 'Questionario ativo',
                          title: survey.surveyDisplayName.isNotEmpty
                              ? survey.surveyDisplayName
                              : survey.surveyName,
                          subtitle:
                              'Revise o contexto antes de iniciar a triagem.',
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (survey.surveyDescription.isNotEmpty)
                                Html(
                                  data: survey.surveyDescription,
                                  style: {
                                    'body': Style(
                                      fontSize: FontSize(16.0),
                                      lineHeight: const LineHeight(1.5),
                                    ),
                                    'p': Style(
                                      margin: Margins.only(bottom: 12.0),
                                    ),
                                  },
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
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodyMedium
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
                            onPressed: () =>
                                AppNavigator.toInstructions(context),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
        );
      },
    );
  }
}
