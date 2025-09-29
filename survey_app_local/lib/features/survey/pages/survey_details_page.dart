/// Página de exibição dos detalhes de um questionário.
///
/// Mostra informações completas sobre um questionário específico,
/// incluindo metadados como ID, nome, descrição, criador, contato e datas.
/// A descrição pode conter formatação HTML.
library;

import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:survey_app/core/utils/formatters.dart';
import 'package:survey_app/core/repositories/survey_repository.dart';
import 'package:survey_app/widgets/common/async_scaffold.dart';

/// Página que exibe informações detalhadas de um questionário.
///
/// Carrega e apresenta todos os metadados do questionário selecionado,
/// incluindo descrição formatada em HTML quando aplicável.
///
/// Esta página é acessada através da página de configurações quando
/// o usuário deseja visualizar detalhes de um questionário específico.
class SurveyDetailsPage extends StatefulWidget {
  /// Caminho do arquivo JSON do questionário
  final String surveyPath;

  /// Nome legível do questionário para exibição
  final String surveyDisplayName;

  /// Cria uma página de detalhes do questionário.
  ///
  /// [surveyPath] - Caminho para o arquivo JSON do questionário
  /// [surveyDisplayName] - Nome formatado para exibição
  const SurveyDetailsPage({
    super.key,
    required this.surveyPath,
    required this.surveyDisplayName,
  });

  @override
  State<SurveyDetailsPage> createState() => _SurveyDetailsPageState();
}

/// Estado da página de detalhes do questionário.
///
/// Controla o carregamento dos dados do questionário e a exibição
/// das informações formatadas na interface.
class _SurveyDetailsPageState extends State<SurveyDetailsPage> {
  /// Dados completos do questionário carregados do JSON
  Map<String, dynamic>? _surveyData;

  /// Flag que indica se os dados ainda estão carregando
  bool _isLoading = true;

  /// Mensagem de erro caso ocorra falha no carregamento
  String? _errorMessage;

  final SurveyRepository _surveyRepository = SurveyRepository();

  @override
  void initState() {
    super.initState();
    _loadSurveyDetails();
  }

  /// Carrega os detalhes do questionário do arquivo JSON.
  ///
  /// Deserializa o arquivo JSON e armazena os dados completos
  /// para exibição na interface. Em caso de erro, define uma
  /// mensagem de erro apropriada.
  ///
  /// Throws [Exception] se não conseguir carregar ou deserializar o arquivo.
  Future<void> _loadSurveyDetails() async {
    try {
      final jsonData = await _surveyRepository.getRawByPath(widget.surveyPath);
      setState(() {
        _surveyData = jsonData;
        _isLoading = false;
      });
    } catch (e) {
      print("Erro ao carregar detalhes do questionário: $e");
      setState(() {
        _errorMessage = 'Erro ao carregar os detalhes do questionário.';
        _isLoading = false;
      });
    }
  }

  /// Converte qualquer valor em [String] de forma segura.
  ///
  /// Retorna [fallback] quando o valor for nulo ou, no caso de string,
  /// estiver vazia após trim. Caso contrário, chama `toString()`.
  String _asString(dynamic value, {String fallback = 'Não informado'}) {
    if (value == null) return fallback;
    if (value is String && value.trim().isEmpty) return fallback;
    return value.toString();
  }

  /// Formata uma data para exibição em formato brasileiro.
  ///
  /// [dateString] - String da data no formato ISO ou similar
  ///
  /// Returns a data formatada ou a string original se não conseguir formatar
  String _formatDate(String? dateString) {
    final formatted = Formatters.formatIsoDateBr(dateString);
    return formatted.isEmpty ? 'Não informado' : formatted;
  }

