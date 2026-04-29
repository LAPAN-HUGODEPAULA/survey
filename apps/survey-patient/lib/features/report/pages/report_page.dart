import 'dart:convert';
import 'dart:io';

import 'package:design_system_flutter/report/report_models.dart';
import 'package:design_system_flutter/report/report_view.dart';
import 'package:design_system_flutter/widgets.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart' as path;
import 'package:patient_app/core/models/agent_response.dart';
import 'package:patient_app/core/models/patient.dart';
import 'package:patient_app/core/models/survey/question.dart';
import 'package:patient_app/core/models/survey/survey.dart';
import 'package:patient_app/core/models/survey_response.dart';
import 'package:patient_app/core/providers/app_settings.dart';
import 'package:patient_app/core/repositories/survey_repository.dart';
import 'package:patient_app/features/report/pages/report_download_stub.dart'
    if (dart.library.html) 'package:patient_app/features/report/pages/report_download_web.dart'
    as report_download;
import 'package:patient_app/shared/widgets/patient_journey_stepper.dart';
import 'package:provider/provider.dart';

class ReportPage extends StatefulWidget {
  const ReportPage({
    super.key,
    required this.survey,
    required this.surveyAnswers,
    required this.surveyQuestions,
    required this.onRestartSurvey,
    this.surveyRepository,
  });

  final Survey survey;
  final List<String> surveyAnswers;
  final List<Question> surveyQuestions;
  final Future<void> Function() onRestartSurvey;
  final SurveyRepository? surveyRepository;

  @override
  State<ReportPage> createState() => _ReportPageState();
}

class _ReportPageState extends State<ReportPage> {
  bool _isSaving = false;
  bool _saveSuccess = false;
  String? _saveError;
  String? _savedFilePath;
  String? _savedResponseId;
  AgentResponse? _agentResponse;
  String? _selectedPromptKey;
  late final SurveyRepository _surveyRepository;

