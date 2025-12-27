/// Página para a escrita da narrativa clínica.
library;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:clinical_narrative_app/core/providers/app_settings.dart';
import 'package:clinical_narrative_app/core/navigation/app_navigator.dart';

class NarrativePage extends StatefulWidget {
  const NarrativePage({super.key});

  @override
  State<NarrativePage> createState() => _NarrativePageState();
}

class _NarrativePageState extends State<NarrativePage> {
  final _narrativeController = TextEditingController();

  @override
  void dispose() {
    _narrativeController.dispose();
    super.dispose();
  }

  void _submitNarrative() {
    final settings = Provider.of<AppSettings>(context, listen: false);
    settings.setNarrative(_narrativeController.text.trim());
    AppNavigator.toThankYou(context);
  }

  @override
  Widget build(BuildContext context) {
    final patient = Provider.of<AppSettings>(context).patient;

    return Scaffold(
      appBar: AppBar(
        title: Text('Narrativa Clínica - ${patient.name}'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Expanded(
              child: TextField(
                controller: _narrativeController,
                decoration: const InputDecoration(
                  hintText: 'Digite a narrativa aqui...',
                  border: OutlineInputBorder(),
                ),
                maxLines: null,
                expands: true,
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _submitNarrative,
              child: const Text('Salvar e Finalizar'),
            ),
          ],
        ),
      ),
    );
  }
}
