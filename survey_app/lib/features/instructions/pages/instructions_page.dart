/// Página de instruções e verificação de compreensão.
///
/// Apresenta as instruções do questionário ao usuário e verifica
/// se ele compreendeu antes de permitir o início das perguntas.
/// As instruções são carregadas dinamicamente do arquivo JSON do questionário.
library;

import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:provider/provider.dart';
import 'package:survey_app/core/models/survey/survey.dart';
import 'package:survey_app/core/providers/app_settings.dart';
import 'package:survey_app/core/navigation/app_navigator.dart';
import 'package:survey_app/core/repositories/survey_repository.dart';
import 'package:survey_app/widgets/common/async_scaffold.dart';

///';
/// Página que apresenta instruções do questionário e verifica compreensão.
///
/// Esta página é exibida após a coleta de dados demográficos e antes
/// do questionário principal. Carrega as instruções específicas do questionário
/// selecionado e garante que o usuário compreendeu através de uma pergunta
/// de verificação.
///
/// O conteúdo das instruções (preâmbulo, pergunta e respostas) é carregado
/// dinamicamente do arquivo JSON do questionário. A resposta correta é
/// sempre a última opção da lista de respostas.
class InstructionsPage extends StatefulWidget {
  /// Caminho do arquivo JSON do questionário a ser aplicado
  final String surveyPath;

  /// Cria uma página de instruções.
  ///
  /// [surveyPath] - Caminho para o arquivo JSON do questionário
  const InstructionsPage({super.key, required this.surveyPath});

  @override
  State<InstructionsPage> createState() => _InstructionsPageState();
}

/// Estado da página de instruções.
///
/// Controla o carregamento das instruções do questionário, a seleção
/// da pergunta de compreensão e a validação antes de permitir o avanço
/// para o questionário principal.
class _InstructionsPageState extends State<InstructionsPage> {
  /// Survey carregado do arquivo JSON
  Survey? _survey;

  /// Resposta selecionada pelo usuário na pergunta de compreensão
  String? _comprehensionAnswer;

  /// Flag que indica se deve mostrar mensagem de erro
  bool _showError = false;

  /// Flag que indica se as instruções ainda estão carregando
  bool _isLoading = true;

  final SurveyRepository _surveyRepository = SurveyRepository();

  @override
  void initState() {
    super.initState();
    _loadSurveyInstructions();
  }

  /// Carrega as instruções do questionário do arquivo JSON.
  ///
  /// Deserializa o arquivo JSON e extrai as informações das instruções.
  /// Em caso de erro, define _isLoading como false e exibe mensagem no console.
  ///
  /// Throws [Exception] se não conseguir carregar ou deserializar o arquivo.
  Future<void> _loadSurveyInstructions() async {
    try {
      final loaded = await _surveyRepository.getByPath(widget.surveyPath);
      setState(() {
        _survey = loaded;
        _isLoading = false;
      });
    } catch (e) {
      print("Erro ao carregar as instruções do questionário: $e");
      setState(() {
        _isLoading = false;
      });
    }
  }