  @override
  void initState() {
    super.initState();
    _surveyRepository = widget.surveyRepository ?? SurveyRepository();
    _selectedPromptKey = widget.survey.prompt?.promptKey;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _submitResponse();
    });
  }

  @override
  void dispose() {
    _surveyRepository.dispose();
    super.dispose();
  }

  List<Answer> _buildAnswers() {
    final answers = <Answer>[];
    for (int i = 0; i < widget.surveyAnswers.length; i++) {
      if (i < widget.surveyQuestions.length) {
        answers.add(
          Answer(
            id: widget.surveyQuestions[i].id,
            answer: widget.surveyAnswers[i],
          ),
        );
      }
    }
    return answers;
  }

  Patient? _resolvePatient(AppSettings settings) {
    final patient = settings.patient;
    final hasData =
        patient.name.isNotEmpty ||
        patient.email.isNotEmpty ||
        patient.birthDate.isNotEmpty ||
        patient.gender.isNotEmpty ||
        patient.ethnicity.isNotEmpty ||
        patient.educationLevel.isNotEmpty ||
        patient.profession.isNotEmpty ||
        patient.medication.isNotEmpty ||
        patient.diagnoses.isNotEmpty;
    return hasData ? patient : null;
  }

  Future<void> _submitResponse() async {
    setState(() {
      _isSaving = true;
      _saveError = null;
    });

    try {
      final settings = Provider.of<AppSettings>(context, listen: false);
      final patient = _resolvePatient(settings);

      final surveyResponse = SurveyResponse(
        surveyId: widget.survey.id,
        creatorId: widget.survey.creatorId,
        testDate: DateTime.now(),
        screenerId: settings.screener.id,
        promptKey: _selectedPromptKey,
        patient: patient,
        answers: _buildAnswers(),
      );

      final saved = await _surveyRepository.submitResponse(surveyResponse);
      setState(() {
        _isSaving = false;
        _saveSuccess = true;
        _savedResponseId = saved.id;
        _agentResponse = saved.agentResponse;
      });
      await _maybeFetchAgentResponse(surveyResponse, saved.agentResponse);
    } catch (e) {
      await _fallbackToLocalSave(e);
    }
  }

  Future<void> _maybeFetchAgentResponse(
    SurveyResponse surveyResponse,
    AgentResponse? agentResponse,
  ) async {
    if (!mounted) {
      return;
    }

    if (agentResponse != null) {
      setState(() {
        _agentResponse = agentResponse;
      });
      return;
    }

    try {
      final content = jsonEncode(surveyResponse.toJson());
      final response = await _surveyRepository.processClinicalWriter(
        content,
        promptKey: surveyResponse.promptKey,
      );
      if (!mounted) {
        return;
      }
      setState(() {
        _agentResponse = response;
      });
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Clinical writer fallback failed: $e');
      }
    }
  }

  Future<void> _fallbackToLocalSave(Object originalError) async {
    try {
      final settings = Provider.of<AppSettings>(context, listen: false);
      final patient = _resolvePatient(settings);
      final surveyResponse = SurveyResponse(
        surveyId: widget.survey.id,
        creatorId: widget.survey.creatorId,
        testDate: DateTime.now(),
        screenerId: settings.screener.id,
        promptKey: _selectedPromptKey,
        patient: patient,
        answers: _buildAnswers(),
      );

      final fileName = _generateFileName(widget.survey.id, patient?.name);
      final filePath = await _writeResponseFile(
        fileName,
        surveyResponse.toJson(),
      );

      setState(() {
        _isSaving = false;
        _saveSuccess = true;
        _savedFilePath = filePath;
        _saveError =
            'Não foi possível enviar para o servidor (${originalError.toString()}). '
            'As respostas foram salvas localmente.';
      });
    } catch (fallbackError) {
      setState(() {
        _isSaving = false;
        _saveError =
            'Erro ao enviar para o servidor: $originalError\n'
            'Falha ao salvar localmente: $fallbackError';
      });
    }
  }

  String _generateFileName(String surveyId, String? patientName) {
    final safeName = (patientName ?? '').trim().isEmpty ? 'anon' : patientName!;
    final cleanName = safeName
        .toLowerCase()
        .replaceAll(' ', '_')
        .replaceAll(RegExp(r'[^\w\s]'), '');
    return '${surveyId}_$cleanName.json';
  }

  Future<String> _writeResponseFile(
    String fileName,
    Map<String, dynamic> data,
  ) async {
    final jsonString = const JsonEncoder.withIndent('    ').convert(data);

    try {
      if (kIsWeb) {
        return await _saveToWebBrowser(fileName, jsonString);
      } else {
        return await _saveToNativeDirectory(fileName, jsonString);
      }
    } catch (e) {
      return await _saveWithFallback(fileName, jsonString);
    }
  }

  Future<String> _saveToWebBrowser(String fileName, String jsonString) async {
    return report_download.saveBrowserFile(
      fileName: fileName,
      content: jsonString,
      mimeType: 'application/json',
    );
  }

  Future<String> _saveToNativeDirectory(
    String fileName,
    String jsonString,
  ) async {
    final tempDir = Directory.systemTemp;
    final responsesDir = Directory(path.join(tempDir.path, 'survey_responses'));

    if (!await responsesDir.exists()) {
      await responsesDir.create(recursive: true);
    }

    final file = File(path.join(responsesDir.path, fileName));
    await file.writeAsString(jsonString);

    return file.path;
  }

  Future<String> _saveWithFallback(String fileName, String jsonString) async {
    if (kIsWeb) {
      try {
        await report_download.saveBrowserLocalStorage(
          key: 'survey_response_$fileName',
          value: jsonString,
        );
        return 'Salvo no armazenamento do navegador: $fileName';
      } catch (e) {
        return 'Dados preparados (não foi possível salvar): $fileName';
      }
    }
    return 'Dados preparados para salvamento: $fileName';
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
      final patient = _resolvePatient(settings);
      return ReportDocument.fromPlainText(
        text: medicalRecord,
        title: 'Relatório de Triagem Sensorial',
        subtitle: 'Para: Especialista responsável',
        patient: patient == null
            ? null
            : ReportPatientInfo(
                name: patient.name,
                reference: _savedResponseId,
                birthDate: patient.birthDate,
                sex: patient.gender,
              ),
      );
    }

    return null;
  }

  String _buildReportText(ReportDocument report) {
    return report.toPlainText(
      footer:
          'Gerado por LAPAN - Laboratório de Pesquisa Aplicada à Neurociência da Visão',
    );
  }

  String _generateReportFileName(String surveyId, String? patientName) {
    final baseName = _generateFileName(
      surveyId,
      patientName,
    ).replaceAll('.json', '');
    return '${baseName}_relatorio.txt';
  }

  Future<void> _exportReport(
    AppSettings settings,
    ReportDocument report,
  ) async {
    final patient = _resolvePatient(settings);
    final fileName = _generateReportFileName(widget.survey.id, patient?.name);
    final reportText = _buildReportText(report);
    final result = await _writeReportFile(fileName, reportText);

    if (!mounted) {
      return;
    }

    showDsToast(
      context,
      feedback: DsFeedbackMessage(
        severity: DsStatusType.success,
        title: 'Exportação concluída',
        message: result,
      ),
    );
  }

  Future<void> _exportPdf() async {
    if (kIsWeb) {
      await report_download.printBrowserPage();
      return;
    }
    if (!mounted) {
      return;
    }
    showDsToast(
      context,
      feedback: const DsFeedbackMessage(
        severity: DsStatusType.info,
        title: 'Exportação em PDF',
        message: 'A exportação em PDF está disponível apenas no navegador.',
      ),
    );
  }

  Future<String> _writeReportFile(String fileName, String content) async {
    try {
      if (kIsWeb) {
        return await _saveReportToWebBrowser(fileName, content);
      }
      return await _saveReportToNativeDirectory(fileName, content);
    } catch (e) {
      return 'Falha ao exportar relatório: $e';
    }
  }

  Future<String> _saveReportToWebBrowser(
    String fileName,
    String content,
  ) async {
    return report_download.saveBrowserFile(
      fileName: fileName,
      content: content,
      mimeType: 'text/plain',
    );
  }

  Future<String> _saveReportToNativeDirectory(
    String fileName,
    String content,
  ) async {
    final tempDir = Directory.systemTemp;
    final reportsDir = Directory(path.join(tempDir.path, 'survey_reports'));

    if (!await reportsDir.exists()) {
      await reportsDir.create(recursive: true);
    }

    final file = File(path.join(reportsDir.path, fileName));
    await file.writeAsString(content);
    return file.path;
  }

  @override
  Widget build(BuildContext context) {
    final settings = Provider.of<AppSettings>(context);
    final reportDocument = _agentResponse == null
        ? null
        : _resolveReportDocument(settings, _agentResponse!);
    final displayName = widget.survey.surveyDisplayName.isNotEmpty
        ? widget.survey.surveyDisplayName
        : widget.survey.surveyName;

    return DsScaffold(
      title: 'Relatório',
      subtitle: 'Análise consolidada do questionário $displayName.',
      onBack: () => Navigator.of(context).popUntil(
        (route) => route.settings.name == 'ThankYouPage' || route.isFirst,
      ),
      backLabel: 'Voltar',
      scrollable: true,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const PatientJourneyStepper(
            currentStep: PatientJourneyStep.relatorio,
          ),
          if (_isSaving) ...[
            const Center(child: DsLoading()),
            const SizedBox(height: 16),
            const DsInlineMessage(
              feedback: DsFeedbackMessage(
                severity: DsStatusType.info,
                title: 'Preparando relatório',
                message: 'Respostas registradas. Relatório em preparo.',
              ),
              margin: EdgeInsets.zero,
            ),
            const SizedBox(height: 24),
          ],
          if (_saveSuccess && !_isSaving)
            DsMessageBanner(
              feedback: DsFeedbackMessage(
                severity: DsStatusType.success,
                title: _savedResponseId != null
                    ? 'Respostas enviadas'
                    : 'Respostas salvas localmente',
                message: _savedResponseId != null
                    ? 'Agora você pode visualizar, imprimir ou exportar o relatório.'
                    : 'Não conseguimos enviar ao servidor, mas os dados foram preservados localmente.',
              ),
              footer: (_savedResponseId != null || _savedFilePath != null)
                  ? Text(
                      _savedResponseId != null
                          ? 'Protocolo: $_savedResponseId'
                          : 'Arquivo salvo em: $_savedFilePath',
                    )
                  : null,
            ),
          if (_saveError != null)
            Padding(
              padding: const EdgeInsets.only(top: 16.0),
              child: DsMessageBanner(
                feedback: DsFeedbackMessage(
                  severity: DsStatusType.warning,
                  title: 'Envio com ressalvas',
                  message: _saveError!,
                ),
              ),
            ),
          const SizedBox(height: 16),
          if (reportDocument != null) ...[
            ReportView(
              report: reportDocument,
              footer:
                  'Gerado por LAPAN - Laboratório de Pesquisa Aplicada à Neurociência da Visão',
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                DsFilledButton(
                  label: 'Salvar como texto',
                  icon: Icons.text_snippet_outlined,
                  onPressed: () => _exportReport(settings, reportDocument),
                ),
                DsOutlinedButton(
                  label: 'Exportar PDF',
                  icon: Icons.picture_as_pdf_outlined,
                  onPressed: _exportPdf,
                ),
              ],
            ),
          ],
          if (!_isSaving && reportDocument == null && _saveError == null)
            Padding(
              padding: const EdgeInsets.only(top: 24.0),
              child: Text(
                'Ainda estamos processando o seu relatório. Aguarde alguns instantes.',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: DsOutlinedButton(
              label: 'Iniciar nova avaliação',
              onPressed: widget.onRestartSurvey,
            ),
          ),
        ],
      ),
    );
  }
}
