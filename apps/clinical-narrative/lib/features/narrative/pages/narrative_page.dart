/// Página para a escrita da narrativa clínica.
library;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:clinical_narrative_app/core/providers/app_settings.dart';
import 'package:clinical_narrative_app/core/services/clinical_writer_service.dart';
import 'package:clinical_narrative_app/core/navigation/app_navigator.dart';
import 'package:design_system_flutter/report/report_models.dart';
import 'package:clinical_narrative_app/core/models/agent_response.dart';

class NarrativePage extends StatefulWidget {
  const NarrativePage({super.key});

  @override
  State<NarrativePage> createState() => _NarrativePageState();
}

class _NarrativePageState extends State<NarrativePage> {
  final _narrativeController = TextEditingController();
  bool _isGenerating = false;

  @override
  void dispose() {
    _narrativeController.dispose();
    super.dispose();
  }

  Future<void> _generateNarrative() async {
    final rawContent = _narrativeController.text.trim();
    if (rawContent.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Informe o conteudo para gerar a narrativa.')),
      );
      return;
    }

    setState(() => _isGenerating = true);
    try {
      final service = ClinicalWriterService();
      final response = await service.processContent(rawContent);
      final settings = Provider.of<AppSettings>(context, listen: false);
      final report = _resolveReportDocument(settings, response);
      if (report == null) {
        final message = response.errorMessage ?? 'Resposta vazia do agente.';
        throw Exception(message);
      }
      settings.setNarrative(report.toPlainText());
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Narrativa gerada com sucesso.')),
      );
      if (mounted) {
        AppNavigator.toReport(context, report);
      }
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao gerar narrativa: $error')),
      );
    } finally {
      if (mounted) {
        setState(() => _isGenerating = false);
      }
    }
  }

  ReportDocument? _resolveReportDocument(
    AppSettings settings,
    AgentResponse response,
  ) {
    final errorMessage = response.errorMessage?.trim();
    if (errorMessage != null && errorMessage.isNotEmpty) {
      return ReportDocument.fromError(errorMessage);
    }

    if (response.report != null) {
      return response.report;
    }

    final medicalRecord = response.medicalRecord?.trim();
    if (medicalRecord != null && medicalRecord.isNotEmpty) {
      return ReportDocument.fromPlainText(
        text: medicalRecord,
        title: 'Prontuario Clinico',
        subtitle: settings.patient.name.isNotEmpty
            ? 'Paciente: ${settings.patient.name}'
            : 'Paciente nao informado',
        patient: ReportPatientInfo(
          name: settings.patient.name,
          reference: settings.patient.medicalRecordId,
        ),
      );
    }

    return null;
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
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: _isGenerating ? null : _generateNarrative,
                    child: _isGenerating
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text('Gerar prontuario'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
