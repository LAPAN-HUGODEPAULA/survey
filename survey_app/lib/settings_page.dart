/// Página de configurações da aplicação.
///
/// Permite configurar o nome do responsável pela aplicação do questionário,
/// seu contato e selecionar qual questionário será utilizado dentre os disponíveis.
/// Também oferece acesso aos detalhes de cada questionário.
library;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:survey_app/providers/app_settings.dart';
import 'package:survey_app/survey_details_page.dart';

/// Página de configurações da aplicação de questionários.
///
/// Fornece interface para:
/// - Definir o nome do profissional responsável (screener)
/// - Definir o contato do profissional responsável
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

  /// Controlador para o campo de texto do nome do responsável
  late TextEditingController _screenerNameController;

  /// Controlador para o campo de texto do contato do responsável
  late TextEditingController _screenerContactController;

  @override
  void initState() {
    super.initState();
    // Carrega os questionários disponíveis e inicializa os controladores
    final settings = Provider.of<AppSettings>(context, listen: false);
    settings.loadAvailableSurveys();
    _screenerNameController = TextEditingController(
      text: settings.screenerName,
    );
    _screenerContactController = TextEditingController(
      text: settings.screenerContact,
    );
  }

  @override
  void dispose() {
    _screenerNameController.dispose();
    _screenerContactController.dispose();
    super.dispose();
  }

  /// Valida o nome completo do responsável.
  ///
  /// [name] - String do nome a ser validada
  ///
  /// Returns string de erro se inválido, null se válido
  String? _validateName(String? name) {
    if (name == null || name.isEmpty) {
      return 'Por favor, insira o nome completo do responsável.';
    }

    if (name.trim().length < 5) {
      return 'O nome deve ter pelo menos 5 caracteres.';
    }

    // Regex para validar apenas caracteres alfabéticos e espaços
    final nameRegex = RegExp(r'^[a-zA-ZÀ-ÿ\s]+$');
    if (!nameRegex.hasMatch(name.trim())) {
      return 'O nome deve conter apenas letras e espaços.';
    }

    return null;
  }

  /// Valida se o email tem formato válido.
  ///
  /// [email] - String do email a ser validada
  ///
  /// Returns string de erro se inválido, null se válido
  String? _validateEmail(String? email) {
    if (email == null || email.isEmpty) {
      return 'Por favor, insira o email de contato do responsável.';
    }

    // Remove espaços em branco no início e fim
    final emailTrimmed = email.trim();

    // Verifica se contém pelo menos um @
    if (!emailTrimmed.contains('@')) {
      return 'Email deve conter o símbolo @.';
    }

    // Verifica se tem apenas um @
    if (emailTrimmed.split('@').length != 2) {
      return 'Email deve conter apenas um símbolo @.';
    }

    // Separa as partes antes e depois do @
    final parts = emailTrimmed.split('@');
    final localPart = parts[0];
    final domainPart = parts[1];

    // Valida parte local (antes do @)
    if (localPart.isEmpty) {
      return 'Email deve ter texto antes do @.';
    }

    // Valida parte do domínio (depois do @)
    if (domainPart.isEmpty) {
      return 'Email deve ter um domínio depois do @.';
    }

    // Verifica se o domínio contém pelo menos um ponto
    if (!domainPart.contains('.')) {
      return 'Domínio do email deve conter pelo menos um ponto.';
    }

    // Regex mais rigorosa para validação completa
    final emailRegex = RegExp(
      r"^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?(?:\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?)*$",
    );

    if (!emailRegex.hasMatch(emailTrimmed)) {
      return 'Por favor, insira um email válido (ex: usuario@exemplo.com).';
    }

    // Validação adicional: verifica se a extensão do domínio tem pelo menos 2 caracteres
    final domainParts = domainPart.split('.');
    final lastPart = domainParts.last;

    if (lastPart.length < 2) {
      return 'Extensão do domínio deve ter pelo menos 2 caracteres.';
    }

    return null;
  }

  /// Extrai um nome legível do caminho do arquivo de questionário.
  ///
  /// [path] - Caminho completo do arquivo (ex: 'assets/surveys/lapan_q7.json')
  ///
  /// Returns o nome do arquivo sem extensão (ex: 'lapan_q7')
  ///
  /// Exemplo:
  /// ```dart
  /// getSurveyNameFromPath('assets/surveys/lapan_q7.json') // retorna 'lapan_q7'
  /// ```
  String getSurveyNameFromPath(String path) {
    return path.split('/').last.replaceAll('.json', '');
  }

  /// Navega para a página de detalhes do questionário selecionado.
  ///
  /// [surveyPath] - Caminho do questionário selecionado
  ///
  /// Só executa se há um questionário válido selecionado.
  void _showSurveyDetails(String surveyPath) {
    final displayName = getSurveyNameFromPath(surveyPath);

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SurveyDetailsPage(
          surveyPath: surveyPath,
          surveyDisplayName: displayName,
        ),
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

    // Validação específica do nome (além da validação do formulário)
    final nameText = _screenerNameController.text.trim();
    if (nameText.isEmpty) {
      validationErrors.add('Preencha o nome do responsável');
    } else if (nameText.length < 5) {
      validationErrors.add('O nome deve ter pelo menos 5 caracteres');
    }

    // Validação específica do email (além da validação do formulário)
    final emailText = _screenerContactController.text.trim();
    if (emailText.isEmpty) {
      validationErrors.add('Preencha o email do responsável');
    }

    // Verificação se há questionário selecionado
    final settings = Provider.of<AppSettings>(context, listen: false);
    if (settings.selectedSurveyPath == null) {
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
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 4),
          ),
        );
      } else {
        // Se apenas os campos de texto não passaram na validação
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Por favor, corrija os erros nos campos destacados.'),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 3),
          ),
        );
      }
      return;
    }

    // Se tudo estiver válido, mostra mensagem de sucesso e fecha
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Configurações salvas com sucesso!'),
        backgroundColor: Colors.green,
        duration: Duration(seconds: 2),
      ),
    );

    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AppSettings>(
      builder: (context, settings, child) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('Configurações'),
            backgroundColor: Colors.amber,
          ),
          body: Form(
            key: _formKey,
            child: ListView(
              padding: const EdgeInsets.all(24.0),
              children: [
                // Campo para o nome do responsável
                TextFormField(
                  controller: _screenerNameController,
                  decoration: const InputDecoration(
                    labelText: 'Nome do Responsável (Screener) *',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.person),
                    helperText:
                        'Nome do profissional que aplicará o questionário',
                  ),
                  textCapitalization: TextCapitalization.words,
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  inputFormatters: [
                    // Permite apenas letras, espaços e acentos
                    FilteringTextInputFormatter.allow(RegExp(r'[a-zA-ZÀ-ÿ\s]')),
                  ],
                  validator: _validateName,
                  onChanged: (value) {
                    // Atualiza o nome nas configurações em tempo real
                    settings.setScreenerName(value);
                  },
                ),
                const SizedBox(height: 16),

                // Campo para o contato do responsável
                TextFormField(
                  controller: _screenerContactController,
                  decoration: const InputDecoration(
                    labelText: 'Email do Responsável *',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.email),
                    helperText:
                        'Email do profissional (ex: usuario@exemplo.com)',
                  ),
                  keyboardType: TextInputType.emailAddress,
                  autocorrect: false,
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  validator: _validateEmail,
                  onChanged: (value) {
                    // Remove espaços automaticamente durante a digitação
                    final trimmedValue = value.replaceAll(' ', '');
                    if (trimmedValue != value) {
                      _screenerContactController.value = TextEditingValue(
                        text: trimmedValue,
                        selection: TextSelection.collapsed(
                          offset: trimmedValue.length,
                        ),
                      );
                    }
                    // Atualiza o contato nas configurações em tempo real
                    settings.setScreenerContact(trimmedValue);
                  },
                ),
                const SizedBox(height: 24),

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
                if (settings.availableSurveyPaths.isEmpty)
                  const Center(child: CircularProgressIndicator())
                else
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          DropdownButtonFormField<String>(
                            value: settings.selectedSurveyPath,
                            isExpanded: true,
                            decoration: const InputDecoration(
                              labelText: 'Questionário Selecionado *',
                              border: OutlineInputBorder(),
                              contentPadding: EdgeInsets.symmetric(
                                horizontal: 16.0,
                              ),
                            ),
                            items: settings.availableSurveyPaths.map((path) {
                              return DropdownMenuItem(
                                value: path,
                                child: Text(getSurveyNameFromPath(path)),
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
                            onPressed: settings.selectedSurveyPath != null
                                ? () => _showSurveyDetails(
                                    settings.selectedSurveyPath!,
                                  )
                                : null,
                            icon: const Icon(Icons.info_outline),
                            label: const Text('Ver Detalhes do Questionário'),
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              backgroundColor:
                                  settings.selectedSurveyPath != null
                                  ? Colors.amber.shade200
                                  : Colors.grey,
                              foregroundColor: Colors.black,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                const SizedBox(height: 32),

                // Informações de status
                Card(
                  color: Colors.amber.shade50,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.info_outline,
                              color: Colors.amber.shade700,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Status das Configurações',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        _buildStatusItem(
                          'Responsável configurado:',
                          settings.screenerName.isNotEmpty
                              ? settings.screenerName
                              : 'Não configurado',
                          settings.screenerName.isNotEmpty,
                        ),
                        _buildStatusItem(
                          'Email configurado:',
                          settings.screenerContact.isNotEmpty
                              ? settings.screenerContact
                              : 'Não configurado',
                          settings.screenerContact.isNotEmpty,
                        ),
                        _buildStatusItem(
                          'Questionário selecionado:',
                          settings.selectedSurveyPath != null
                              ? getSurveyNameFromPath(
                                  settings.selectedSurveyPath!,
                                )
                              : 'Nenhum selecionado',
                          settings.selectedSurveyPath != null,
                        ),
                        _buildStatusItem(
                          'Questionários disponíveis:',
                          '${settings.availableSurveyPaths.length} encontrado(s)',
                          settings.availableSurveyPaths.isNotEmpty,
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
                    color: Colors.blue.shade50,
                    border: Border.all(color: Colors.blue.shade200),
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.info_outline,
                        color: Colors.blue.shade700,
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
                    backgroundColor: Colors.amber,
                    foregroundColor: Colors.black,
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
            ),
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
            color: isValid ? Colors.green : Colors.red,
            size: 20,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: RichText(
              text: TextSpan(
                style: const TextStyle(fontSize: 14, color: Colors.black87),
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
