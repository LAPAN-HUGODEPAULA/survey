/// Página para a escrita da narrativa clínica.
library;

import 'package:clinical_narrative_app/core/models/agent_response.dart';
import 'package:clinical_narrative_app/core/navigation/app_navigator.dart';
import 'package:clinical_narrative_app/core/providers/app_settings.dart';
import 'package:clinical_narrative_app/core/services/clinical_writer_service.dart';
import 'package:design_system_flutter/report/report_models.dart';
import 'package:design_system_flutter/widgets.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

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
        const SnackBar(
          content: Text('Informe o conteúdo para gerar a narrativa.'),
        ),
      );
      return;
    }

    final settings = Provider.of<AppSettings>(context, listen: false);
    setState(() => _isGenerating = true);
    try {
      final service = ClinicalWriterService();
      final response = await service.processContent(rawContent);
      final report = _resolveReportDocument(settings, response);
      if (report == null) {
        final message = response.errorMessage ?? 'Resposta vazia do agente.';
        throw Exception(message);
      }
      settings.setNarrative(report.toPlainText());
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Narrativa gerada com sucesso.')),
        );
        AppNavigator.toReport(context, report);
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao gerar narrativa: $error')),
        );
      }
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
        title: 'Prontuário Clínico',
        subtitle: settings.patient.name.isNotEmpty
            ? 'Paciente: ${settings.patient.name}'
            : 'Paciente não informado',
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

    return DsScaffold(
      title: 'Narrativa clinica',
      subtitle: patient.name.isNotEmpty
          ? 'Paciente: ${patient.name}'
          : 'Paciente nao informado',
      scrollable: true,
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 900),
          child: DsSection(
            eyebrow: 'Redacao',
            title: 'Rascunho da narrativa',
            subtitle:
                'Revise o conteudo clinico antes de gerar o prontuario final.',
            child: Column(
              children: [
                DsFocusFrame(
                  child: SizedBox(
                    height: 420,
                    child: TextField(
                      controller: _narrativeController,
                      decoration: const InputDecoration(
                        hintText: 'Digite a narrativa aqui...',
                        border: InputBorder.none,
                      ),
                      maxLines: null,
                      expands: true,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: DsFilledButton(
                    label: 'Gerar prontuario',
                    onPressed: _isGenerating ? null : _generateNarrative,
                    loading: _isGenerating,
                    size: DsButtonSize.large,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
