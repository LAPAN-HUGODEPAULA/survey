/// Página de agradecimento.
library;

import 'package:clinical_narrative_app/core/providers/app_settings.dart';
import 'package:clinical_narrative_app/core/services/narrative_service.dart';
import 'package:clinical_narrative_app/features/demographics/pages/demographics_page.dart';
import 'package:design_system_flutter/widgets.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ThankYouPage extends StatefulWidget {
  const ThankYouPage({super.key});

  @override
  State<ThankYouPage> createState() => _ThankYouPageState();
}

class _ThankYouPageState extends State<ThankYouPage> {
  late Future<void> _saveNarrativeFuture;

  @override
  void initState() {
    super.initState();
    _saveNarrative();
  }

  void _saveNarrative() {
    final settings = Provider.of<AppSettings>(context, listen: false);
    final narrativeService = NarrativeService();
    _saveNarrativeFuture = narrativeService.saveNarrative(
      patient: settings.patient,
      narrative: settings.narrative,
    );
  }

  @override
  Widget build(BuildContext context) {
    return DsScaffold(
      title: 'Narrativa concluida',
      subtitle: 'Finalize o fluxo ou reinicie uma nova narrativa clinica.',
      body: Center(
        child: FutureBuilder<void>(
          future: _saveNarrativeFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const SizedBox(
                width: 48,
                height: 48,
                child: CircularProgressIndicator(),
              );
            }

            if (snapshot.hasError) {
              return ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 640),
                child: DsSection(
                  eyebrow: 'Persistencia',
                  title: 'Erro ao salvar a narrativa',
                  subtitle: snapshot.error.toString(),
                  child: SizedBox(
                    width: double.infinity,
                    child: DsOutlinedButton(
                      label: 'Tentar novamente',
                      onPressed: () {
                        setState(_saveNarrative);
                      },
                    ),
                  ),
                ),
              );
            }

            return ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 640),
              child: DsSection(
                eyebrow: 'Persistencia',
                title: 'Narrativa salva com sucesso',
                subtitle:
                    'Os dados foram registrados e o fluxo pode ser reiniciado para um novo paciente.',
                child: Column(
                  children: [
                    Icon(
                      Icons.check_circle_outline,
                      size: 96,
                      color: Theme.of(context).colorScheme.tertiary,
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: DsFilledButton(
                        label: 'Iniciar nova narrativa',
                        onPressed: () {
                          Provider.of<AppSettings>(
                            context,
                            listen: false,
                          ).clearPatientData();
                          Navigator.of(context).pushAndRemoveUntil(
                            MaterialPageRoute<void>(
                              builder: (context) => const DemographicsPage(),
                            ),
                            (Route<dynamic> route) => false,
                          );
                        },
                        size: DsButtonSize.large,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
