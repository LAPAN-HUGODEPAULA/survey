library;

import 'dart:convert';
import 'dart:io';

import 'package:design_system_flutter/report/report_models.dart';
import 'package:design_system_flutter/report/report_view.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart' as path;
import 'package:provider/provider.dart';
import 'package:universal_html/html.dart' as html;
import 'package:patient_app/core/models/agent_response.dart';
import 'package:patient_app/core/models/patient.dart';
import 'package:patient_app/core/models/survey/question.dart';
import 'package:patient_app/core/models/survey/survey.dart';
import 'package:patient_app/core/models/survey_response.dart';
import 'package:patient_app/core/providers/app_settings.dart';
import 'package:patient_app/core/repositories/survey_repository.dart';

class ReportPage extends StatefulWidget {
  const ReportPage({
    super.key,
    required this.survey,
    required this.surveyAnswers,
    required this.surveyQuestions,
    this.surveyRepository,
  });

  final Survey survey;
  final List<String> surveyAnswers;
  final List<Question> surveyQuestions;
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
  late final SurveyRepository _surveyRepository;

  @override
  void initState() {
    super.initState();
    _surveyRepository = widget.surveyRepository ?? SurveyRepository();
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
    final hasData = patient.name.isNotEmpty ||
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
        creatorName: widget.survey.creatorName,
        creatorContact: widget.survey.creatorContact ?? 'Nao informado',
        testDate: DateTime.now(),
        screener: settings.screener,
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
      final response = await _surveyRepository.processClinicalWriter(content);
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
        creatorName: widget.survey.creatorName,
        creatorContact: widget.survey.creatorContact ?? 'Nao informado',
        testDate: DateTime.now(),
        screener: settings.screener,
        patient: patient,
        answers: _buildAnswers(),
      );

      final fileName = _generateFileName(
        widget.survey.id,
        patient?.name,
      );
      final filePath = await _writeResponseFile(fileName, surveyResponse.toJson());

      setState(() {
        _isSaving = false;
        _saveSuccess = true;
        _savedFilePath = filePath;
        _saveError =
            'Nao foi possivel enviar para o servidor (${originalError.toString()}). '
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
    final bytes = utf8.encode(jsonString);
    final blob = html.Blob([bytes]);
    final url = html.Url.createObjectUrlFromBlob(blob);
    final anchor = html.AnchorElement(href: url)
      ..download = fileName
      ..style.display = 'none';

    html.document.body?.children.add(anchor);
    anchor.click();
    anchor.remove();
    html.Url.revokeObjectUrl(url);

    return 'Download iniciado: $fileName';
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
        html.window.localStorage['survey_response_$fileName'] = jsonString;
        return 'Salvo no armazenamento do navegador: $fileName';
      } catch (e) {
        return 'Dados preparados (nao foi possivel salvar): $fileName';
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
        title: 'Relatorio de Triagem Sensorial',
        subtitle: settings.screener.name.isNotEmpty
            ? 'Para: ${settings.screener.name}'
            : 'Para: Especialista responsavel',
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
          'Gerado por LAPAN - Labotatorio de Pesquisa Aplicada a Neurociencias da Visao',
    );
  }

  String _generateReportFileName(String surveyId, String? patientName) {
    final baseName = _generateFileName(surveyId, patientName).replaceAll('.json', '');
    return '${baseName}_relatorio.txt';
  }

  Future<void> _exportReport(AppSettings settings, ReportDocument report) async {
    final patient = _resolvePatient(settings);
    final fileName = _generateReportFileName(
      widget.survey.id,
      patient?.name,
    );
    final reportText = _buildReportText(report);
    final result = await _writeReportFile(fileName, reportText);

    if (!mounted) {
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(result)),
    );
  }

  Future<void> _exportPdf() async {
    if (kIsWeb) {
      html.window.print();
      return;
    }
    if (!mounted) {
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Exportacao em PDF disponivel no navegador.')),
    );
  }

  Future<String> _writeReportFile(String fileName, String content) async {
    try {
      if (kIsWeb) {
        return await _saveReportToWebBrowser(fileName, content);
      }
      return await _saveReportToNativeDirectory(fileName, content);
    } catch (e) {
      return 'Falha ao exportar relatorio: $e';
    }
  }

  Future<String> _saveReportToWebBrowser(String fileName, String content) async {
    final bytes = utf8.encode(content);
    final blob = html.Blob([bytes]);
    final url = html.Url.createObjectUrlFromBlob(blob);
    final anchor = html.AnchorElement(href: url)
      ..download = fileName
      ..style.display = 'none';

    html.document.body?.children.add(anchor);
    anchor.click();
    anchor.remove();
    html.Url.revokeObjectUrl(url);

    return 'Download iniciado: $fileName';
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

    return Scaffold(
      appBar: AppBar(
        title: const Text('Relatorio'),
        automaticallyImplyLeading: false,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 860),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (_isSaving) ...[
                  const Center(child: CircularProgressIndicator()),
                  const SizedBox(height: 16),
                  const Text(
                    'Gerando relatorio...',
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                ],
                if (_saveSuccess && !_isSaving)
                  _StatusBanner(
                    icon: Icons.check_circle_outline,
                    message: _savedResponseId != null
                        ? 'Respostas enviadas com sucesso!'
                        : 'Respostas salvas localmente.',
                    detail: _savedResponseId != null
                        ? 'Protocolo: $_savedResponseId'
                        : _savedFilePath,
                    color: Theme.of(context).colorScheme.tertiary,
                  ),
                if (_saveError != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 16.0),
                    child: _StatusBanner(
                      icon: Icons.warning_amber_outlined,
                      message: _saveError!,
                      color: Theme.of(context).colorScheme.error,
                    ),
                  ),
                const SizedBox(height: 16),
                if (reportDocument != null) ...[
                  ReportView(
                    report: reportDocument,
                    footer:
                        'Gerado por LAPAN - Labotatorio de Pesquisa Aplicada a Neurociencias da Visao',
                  ),
                  const SizedBox(height: 16),
                  Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: [
                      ElevatedButton.icon(
                        onPressed: () => _exportReport(settings, reportDocument),
                        icon: const Icon(Icons.text_snippet_outlined),
                        label: const Text('Salvar como texto'),
                      ),
                      OutlinedButton.icon(
                        onPressed: _exportPdf,
                        icon: const Icon(Icons.picture_as_pdf_outlined),
                        label: const Text('Exportar PDF'),
                      ),
                    ],
                  ),
                ],
                if (!_isSaving && reportDocument == null && _saveError == null)
                  Padding(
                    padding: const EdgeInsets.only(top: 24.0),
                    child: Text(
                      'Ainda estamos processando o relatorio. Aguarde alguns instantes.',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyMedium,
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

class _StatusBanner extends StatelessWidget {
  const _StatusBanner({
    required this.icon,
    required this.message,
    this.detail,
    required this.color,
  });

  final IconData icon;
  final String message;
  final String? detail;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: scheme.outline),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  message,
                  style: Theme.of(context)
                      .textTheme
                      .bodyMedium
                      ?.copyWith(fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
          if (detail != null && detail!.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              detail!,
              style: Theme.of(context)
                  .textTheme
                  .bodySmall
                  ?.copyWith(color: scheme.onSurfaceVariant),
            ),
          ],
        ],
      ),
    );
  }
}
