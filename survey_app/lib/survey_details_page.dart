/// Página de exibição dos detalhes de um questionário.
///
/// Mostra informações completas sobre um questionário específico,
/// incluindo metadados como ID, nome, descrição, criador, contato e datas.
/// A descrição pode conter formatação HTML.

library;

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_html/flutter_html.dart';

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
      final String jsonString = await rootBundle.loadString(widget.surveyPath);
      final Map<String, dynamic> jsonData = json.decode(jsonString);

      setState(() {
        _surveyData = jsonData;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Erro ao carregar os detalhes do questionário.';
        _isLoading = false;
      });
    }
  }

  /// Formata uma data para exibição em formato brasileiro.
  ///
  /// [dateString] - String da data no formato ISO ou similar
  ///
  /// Returns a data formatada ou a string original se não conseguir formatar
  String _formatDate(String? dateString) {
    if (dateString == null || dateString.isEmpty) {
      return 'Não informado';
    }

    try {
      // Tenta fazer o parse da data
      final DateTime date = DateTime.parse(dateString.replaceAll(' ', 'T'));
      return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year} às ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
    } catch (e) {
      // Se não conseguir fazer o parse, retorna a string original
      return dateString;
    }
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
    return Scaffold(
      appBar: AppBar(
        title: Text('Detalhes - ${widget.surveyDisplayName}'),
        backgroundColor: Colors.amber,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.error_outline,
                      size: 64,
                      color: Colors.red.shade400,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      _errorMessage!,
                      style: const TextStyle(fontSize: 16),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('Voltar'),
                    ),
                  ],
                ),
              ),
            )
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
                        _buildDetailRow(
                          'ID:',
                          _surveyData!['surveyId'] ?? 'Não informado',
                        ),
                        _buildDetailRow(
                          'Nome:',
                          _surveyData!['surveyName'] ?? 'Não informado',
                        ),
                        _buildDetailRow(
                          'Criador:',
                          _surveyData!['creatorName'] ?? 'Não informado',
                        ),
                        if (_surveyData!['creatorContact'] != null &&
                            _surveyData!['creatorContact']
                                .toString()
                                .isNotEmpty)
                          _buildDetailRow(
                            'Contato:',
                            _surveyData!['creatorContact'],
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
                            data: _surveyData!['surveyDescription'],
                            style: {
                              "body": Style(
                                fontSize: FontSize(16.0),
                                lineHeight: const LineHeight(1.4),
                              ),
                              "p": Style(margin: Margins.only(bottom: 8.0)),
                            },
                          )
                        : Text(
                            _surveyData!['surveyDescription'] ??
                                'Nenhuma descrição disponível.',
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
                        data: _surveyData!['finalNotes'],
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
