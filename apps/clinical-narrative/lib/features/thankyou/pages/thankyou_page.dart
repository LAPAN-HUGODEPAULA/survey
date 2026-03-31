/// Página de agradecimento.
library;

import 'package:clinical_narrative_app/core/providers/app_settings.dart';
import 'package:clinical_narrative_app/core/services/narrative_service.dart';
import 'package:clinical_narrative_app/features/demographics/pages/demographics_page.dart';
import 'package:clinical_narrative_app/shared/widgets/clinician_navigation_app_bar.dart';
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
      appBar: const ClinicianNavigationAppBar(
        title: Text('Obrigado!'),
        showHomeButton: true,
      ),
      body: Center(
        child: FutureBuilder<void>(
          future: _saveNarrativeFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const CircularProgressIndicator();
            } else if (snapshot.hasError) {
              return Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 100, color: Colors.red),
                  const SizedBox(height: 16),
                  const Text(
                    'Erro ao salvar a narrativa!',
                    style: TextStyle(fontSize: 24),
                  ),
                  const SizedBox(height: 16),
                  Text(snapshot.error.toString()),
                  const SizedBox(height: 32),
                  ElevatedButton(
                    onPressed: () {
                      setState(_saveNarrative);
                    },
                    child: const Text('Tentar Novamente'),
                  ),
                ],
              );
            } else {
              return Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.check_circle_outline,
                    size: 100,
                    color: Colors.green,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Narrativa salva com sucesso!',
                    style: TextStyle(fontSize: 24),
                  ),
                  const SizedBox(height: 32),
                  ElevatedButton(
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
                    child: const Text('Iniciar Nova Narrativa'),
                  ),
                ],
              );
            }
          },
        ),
      ),
    );
  }
}
