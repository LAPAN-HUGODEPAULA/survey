library;

import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:provider/provider.dart';
import 'package:patient_app/core/navigation/app_navigator.dart';
import 'package:patient_app/core/providers/app_settings.dart';
import 'package:patient_app/widgets/common/async_scaffold.dart';

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
    settings.setScreenerName(
      const String.fromEnvironment(
        'DEFAULT_SCREENER_NAME',
        defaultValue: 'self',
      ),
    );
    settings.setScreenerContact(
      const String.fromEnvironment(
        'DEFAULT_SCREENER_CONTACT',
        defaultValue: 'contact@lapan.com.br',
      ),
    );
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

        return AsyncScaffold(
          isLoading: isLoading,
          error: error != null
              ? 'Falha ao carregar questionarios: $error'
              : survey == null
                  ? 'Nenhum questionario disponivel. Verifique a conexao.'
                  : null,
          appBar: AppBar(
            title: const Text('Bem-vindo'),
            automaticallyImplyLeading: false,
          ),
          child: survey == null
              ? const SizedBox.shrink()
              : Center(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(24.0),
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 720),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            survey.surveyDisplayName.isNotEmpty
                                ? survey.surveyDisplayName
                                : survey.surveyName,
                            style: Theme.of(context)
                                .textTheme
                                .headlineMedium
                                ?.copyWith(fontWeight: FontWeight.w700),
                          ),
                          const SizedBox(height: 12),
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
                          const SizedBox(height: 24),
                          Container(
                            padding: const EdgeInsets.all(16.0),
                            decoration: BoxDecoration(
                              color: Theme.of(context)
                                  .colorScheme
                                  .primaryContainer,
                              borderRadius: BorderRadius.circular(12.0),
                              border: Border.all(
                                color: Theme.of(context).colorScheme.outline,
                              ),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.info_outline,
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onPrimaryContainer,
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    'Voce respondera 7 perguntas rapidas. Ao final, sera possivel ver um resumo e gerar um relatorio.',
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyMedium
                                        ?.copyWith(
                                          color: Theme.of(context)
                                              .colorScheme
                                              .onPrimaryContainer,
                                        ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 32),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton.icon(
                              onPressed: () => AppNavigator.toInstructions(
                                context,
                              ),
                              icon: const Icon(Icons.play_arrow),
                              label: const Text('Iniciar Questionario'),
                              style: ElevatedButton.styleFrom(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
        );
      },
    );
  }
}
