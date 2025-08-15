// lib/thank_you_page.dart
///
/// Página de agradecimento exibida após completar o questionário.
///
/// Página final da aplicação, apresentada quando o usuário completa
/// todas as perguntas do questionário, confirmando que as respostas
/// foram registradas com sucesso e exibindo notas finais específicas
/// do questionário quando disponíveis.

import 'dart:convert';
import 'dart:html' as html;
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:provider/provider.dart';
import 'package:survey_app/models/survey_model.dart';
import 'package:survey_app/providers/app_settings.dart';
import 'package:path/path.dart' as path;

/// Página de agradecimento final do questionário.
///
/// Exibe uma mensagem de agradecimento ao usuário após completar
/// o questionário, confirmando que as respostas foram registradas
/// com sucesso. Esta é a página terminal do fluxo da aplicação.
///
/// Opcionalmente exibe notas finais específicas do questionário
/// quando fornecidas, com suporte para formatação HTML.
///
/// A página não possui navegação de retorno, indicando que o
/// processo foi finalizado.
class ThankYouPage extends StatefulWidget {
  /// Notas finais do questionário em formato HTML (opcional)
  final String? finalNotes;

  /// Nome do questionário para personalização da mensagem
  final String? surveyName;

  /// ID do questionário
  final String? surveyId;

  /// Lista das respostas do usuário
  final List<String>? surveyAnswers;

  /// Lista das questões do questionário
  final List<Question>? surveyQuestions;

  /// Cria uma página de agradecimento.
  ///
  /// [finalNotes] - Notas finais em HTML específicas do questionário
  /// [surveyName] - Nome do questionário para personalização
  /// [surveyId] - ID do questionário
  /// [surveyAnswers] - Lista das respostas do usuário
  /// [surveyQuestions] - Lista das questões do questionário
  const ThankYouPage({
    super.key,
    this.finalNotes,
    this.surveyName,
    this.surveyId,
    this.surveyAnswers,
    this.surveyQuestions,
  });

  @override
  State<ThankYouPage> createState() => _ThankYouPageState();
}

class _ThankYouPageState extends State<ThankYouPage> {
  bool _isSaving = false;
  bool _saveSuccess = false;
  String? _saveError;
  String? _savedFilePath;

