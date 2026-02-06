/// Página de configurações da aplicação.
///
/// Permite selecionar qual questionário será utilizado dentre os disponíveis
/// e oferece acesso aos detalhes de cada questionário.
library;

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:survey_app/core/models/survey/survey.dart';
import 'package:survey_app/core/providers/app_settings.dart';
import 'package:survey_app/features/survey/pages/survey_details_page.dart';

/// Página de configurações da aplicação de questionários.
///
/// Fornece interface para:
/// - Selecionar qual questionário será aplicado
/// - Visualizar detalhes dos questionários disponíveis
///
/// As alterações são automaticamente persistidas através do [AppSettings] provider.
class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

/// Estado da página de configurações.
///
/// Gerencia os controladores dos campos de texto do nome e contato do responsável
/// e sincroniza as configurações com o provider global.
class _SettingsPageState extends State<SettingsPage> {
  /// Chave global para validação do formulário
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    // Carrega os questionários disponíveis e inicializa os controladores
    final settings = Provider.of<AppSettings>(context, listen: false);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      settings.loadAvailableSurveys();
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  // Validation methods are now provided by ValidatorSets and FormValidators

  /// Navega para a página de detalhes do questionário selecionado.
  void _showSurveyDetails(Survey survey) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SurveyDetailsPage(survey: survey),
      ),
    );
  }

  /// Submete o formulário após validação completa.
  ///
  /// Valida todos os campos obrigatórios e, se válidos, fecha a página.
  /// Exibe um SnackBar de erro se algum campo obrigatório não estiver preenchido.
  void _submitForm() {
    // Primeiro, valida os campos do formulário (TextFormField)
    bool isFormValid = _formKey.currentState!.validate();

    // Lista para armazenar erros de validação adicional
    List<String> validationErrors = [];

    // Verificação se há questionário selecionado
    final settings = Provider.of<AppSettings>(context, listen: false);
    if (settings.selectedSurvey == null) {
      validationErrors.add('Selecione um questionário');
    }

    // Se há erros de validação, mostra uma mensagem
    if (validationErrors.isNotEmpty || !isFormValid) {
      if (validationErrors.isNotEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Campos obrigatórios não preenchidos:\n• ${validationErrors.join('\n• ')}',
            ),
            backgroundColor: Theme.of(context).colorScheme.error,
            duration: const Duration(seconds: 4),
          ),
        );
      } else {
        // Se apenas os campos de texto não passaram na validação
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text(
              'Por favor, corrija os erros nos campos destacados.',
            ),
            backgroundColor: Theme.of(context).colorScheme.error,
            duration: const Duration(seconds: 3),
          ),
        );
      }
      return;
    }

    // Se tudo estiver válido, mostra mensagem de sucesso e fecha
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Configurações salvas com sucesso!'),
        backgroundColor: Theme.of(context).colorScheme.tertiary,
        duration: const Duration(seconds: 2),
      ),
    );

    Future.delayed(const Duration(milliseconds: 200), () {
      if (!mounted) return;
      context.go('/');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AppSettings>(
      builder: (context, settings, child) {

        return Scaffold(
          appBar: AppBar(title: const Text('Configurações')),
          body: Center(
            child: Container(
              constraints: const BoxConstraints(maxWidth: 700),
              child: Form(
                key: _formKey,
                child: ListView(
                  padding: const EdgeInsets.all(24.0),
                  children: [
                // Seção de seleção do questionário
                const Text(
                  'Questionário Ativo',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Selecione qual questionário será aplicado:',
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                ),
                const SizedBox(height: 16),

                // Dropdown de seleção do questionário
                if (settings.isLoadingSurveys) ...[
                  const Center(child: CircularProgressIndicator()),
                ] else if (settings.availableSurveys.isEmpty) ...[
                  Card(
                    color:
                        Theme.of(context).colorScheme.surfaceContainerHighest,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Text(
                        'Nenhum questionário foi encontrado no servidor. Verifique se o backend está em execução.',
                        style: TextStyle(
                          color: Theme.of(context)
                              .colorScheme
                              .onSurfaceVariant,
                        ),
                      ),
                    ),
                  ),
                ] else ...[
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          DropdownButtonFormField<String>(
                            key: ValueKey(settings.selectedSurveyId),
                            initialValue: settings.selectedSurveyId,
                            isExpanded: true,
                            decoration: const InputDecoration(
                              labelText: 'Questionário Selecionado *',
                              border: OutlineInputBorder(),
                              contentPadding: EdgeInsets.symmetric(
                                horizontal: 16.0,
                              ),
                            ),
                            items: settings.availableSurveys
                                .map<DropdownMenuItem<String>>((survey) {
                              final displayName =
                                  survey.surveyDisplayName.isNotEmpty
                                      ? survey.surveyDisplayName
                                      : survey.surveyName;
                              return DropdownMenuItem<String>(
                                value: survey.id,
                                child: Text(displayName),
                              );
                            }).toList(),
                            validator: (value) =>
                                value == null ? 'Campo obrigatório' : null,
                            onChanged: (value) {
                              settings.selectSurvey(value);
                            },
                          ),

                          const SizedBox(height: 16),

                          // Botão de detalhes do questionário
                          ElevatedButton.icon(
                            onPressed: settings.selectedSurvey != null
                                ? () => _showSurveyDetails(
                                      settings.selectedSurvey!,
                                    )
                                : null,
                            icon: const Icon(Icons.info_outline),
                            label: const Text('Ver Detalhes do Questionário'),
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              backgroundColor: settings.selectedSurvey != null
                                  ? Theme.of(context)
                                      .colorScheme
                                      .primaryContainer
                                  : Theme.of(context)
                                      .colorScheme
                                      .surfaceContainerHighest,
                              foregroundColor: settings.selectedSurvey != null
                                  ? Theme.of(context)
                                      .colorScheme
                                      .onPrimaryContainer
                                  : Theme.of(context).colorScheme.onSurface,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],

                const SizedBox(height: 32),

                // Informações de status
                Card(
                  color: Theme.of(context).colorScheme.primaryContainer,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.info_outline,
                              color: Theme.of(
                                context,
                              ).colorScheme.onPrimaryContainer,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Status das Configurações',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Theme.of(
                                  context,
                                ).colorScheme.onPrimaryContainer,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        _buildStatusItem(
                          'Questionário selecionado:',
                          settings.selectedSurvey != null
                              ? settings.selectedSurveyName
                              : 'Nenhum selecionado',
                          settings.selectedSurvey != null,
                        ),
                        _buildStatusItem(
                          'Questionários disponíveis:',
                          '${settings.availableSurveys.length} encontrado(s)',
                          settings.availableSurveys.isNotEmpty,
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                // Informação sobre campos obrigatórios
                Container(
                  padding: const EdgeInsets.all(16.0),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.secondaryContainer,
                    border: Border.all(
                      color: Theme.of(context).colorScheme.outline,
                    ),
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.info_outline,
                        color: Theme.of(
                          context,
                        ).colorScheme.onSecondaryContainer,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      const Expanded(
                        child: Text(
                          'Campos marcados com (*) são obrigatórios e serão validados antes de salvar.',
                          style: TextStyle(fontSize: 14),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // Botão de confirmação com validação
                ElevatedButton(
                  onPressed: _submitForm,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    'Salvar e Voltar',
                    style: TextStyle(fontSize: 18),
                  ),
                ),
              ],
            ),),),
          ),
        );
      },
    );
  }

  /// Constrói um item de status com ícone de verificação.
  ///
  /// [label] - Rótulo do item
  /// [value] - Valor do item
  /// [isValid] - Se o item está válido/configurado
  ///
  /// Returns um Widget com o item formatado
  Widget _buildStatusItem(String label, String value, bool isValid) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          Icon(
            isValid ? Icons.check_circle : Icons.cancel,
            color: isValid
                ? Theme.of(context).colorScheme.tertiary
                : Theme.of(context).colorScheme.error,
            size: 20,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: RichText(
              text: TextSpan(
                style: TextStyle(
                  fontSize: 14,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
                children: [
                  TextSpan(
                    text: label,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  TextSpan(text: ' $value'),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