  /// Constrói um card com informações do questionário.
  ///
  /// [title] - Título da seção
  /// [content] - Widget com o conteúdo da seção
  ///
  /// Returns um Card formatado com o conteúdo
  Widget _buildInfoCard(String title, Widget content) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 8),
            content,
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AsyncScaffold(
      isLoading: _isLoading,
      error: _errorMessage,
      appBar: AppBar(
        title: Text('Detalhes - ${widget.surveyDisplayName}'),
        backgroundColor: Colors.amber,
      ),
      // Evita acessar _surveyData! enquanto ainda está carregando
      // ou quando há erro. O AsyncScaffold já cuida desses estados.
      child: (_isLoading || _errorMessage != null)
          ? const SizedBox.shrink()
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Informações básicas
                  _buildInfoCard(
                    'Informações Básicas',
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildDetailRow('ID:', _asString(_surveyData!['_id'])),
                        _buildDetailRow(
                          'Nome:',
                          _asString(_surveyData!['surveyName']),
                        ),
                        _buildDetailRow(
                          'Criador:',
                          _asString(_surveyData!['creatorName']),
                        ),
                        if (_surveyData!['creatorContact'] != null &&
                            _surveyData!['creatorContact']
                                .toString()
                                .isNotEmpty)
                          _buildDetailRow(
                            'Contato:',
                            _asString(_surveyData!['creatorContact']),
                          ),
                      ],
                    ),
                  ),

                  // Datas
                  _buildInfoCard(
                    'Informações Temporais',
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildDetailRow(
                          'Data de Criação:',
                          _formatDate(_surveyData!['createdAt']),
                        ),
                        _buildDetailRow(
                          'Última Modificação:',
                          _formatDate(_surveyData!['modifiedAt']),
                        ),
                      ],
                    ),
                  ),

                  // Descrição (com suporte a HTML)
                  _buildInfoCard(
                    'Descrição',
                    _surveyData!['surveyDescription'] != null &&
                            _surveyData!['surveyDescription']
                                .toString()
                                .contains('<')
                        ? Html(
                            data: _asString(
                              _surveyData!['surveyDescription'],
                              fallback: 'Nenhuma descrição disponível.',
                            ),
                            style: {
                              "body": Style(
                                fontSize: FontSize(16.0),
                                lineHeight: const LineHeight(1.4),
                              ),
                              "p": Style(margin: Margins.only(bottom: 8.0)),
                            },
                          )
                        : Text(
                            _asString(
                              _surveyData!['surveyDescription'],
                              fallback: 'Nenhuma descrição disponível.',
                            ),
                            style: const TextStyle(fontSize: 16),
                          ),
                  ),

                  // Estatísticas do questionário
                  _buildInfoCard(
                    'Estatísticas',
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildDetailRow(
                          'Número de Perguntas:',
                          '${(_surveyData!['questions'] as List?)?.length ?? 0} perguntas',
                        ),
                        if (_surveyData!['instructions'] != null)
                          _buildDetailRow('Possui Instruções:', 'Sim'),
                        if (_surveyData!['finalNotes'] != null &&
                            _surveyData!['finalNotes'].toString().isNotEmpty)
                          _buildDetailRow('Possui Notas Finais:', 'Sim'),
                      ],
                    ),
                  ),

                  // Notas finais (se existirem)
                  if (_surveyData!['finalNotes'] != null &&
                      _surveyData!['finalNotes'].toString().isNotEmpty)
                    _buildInfoCard(
                      'Notas Finais',
                      Html(
                        data: _asString(_surveyData!['finalNotes']),
                        style: {
                          "body": Style(
                            fontSize: FontSize(16.0),
                            lineHeight: const LineHeight(1.4),
                          ),
                          "p": Style(margin: Margins.only(bottom: 8.0)),
                          "strong": Style(fontWeight: FontWeight.bold),
                          "a": Style(
                            color: Colors.blue.shade700,
                            textDecoration: TextDecoration.underline,
                          ),
                        },
                      ),
                    ),

                  const SizedBox(height: 24),

                  // Botão de voltar
                  ElevatedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      backgroundColor: Colors.amber,
                      foregroundColor: Colors.black,
                    ),
                    child: const Text(
                      'Voltar às Configurações',
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  /// Constrói uma linha de detalhe com rótulo e valor.
  ///
  /// [label] - Rótulo do campo
  /// [value] - Valor do campo
  ///
  /// Returns um Widget com a linha formatada
  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 140,
            child: Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                color: Colors.grey,
              ),
            ),
          ),
          Expanded(child: Text(value, style: const TextStyle(fontSize: 16))),
        ],
      ),
    );
  }
}
