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
  DsFeedbackMessage? _feedback;
  AIProgress? _aiProgress;
  bool _retryableFailure = false;

  @override
  void dispose() {
    _narrativeController.dispose();
    super.dispose();
  }

  Future<void> _generateNarrative() async {
    final rawContent = _narrativeController.text.trim();
    if (rawContent.isEmpty) {
      setState(() {
        _feedback = const DsFeedbackMessage(
          severity: DsStatusType.error,
          title: 'Conteúdo obrigatório',
          message: 'Informe o conteúdo antes de gerar a narrativa.',
        );
      });
      return;
    }

    final settings = Provider.of<AppSettings>(context, listen: false);
    setState(() {
      _isGenerating = true;
      _retryableFailure = false;
      _aiProgress = const AIProgress(stage: 'organizing_data');
      _feedback = const DsFeedbackMessage(
        severity: DsStatusType.info,
        title: 'Gerando narrativa',
        message:
            'Estamos estruturando um texto clínico consistente a partir do conteúdo informado.',
      );
    });
    try {
      final service = ClinicalWriterService();
      final response = await _generateWithPolling(service, rawContent);
      if (response == null) {
        throw Exception(
          _feedback?.message ??
              'Não foi possível concluir a geração no momento.',
        );
      }
      final report = _resolveReportDocument(settings, response);
      if (report == null) {
        final message = response.errorMessage ?? 'Resposta vazia do agente.';
        throw Exception(message);
      }
      settings.setNarrative(report.toPlainText());
      if (mounted) {
        setState(() {
          _feedback = const DsFeedbackMessage(
            severity: DsStatusType.success,
            title: 'Narrativa gerada',
            message: 'A narrativa foi gerada com sucesso.',
          );
        });
        AppNavigator.toReport(context, report);
      }
    } catch (error) {
      if (mounted) {
        setState(() {
          _feedback = DsFeedbackMessage(
            severity: _retryableFailure
                ? DsStatusType.warning
                : DsStatusType.error,
            title: 'Falha ao gerar narrativa',
            message: 'Erro ao gerar narrativa: $error',
            primaryAction: _retryableFailure
                ? DsFeedbackAction(
                    label: 'Tentar Novamente',
                    onPressed: _generateNarrative,
                    icon: Icons.refresh,
                  )
                : null,
          );
        });
      }
    } finally {
      if (mounted) {
        setState(() => _isGenerating = false);
      }
    }
  }

  Future<AgentResponse?> _generateWithPolling(
    ClinicalWriterService service,
    String rawContent,
  ) async {
    final task = await service.startProcessTask(rawContent);
    final taskId = task['taskId']?.toString() ?? task['task_id']?.toString();
    if (taskId == null || taskId.isEmpty) {
      return service.processContent(rawContent);
    }
    final startProgress = task['aiProgress'] ?? task['ai_progress'];
    if (startProgress is Map<String, dynamic> && mounted) {
      setState(() {
        _aiProgress = AIProgress.fromJson(startProgress);
      });
    }
    for (var attempt = 0; attempt < 120; attempt++) {
      await Future<void>.delayed(const Duration(seconds: 1));
      final statusPayload = await service.fetchTaskStatus(taskId);
      final progressPayload =
          statusPayload['aiProgress'] ?? statusPayload['ai_progress'];
      if (progressPayload is Map<String, dynamic> && mounted) {
        setState(() {
          _aiProgress = AIProgress.fromJson(progressPayload);
        });
      }
      final status = statusPayload['status']?.toString() ?? '';
      if (status == 'completed' &&
          statusPayload['result'] is Map<String, dynamic>) {
        return AgentResponse.fromJson(
          statusPayload['result'] as Map<String, dynamic>,
        );
      }
      if (status == 'failed') {
        final errorPayload = statusPayload['error'];
        if (errorPayload is Map<String, dynamic>) {
          _retryableFailure = errorPayload['retryable'] as bool? ?? false;
          _feedback = DsFeedbackMessage(
            severity: _retryableFailure
                ? DsStatusType.warning
                : DsStatusType.error,
            title: 'Falha ao gerar narrativa',
            message:
                errorPayload['userMessage']?.toString() ??
                'Não conseguimos gerar a análise automática para este caso.',
          );
        }
        return null;
      }
    }
    _retryableFailure = true;
    _feedback = const DsFeedbackMessage(
      severity: DsStatusType.warning,
      title: 'A análise está demorando mais que o esperado',
      message: 'Tente novamente em alguns instantes.',
    );
    return null;
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
    final settings = Provider.of<AppSettings>(context);
    final patient = settings.patient;
    final tone = DsEmotionalToneProvider.resolveTokens(context);

    return DsScaffold(
      title: 'Narrativa clínica',
      subtitle: patient.name.isNotEmpty
          ? 'Paciente: ${patient.name}'
          : 'Paciente não informado',
      userName: settings.screenerDisplayName,
      showAmbientGreeting: true,
      scrollable: true,
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 900),
          child: DsSection(
            eyebrow: 'Redação',
            title: 'Rascunho da narrativa',
            subtitle:
                'Revise o conteúdo clínico antes de gerar o prontuário final.',
            child: Column(
              children: [
                if (_feedback != null) ...[
                  DsMessageBanner(feedback: _feedback!),
                ],
                if (_isGenerating) ...[
                  DsAIProgressIndicator(
                    stage: _aiProgress?.stage ?? 'organizing_data',
                    severity: _aiProgress?.severity ?? 'info',
                    retryable: false,
                    userName: settings.screenerDisplayName,
                    wayfindingMessage: tone.waitingSupportMessage,
                  ),
                  const SizedBox(height: 12),
                ],
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
                    label: 'Gerar prontuário',
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