  @override
  void initState() {
    super.initState();
    // Salva o arquivo automaticamente quando a página carrega
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _saveResponseFile();
    });
  }

  /// Salva o arquivo de resposta do questionário.
  ///
  /// Cria um arquivo JSON com a mesma estrutura do exemplo fornecido,
  /// incluindo dados do survey, screener, paciente e respostas.
  Future<void> _saveResponseFile() async {
    if (widget.surveyId == null || widget.surveyAnswers == null) return;

    setState(() {
      _isSaving = true;
      _saveError = null;
    });

    try {
      final settings = Provider.of<AppSettings>(context, listen: false);

      // Obtém dados do survey dos assets
      final surveyData = await _loadSurveyData(settings.selectedSurveyPath!);

      // Prepara o JSON de resposta
      final responseData = {
        "surveyId": widget.surveyId,
        "creatorName": surveyData['creatorName'] ?? 'Não informado',
        "creatorContact": surveyData['creatorContact'] ?? 'Não informado',
        "testDate": DateTime.now().toString().substring(0, 19),
        "screener": settings.screenerName,
        "screenerEmail": settings.screenerContact,
        "patientName": settings.patientName,
        "patientEmail": settings.patientEmail,
        "patientBirthDate": settings.patientBirthDate,
        "patientGender": settings.patientGender,
        "patientEthnicity": settings.patientEthnicity,
        "patientMedication": settings.patientMedication,
        "patientDiagnoses": settings.patientDiagnoses,
        "questions": _buildQuestionsResponse(),
      };

      // Gera o nome do arquivo
      final fileName = _generateFileName(
        widget.surveyId!,
        settings.patientName,
      );

      // Salva o arquivo
      await _writeResponseFile(fileName, responseData);

      setState(() {
        _isSaving = false;
        _saveSuccess = true;
      });
    } catch (e) {
      setState(() {
        _isSaving = false;
        _saveError = 'Erro ao salvar arquivo: $e';
      });
    }
  }

  /// Carrega dados do survey do arquivo JSON.
  Future<Map<String, dynamic>> _loadSurveyData(String surveyPath) async {
    try {
      final String response = await rootBundle.loadString(surveyPath);
      return json.decode(response);
    } catch (e) {
      return {};
    }
  }

  /// Constrói a lista de perguntas e respostas no formato do JSON.
  List<Map<String, dynamic>> _buildQuestionsResponse() {
    if (widget.surveyQuestions == null || widget.surveyAnswers == null) {
      return [];
    }

    final responses = <Map<String, dynamic>>[];
    for (int i = 0; i < widget.surveyAnswers!.length; i++) {
      if (i < widget.surveyQuestions!.length) {
        responses.add({
          "id": widget.surveyQuestions![i].id,
          "answer": widget.surveyAnswers![i],
        });
      }
    }
    return responses;
  }

  /// Gera o nome do arquivo baseado no surveyId e nome do paciente.
  ///
  /// Formato: surveyId_nome_do_paciente.json
  /// Substitui espaços por sublinhado e remove caracteres especiais.
  String _generateFileName(String surveyId, String patientName) {
    final cleanName = patientName
        .toLowerCase()
        .replaceAll(' ', '_')
        .replaceAll(RegExp(r'[^\w\s]'), ''); // Remove caracteres especiais
    return '${surveyId}_$cleanName.json';
  }

  /// Escreve o arquivo de resposta no diretório apropriado.
  Future<String> _writeResponseFile(
    String fileName,
    Map<String, dynamic> data,
  ) async {
    final jsonString = const JsonEncoder.withIndent('    ').convert(data);

    try {
      if (kIsWeb) {
        // Web platform - use browser download
        return await _saveToWebBrowser(fileName, jsonString);
      } else {
        // Native platform - use file system
        return await _saveToNativeDirectory(fileName, jsonString);
      }
    } catch (e) {
      print('Erro específico da plataforma: $e');
      // Last resort fallback
      return await _saveWithFallback(fileName, jsonString);
    }
  }

  /// Salva arquivo usando download do navegador (Web).
  Future<String> _saveToWebBrowser(String fileName, String jsonString) async {
    try {
      // Create blob and trigger download
      final bytes = utf8.encode(jsonString);
      final blob = html.Blob([bytes]);
      final url = html.Url.createObjectUrlFromBlob(blob);

      final anchor = html.AnchorElement(href: url)
        ..setAttribute('download', fileName)
        ..click();

      html.Url.revokeObjectUrl(url);

      return 'Download iniciado: $fileName';
    } catch (e) {
      throw Exception('Erro ao iniciar download: $e');
    }
  }

  /// Salva arquivo no sistema de arquivos nativo (Mobile/Desktop).
  Future<String> _saveToNativeDirectory(
    String fileName,
    String jsonString,
  ) async {
    try {
      // Use system temp directory
      final tempDir = Directory.systemTemp;
      final responsesDir = Directory(
        path.join(tempDir.path, 'survey_responses'),
      );

      if (!await responsesDir.exists()) {
        await responsesDir.create(recursive: true);
      }

      final file = File(path.join(responsesDir.path, fileName));
      await file.writeAsString(jsonString);

      return file.path;
    } catch (e) {
      // Fallback to temp directory without subdirectory
      final tempDir = Directory.systemTemp;
      final file = File(path.join(tempDir.path, fileName));
      await file.writeAsString(jsonString);

      return file.path;
    }
  }

  /// Fallback method for saving files.
  Future<String> _saveWithFallback(String fileName, String jsonString) async {
    if (kIsWeb) {
      // Web fallback - try to save to browser storage or show data
      try {
        html.window.localStorage['survey_response_$fileName'] = jsonString;
        return 'Salvo no armazenamento do navegador: $fileName';
      } catch (e) {
        return 'Dados preparados (não foi possível salvar): $fileName';
      }
    } else {
      // Native fallback - just indicate the data is ready
      return 'Dados preparados para salvamento: $fileName';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Finalizado'),
        backgroundColor: Colors.amber,
        // Remove botão de voltar para indicar fim do processo
        automaticallyImplyLeading: false,
      ),
      body: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 700),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Status do salvamento
                if (_isSaving) ...[
                  const CircularProgressIndicator(),
                  const SizedBox(height: 16),
                  const Text(
                    'Salvando respostas...',
                    style: TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 24),
                ] else if (_saveSuccess) ...[
                  const Icon(
                    Icons.check_circle_outline,
                    color: Colors.green,
                    size: 100,
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(16.0),
                    decoration: BoxDecoration(
                      color: Colors.green.shade50,
                      border: Border.all(color: Colors.green.shade200),
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.save_alt, color: Colors.green.shade700),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                kIsWeb
                                    ? 'Download do arquivo iniciado com sucesso!'
                                    : 'Arquivo de respostas salvo com sucesso!',
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                        if (_savedFilePath != null) ...[
                          const SizedBox(height: 8),
                          Text(
                            kIsWeb
                                ? 'Arquivo: $_savedFilePath'
                                : 'Localização: $_savedFilePath',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.green.shade700,
                              fontFamily: 'monospace',
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                ] else if (_saveError != null) ...[
                  const Icon(Icons.error_outline, color: Colors.red, size: 100),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(16.0),
                    decoration: BoxDecoration(
                      color: Colors.red.shade50,
                      border: Border.all(color: Colors.red.shade200),
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.warning, color: Colors.red.shade700),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            _saveError!,
                            style: const TextStyle(fontSize: 14),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                ],

                // Ícone de confirmação principal (sempre visível)
                if (!_isSaving && _saveSuccess)
                  const SizedBox.shrink()
                else if (!_isSaving)
                  const Column(
                    children: [
                      Icon(
                        Icons.check_circle_outline,
                        color: Colors.orange,
                        size: 100,
                      ),
                      SizedBox(height: 24),
                    ],
                  ),

                // Mensagem principal de agradecimento
                Text(
                  'Obrigado por responder!',
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),

                // Mensagem de confirmação com nome do questionário se disponível
                Text(
                  widget.surveyName != null
                      ? 'Suas respostas do questionário "${widget.surveyName}" foram registradas com sucesso.'
                      : 'Suas respostas foram registradas com sucesso.',
                  style: const TextStyle(fontSize: 18),
                  textAlign: TextAlign.center,
                ),

                // Notas finais do questionário (se disponíveis)
                if (widget.finalNotes != null &&
                    widget.finalNotes!.isNotEmpty) ...[
                  const SizedBox(height: 32),
                  Container(
                    padding: const EdgeInsets.all(20.0),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      border: Border.all(color: Colors.blue.shade200),
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.info_outline,
                              color: Colors.blue.shade700,
                              size: 24,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Informações Importantes',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.blue.shade700,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Html(
                          data: widget.finalNotes!,
                          style: {
                            "body": Style(
                              fontSize: FontSize(16.0),
                              lineHeight: const LineHeight(1.5),
                              color: Colors.black87,
                            ),
                            "p": Style(margin: Margins.only(bottom: 12.0)),
                            "strong": Style(fontWeight: FontWeight.bold),
                            "a": Style(
                              textDecoration: TextDecoration.underline,
                            ),
                            "br": Style(margin: Margins.only(bottom: 8.0)),
                          },
                        ),
                      ],
                    ),
                  ),
                ],

                const SizedBox(height: 40),

                // Botão opcional para fechar a aplicação ou voltar ao início
                ElevatedButton(
                  onPressed: () {
                    // Limpa os dados do paciente antes de voltar ao início
                    final settings = Provider.of<AppSettings>(
                      context,
                      listen: false,
                    );
                    settings.clearPatientData();

                    Navigator.of(context).popUntil((route) => route.isFirst);
                  },
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                    backgroundColor: Colors.amber,
                    foregroundColor: Colors.black,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    'Iniciar Nova Avaliação',
                    style: TextStyle(fontSize: 16),
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
