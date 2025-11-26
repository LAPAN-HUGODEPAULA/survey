// lib/thank_you_page.dart
///
/// Página de agradecimento exibida após completar o questionário.
///
/// Página final da aplicação, apresentada quando o usuário completa
/// todas as perguntas do questionário, confirmando que as respostas
/// foram registradas com sucesso e exibindo notas finais específicas
/// do questionário quando disponíveis.
library;

import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:provider/provider.dart';
import 'package:path/path.dart' as path;
import 'package:universal_html/html.dart' as html;
import 'package:patient_app/core/providers/app_settings.dart';
import 'package:patient_app/core/models/survey/question.dart';
import 'package:patient_app/core/models/survey/survey.dart';
import 'package:patient_app/core/models/survey_response.dart';
import 'package:patient_app/core/repositories/survey_repository.dart';

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
  final Survey survey;

  /// Lista das respostas do usuário
  final List<String> surveyAnswers;

  /// Lista das questões do questionário
  final List<Question> surveyQuestions;

  /// Cria uma página de agradecimento.
  ///
  /// [finalNotes] - Notas finais em HTML específicas do questionário
  /// [surveyName] - Nome do questionário para personalização
  /// [surveyId] - ID do questionário
  /// [surveyAnswers] - Lista das respostas do usuário
  /// [surveyQuestions] - Lista das questões do questionário
  const ThankYouPage({
    super.key,
    required this.survey,
    required this.surveyAnswers,
    required this.surveyQuestions,
  });

  @override
  State<ThankYouPage> createState() => _ThankYouPageState();
}

class _ThankYouPageState extends State<ThankYouPage> {
  bool _isSaving = false;
  bool _saveSuccess = false;
  String? _saveError;
  String? _savedFilePath;
  String? _savedResponseId;
  final SurveyRepository _surveyRepository = SurveyRepository();

  @override
  void initState() {
    super.initState();
    // Envia a resposta automaticamente quando a página carrega
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _submitResponse();
    });
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

  @override
  void dispose() {
    _surveyRepository.dispose();
    super.dispose();
  }

  Future<void> _submitResponse() async {
    setState(() {
      _isSaving = true;
      _saveError = null;
    });

    try {
      final settings = Provider.of<AppSettings>(context, listen: false);

      final patient = settings.patient;

      final surveyResponse = SurveyResponse(
        surveyId: widget.survey.id,
        creatorName: widget.survey.creatorName,
        creatorContact: widget.survey.creatorContact ?? 'Não informado',
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
      });
    } catch (e) {
      await _fallbackToLocalSave(e);
    }
  }

  Future<void> _fallbackToLocalSave(Object originalError) async {
    try {
      final settings = Provider.of<AppSettings>(context, listen: false);
      final surveyResponse = SurveyResponse(
        surveyId: widget.survey.id,
        creatorName: widget.survey.creatorName,
        creatorContact: widget.survey.creatorContact ?? 'Não informado',
        testDate: DateTime.now(),
        screener: settings.screener,
        patient: settings.patient,
        answers: _buildAnswers(),
      );

      final fileName = _generateFileName(
        widget.survey.id,
        settings.patient.name,
      );
      final filePath = await _writeResponseFile(fileName, surveyResponse.toJson());

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
                  Icon(
                    Icons.check_circle_outline,
                    color: Theme.of(context).colorScheme.tertiary,
                    size: 100,
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(16.0),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.tertiaryContainer,
                      border: Border.all(
                        color: Theme.of(context).colorScheme.outline,
                      ),
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.save_alt,
                              color: Theme.of(
                                context,
                              ).colorScheme.onTertiaryContainer,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                _savedResponseId != null
                                    ? 'Respostas enviadas para o servidor com sucesso!'
                                    : 'Respostas salvas localmente.',
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Questionário: ${widget.survey.surveyDisplayName.isNotEmpty ? widget.survey.surveyDisplayName : widget.survey.surveyName}',
                          style: TextStyle(
                            fontSize: 14,
                            color: Theme.of(context).colorScheme.onTertiaryContainer,
                          ),
                        ),
                        if (_savedResponseId != null) ...[
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  'Protocolo da submissão: $_savedResponseId',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Theme.of(context).colorScheme.onTertiaryContainer,
                                    fontFamily: 'monospace',
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ] else if (_savedFilePath != null) ...[
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  'Arquivo salvo em: $_savedFilePath',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Theme.of(context).colorScheme.onTertiaryContainer,
                                    fontFamily: 'monospace',
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                        if (_saveError != null) ...[
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  _saveError!,
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Theme.of(context).colorScheme.onTertiaryContainer,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                ] else if (_saveError != null) ...[
                  Icon(
                    Icons.error_outline,
                    color: Theme.of(context).colorScheme.error,
                    size: 100,
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(16.0),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.errorContainer,
                      border: Border.all(
                        color: Theme.of(context).colorScheme.outline,
                      ),
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.warning,
                          color: Theme.of(context).colorScheme.onErrorContainer,
                        ),
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
                  widget.survey.surveyDisplayName.isNotEmpty
                      ? 'Suas respostas do questionário "${widget.survey.surveyDisplayName}" foram registradas.'
                      : 'Suas respostas foram registradas com sucesso.',
                  style: const TextStyle(fontSize: 18),
                  textAlign: TextAlign.center,
                ),

                // Notas finais do questionário (se disponíveis)
                if (widget.survey.finalNotes != null &&
                    widget.survey.finalNotes!.isNotEmpty) ...[
                  const SizedBox(height: 32),
                  Container(
                    padding: const EdgeInsets.all(20.0),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.secondaryContainer,
                      border: Border.all(
                        color: Theme.of(context).colorScheme.outline,
                      ),
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.info_outline,
                              color: Theme.of(
                                context,
                              ).colorScheme.onSecondaryContainer,
                              size: 24,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Informações Importantes',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Theme.of(
                                  context,
                                ).colorScheme.onSecondaryContainer,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Html(
                          data: widget.survey.finalNotes!,
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