  /// Inicia o questionário se a resposta de compreensão estiver correta.
  ///
  /// Valida se o usuário selecionou a resposta correta (sempre a última
  /// da lista de opções). Se sim, navega para [SurveyPage]. Se não,
  /// exibe mensagem de erro.
  void _startSurvey() {
    if (_survey?.instructions == null) return;

    setState(() {
      if (_comprehensionAnswer == _survey!.instructions.correctAnswer) {
        _showError = false;
        AppNavigator.replaceWithSurvey(context, surveyPath: widget.surveyPath);
      } else {
        _showError = true;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final hasError = _survey?.instructions == null && !_isLoading;

    // While loading or if survey not yet available, rely on AsyncScaffold to show loader/error
    final instructions = _survey?.instructions;

    return AsyncScaffold(
      isLoading: _isLoading,
      error: hasError
          ? 'Não foi possível carregar as instruções do questionário.'
          : null,
      appBar: AppBar(
        title: const Text('Instruções'),
        automaticallyImplyLeading: false,
      ),
      child: Center(
        child: Container(
          padding: const EdgeInsets.all(24.0),
          constraints: const BoxConstraints(maxWidth: 700),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Área rolável com preâmbulo e pergunta de compreensão
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Preâmbulo em HTML
                      Html(
                        data: instructions?.preamble ?? '',
                        style: {
                          "body": Style(
                            fontSize: FontSize(16.0),
                            lineHeight: const LineHeight(1.4),
                          ),
                          "p": Style(margin: Margins.only(bottom: 12.0)),
                          "ul": Style(
                            margin: Margins.symmetric(vertical: 8.0),
                            padding: HtmlPaddings.only(left: 20.0),
                          ),
                          "li": Style(margin: Margins.only(bottom: 4.0)),
                        },
                      ),
                      const SizedBox(height: 24),

                      // Pergunta de compreensão
                      Text(
                        instructions?.questionText ?? '',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Opções de resposta
                      ...((instructions?.answers ?? const <String>[]).map(
                        (option) => RadioListTile<String>(
                          title: Text(option),
                          value: option,
                          groupValue: _comprehensionAnswer,
                          onChanged: (value) => setState(() {
                            _comprehensionAnswer = value;
                            if (_showError) _showError = false;
                          }),
                          contentPadding: EdgeInsets.zero,
                        ),
                      )),

                      // Mensagem de erro
                      if (_showError)
                        Padding(
                          padding: const EdgeInsets.only(top: 16.0),
                          child: Container(
                            padding: const EdgeInsets.all(12.0),
                            decoration: BoxDecoration(
                              color: Theme.of(
                                context,
                              ).colorScheme.errorContainer,
                              border: Border.all(
                                color: Theme.of(context).colorScheme.outline,
                              ),
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.error_outline,
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.onErrorContainer,
                                  size: 20,
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    'Por favor, selecione a resposta correta para continuar.',
                                    style: TextStyle(
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.onErrorContainer,
                                      fontSize: 14,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),

              // Botão para iniciar questionário (fixo na parte inferior)
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _startSurvey,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    'Iniciar Questionário',
                    style: TextStyle(fontSize: 18),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Página de configurações do aplicativo.
///
/// Permite ao usuário atualizar os dados do aplicador e selecionar
/// o questionário ativo. As configurações são salvas e carregadas
/// através do [AppSettings].
class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  late final TextEditingController _screenerNameController;
  late final TextEditingController _screenerContactController;
  final FocusNode _screenerNameFocus = FocusNode();
  final FocusNode _screenerContactFocus = FocusNode();

  @override
  void initState() {
    super.initState();
    final appSettings = Provider.of<AppSettings>(context, listen: false);

    _screenerNameController = TextEditingController(
      text: appSettings.screener.name,
    );
    _screenerContactController = TextEditingController(
      text: appSettings.screener.email,
    );

    _screenerNameController.addListener(() {
      final appSettings = Provider.of<AppSettings>(context, listen: false);
      if (_screenerNameController.text != appSettings.screener.name) {
        appSettings.setScreenerName(_screenerNameController.text);
      }
    });
    _screenerContactController.addListener(() {
      final appSettings = Provider.of<AppSettings>(context, listen: false);
      if (_screenerContactController.text != appSettings.screener.email) {
        appSettings.setScreenerContact(_screenerContactController.text);
      }
    });
  }

  @override
  void dispose() {
    _screenerNameController.dispose();
    _screenerContactController.dispose();
    _screenerNameFocus.dispose();
    _screenerContactFocus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Configurações')),
      body: Consumer<AppSettings>(
        builder: (context, appSettings, child) {
          // To prevent cursor jumps, only update the controller's text if the
          // field is not focused and the text is out of sync.
          if (!_screenerNameFocus.hasFocus &&
              _screenerNameController.text != appSettings.screener.name) {
            _screenerNameController.text = appSettings.screener.name;
          }
          if (!_screenerContactFocus.hasFocus &&
              _screenerContactController.text != appSettings.screener.email) {
            _screenerContactController.text = appSettings.screener.email;
          }

          return ListView(
            padding: const EdgeInsets.all(16.0),
            children: [
              Text(
                'Dados do Aplicador',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _screenerNameController,
                focusNode: _screenerNameFocus,
                decoration: const InputDecoration(
                  labelText: 'Nome do Aplicador',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _screenerContactController,
                focusNode: _screenerContactFocus,
                decoration: const InputDecoration(
                  labelText: 'Email do Aplicador',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'Seleção de Questionário',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 16),
              if (appSettings.availableSurveyPaths.isEmpty)
                const Center(child: CircularProgressIndicator())
              else
                DropdownButtonFormField<String>(
                  initialValue: appSettings.selectedSurveyPath,
                  decoration: const InputDecoration(
                    labelText: 'Questionário Ativo',
                    border: OutlineInputBorder(),
                  ),
                  items: appSettings.availableSurveyPaths.map((path) {
                    // Extrai um nome legível do caminho do arquivo
                    String name = path
                        .split('/')
                        .last
                        .replaceAll('.json', '')
                        .replaceAll('_', ' ')
                        .replaceAll('-', ' ');
                    name = name
                        .split(' ')
                        .map((word) {
                          if (word.isEmpty) return '';
                          return word[0].toUpperCase() + word.substring(1);
                        })
                        .join(' ');

                    return DropdownMenuItem<String>(
                      value: path,
                      child: Text(name),
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    if (newValue != null) {
                      appSettings.selectSurvey(newValue);
                    }
                  },
                ),
            ],
          );
        },
      ),
    );
  }
}
