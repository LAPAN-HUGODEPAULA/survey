/// Página de coleta de informações demográficas do usuário.
///
/// Esta página é responsável por coletar dados pessoais do usuário antes
/// do início do questionário principal, incluindo informações como nome,
/// data de nascimento, sexo, raça, diagnósticos prévios, medicamentos
/// e email de contato.

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:survey_app/instructions_page.dart';
import 'package:survey_app/providers/app_settings.dart';
import 'package:survey_app/settings_page.dart';

/// Página que coleta informações demográficas do usuário.
///
/// Esta é a primeira página da aplicação, onde são coletados dados pessoais
/// básicos do participante da pesquisa. Os dados incluem informações
/// demográficas padrão, informações médicas relevantes e contato.
///
/// A página valida todos os campos obrigatórios antes de permitir
/// o avanço para as instruções do questionário.
class DemographicsPage extends StatefulWidget {
  const DemographicsPage({super.key});

  @override
  State<DemographicsPage> createState() => _DemographicsPageState();
}

/// Estado da página de informações demográficas.
///
/// Gerencia todos os controladores de formulário, validação de dados
/// e carregamento dinâmico de diagnósticos médicos.
class _DemographicsPageState extends State<DemographicsPage> {
  /// Chave global para validação do formulário
  final _formKey = GlobalKey<FormState>();

  // Controladores dos campos de texto
  /// Controlador para o campo nome completo
  final _nameController = TextEditingController();

  /// Controlador para o campo email de contato
  final _emailController = TextEditingController();

  /// Controlador para o campo data de nascimento
  final _dobController = TextEditingController();

  /// Controlador para o campo nome do medicamento
  final _medicationNameController = TextEditingController();

  // Variáveis de seleção única
  /// Sexo selecionado pelo usuário
  String? _selectedSex;

  /// Raça/etnia selecionada pelo usuário
  String? _selectedRace;

  /// Indica se o usuário usa medicamento psiquiátrico
  String? _usesMedication;

  // Variáveis para diagnósticos dinâmicos
  /// Lista de diagnósticos carregados do arquivo JSON
  List<String> _diagnosesList = [];

  /// Map que controla quais diagnósticos foram selecionados
  Map<String, bool> _selectedDiagnoses = {};

  /// Indica se os diagnósticos ainda estão sendo carregados
  bool _isLoadingDiagnoses = true;

  /// Indica se o formulário já foi submetido pelo menos uma vez
  bool _hasAttemptedSubmit = false;

  /// Flag para controlar se os dados foram limpos recentemente
  bool _lastPatientDataWasEmpty = true;

  @override
  void initState() {
    super.initState();
    _loadDiagnoses();
    // Verifica se precisa limpar os campos baseado no provider
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkIfShouldClearFields();
    });
  }

  /// Verifica se os campos devem ser limpos baseado no estado do provider.
  ///
  /// Se todos os dados do paciente estão vazios no provider, limpa os campos locais.
  void _checkIfShouldClearFields() {
    final settings = Provider.of<AppSettings>(context, listen: false);

    final patientDataIsEmpty =
        settings.patientName.isEmpty &&
        settings.patientEmail.isEmpty &&
        settings.patientBirthDate.isEmpty;

    // Se os dados estavam preenchidos antes e agora estão vazios, limpa os campos
    if (!_lastPatientDataWasEmpty && patientDataIsEmpty) {
      _clearAllFields();
    }

    _lastPatientDataWasEmpty = patientDataIsEmpty;
  }

  /// Método chamado quando os dados do provider mudam
  void _onProviderDataChanged(AppSettings settings) {
    final patientDataIsEmpty =
        settings.patientName.isEmpty &&
        settings.patientEmail.isEmpty &&
        settings.patientBirthDate.isEmpty;

    // Se os dados mudaram de preenchidos para vazios, limpa os campos
    if (!_lastPatientDataWasEmpty && patientDataIsEmpty) {
      _clearAllFields();
    }

    _lastPatientDataWasEmpty = patientDataIsEmpty;
  }

  /// Limpa todos os campos do formulário e reseta o estado.
  void _clearAllFields() {
    setState(() {
      // Limpa controladores de texto
      _nameController.clear();
      _emailController.clear();
      _dobController.clear();
      _medicationNameController.clear();

      // Reseta seleções
      _selectedSex = null;
      _selectedRace = null;
      _usesMedication = null;

      // Reseta diagnósticos selecionados
      _selectedDiagnoses = {
        for (String diagnosis in _diagnosesList) diagnosis: false,
      };

      // Reseta flag de tentativa de submissão
      _hasAttemptedSubmit = false;
    });

    // Limpa os erros de validação do formulário
    _formKey.currentState?.reset();
  }

  /// Carrega a lista de diagnósticos do arquivo assets/data/diagnoses.json.
  ///
  /// Popula [_diagnosesList] com os diagnósticos disponíveis e inicializa
  /// [_selectedDiagnoses] com todos os valores como false.
  ///
  /// O arquivo JSON tem a estrutura: {"diagnoses": ["diagnosis1", "diagnosis2", ...]}
  ///
  /// Em caso de erro, define [_isLoadingDiagnoses] como false e exibe erro no console.
  Future<void> _loadDiagnoses() async {
    try {
      final String response = await rootBundle.loadString(
        'assets/data/diagnoses.json',
      );
      final Map<String, dynamic> data = json.decode(response);

      // Extrai a lista de diagnósticos da propriedade "diagnoses"
      final List<dynamic> diagnosesList = data['diagnoses'] ?? [];

      setState(() {
        _diagnosesList = diagnosesList.cast<String>();
        // Inicializa todos os diagnósticos como não selecionados
        _selectedDiagnoses = {
          for (String diagnosis in _diagnosesList) diagnosis: false,
        };
        _isLoadingDiagnoses = false;
      });
    } catch (e) {
      setState(() {
        _isLoadingDiagnoses = false;
      });

      // Opcional: mostrar erro para o usuário
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao carregar diagnósticos: $e'),
            backgroundColor: Colors.orange,
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _dobController.dispose();
    _medicationNameController.dispose();
    super.dispose();
  }

  /// Valida o nome completo do usuário.
  ///
  /// [name] - String do nome a ser validada
  ///
  /// Returns string de erro se inválido, null se válido
  String? _validateName(String? name) {
    if (name == null || name.isEmpty) {
      return 'Por favor, insira seu nome completo.';
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
      return 'Por favor, insira seu email de contato.';
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

  /// Valida e formata a data de nascimento.
  ///
  /// [dateText] - String da data a ser validada
  ///
  /// Returns string de erro se inválida, null se válida
  String? _validateDate(String? dateText) {
    if (dateText == null || dateText.isEmpty) {
      return 'Por favor, insira sua data de nascimento.';
    }

    // Regex para validar formato DD/MM/YYYY
    final dateRegex = RegExp(r'^\d{2}/\d{2}/\d{4}$');
    if (!dateRegex.hasMatch(dateText)) {
      return 'Use o formato DD/MM/AAAA (ex: 15/03/1990).';
    }

    try {
      final parts = dateText.split('/');
      final day = int.parse(parts[0]);
      final month = int.parse(parts[1]);
      final year = int.parse(parts[2]);

      // Validações básicas de data
      if (day < 1 || day > 31) {
        return 'Dia deve estar entre 01 e 31.';
      }
      if (month < 1 || month > 12) {
        return 'Mês deve estar entre 01 e 12.';
      }
      if (year < 1900 || year > DateTime.now().year) {
        return 'Ano deve estar entre 1900 e ${DateTime.now().year}.';
      }

      // Tenta criar a data para validar se é uma data real
      final date = DateTime(year, month, day);
      if (date.day != day || date.month != month || date.year != year) {
        return 'Data inválida.';
      }

      // Verifica se não é uma data futura
      if (date.isAfter(DateTime.now())) {
        return 'A data de nascimento não pode ser futura.';
      }

      return null;
    } catch (e) {
      return 'Data inválida. Use o formato DD/MM/AAAA.';
    }
  }

  /// Valida a lista de medicamentos separados por vírgula.
  ///
  /// [medicationList] - String com medicamentos separados por vírgula
  ///
  /// Returns string de erro se inválido, null se válido
  String? _validateMedicationList(String? medicationList) {
    if (medicationList == null || medicationList.isEmpty) {
      return 'Por favor, informe o(s) nome(s) do(s) medicamento(s).';
    }

    // Divide por vírgula e remove espaços em branco
    final medications = medicationList
        .split(',')
        .map((med) => med.trim())
        .where((med) => med.isNotEmpty)
        .toList();

    if (medications.isEmpty) {
      return 'Por favor, informe pelo menos um medicamento válido.';
    }

    // Valida cada medicamento individualmente
    for (final medication in medications) {
      // Regex para validar apenas letras, números, espaços e hífen
      final medicationRegex = RegExp(r'^[a-zA-Z0-9À-ÿ\s\-]+$');
      if (!medicationRegex.hasMatch(medication)) {
        return 'Medicamento "$medication" contém caracteres inválidos.\nUse apenas letras, números, espaços e hífen.';
      }

      // Verifica se o nome não é muito curto
      if (medication.length < 2) {
        return 'Medicamento "$medication" deve ter pelo menos 2 caracteres.';
      }

      // Verifica se não é muito longo
      if (medication.length > 50) {
        return 'Medicamento "$medication" deve ter no máximo 50 caracteres.';
      }
    }

    return null;
  }

  /// Formata a entrada de data automaticamente durante a digitação.
  ///
  /// [value] - Valor atual do campo
  void _formatDateInput(String value) {
    // Remove todos os caracteres que não sejam dígitos
    String digitsOnly = value.replaceAll(RegExp(r'[^\d]'), '');

    // Limita a 8 dígitos (DDMMAAAA)
    if (digitsOnly.length > 8) {
      digitsOnly = digitsOnly.substring(0, 8);
    }

    // Aplica a formatação DD/MM/AAAA
    String formatted = '';
    for (int i = 0; i < digitsOnly.length; i++) {
      if (i == 2 || i == 4) {
        formatted += '/';
      }
      formatted += digitsOnly[i];
    }

    // Atualiza o campo apenas se o valor formatado for diferente
    if (formatted != _dobController.text) {
      _dobController.value = TextEditingValue(
        text: formatted,
        selection: TextSelection.collapsed(offset: formatted.length),
      );
    }
  }

  /// Submete o formulário após validação completa.
  ///
  /// Valida todos os campos obrigatórios e, se válidos, navega para
  /// a página de instruções com o questionário selecionado.
  ///
  /// Exibe um SnackBar de erro se nenhum questionário estiver selecionado
  /// ou se algum campo obrigatório não estiver preenchido.
  void _submitForm() {
    // Marca que o usuário tentou submeter o formulário
    setState(() {
      _hasAttemptedSubmit = true;
    });

    // Primeiro, valida os campos do formulário
    bool isFormValid = _formKey.currentState!.validate();

    // Lista para armazenar erros de validação adicional
    List<String> validationErrors = [];

    // Validação adicional dos campos obrigatórios que não são TextFormField
    if (_selectedSex == null) {
      validationErrors.add('Selecione o sexo');
    }

    if (_selectedRace == null) {
      validationErrors.add('Selecione a raça/etnia');
    }

    // Adiciona validação para medicamento psiquiátrico
    if (_usesMedication == null) {
      validationErrors.add('Informe se faz uso de medicamento psiquiátrico');
    }

    // Se há erros de validação adicional, mostra uma mensagem
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
      return;
    }

    // Só prossegue se o formulário estiver válido E todos os campos obrigatórios estiverem preenchidos
    if (isFormValid) {
      final settings = Provider.of<AppSettings>(context, listen: false);
      final surveyPath = settings.selectedSurveyPath;

      if (surveyPath == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Nenhum questionário selecionado. Verifique as configurações.',
            ),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      // Diagnósticos selecionados
      final selectedDiagnoses = _selectedDiagnoses.entries
          .where((entry) => entry.value == true)
          .map((entry) => entry.key)
          .toList();

      // Processa lista de medicamentos
      String medicationString = '';
      if (_usesMedication == 'Sim' &&
          _medicationNameController.text.trim().isNotEmpty) {
        // Divide por vírgula, limpa espaços e reconstrói como string
        final medications = _medicationNameController.text
            .split(',')
            .map((med) => med.trim())
            .where((med) => med.isNotEmpty)
            .toList();
        medicationString = medications.join(', ');
      }

      // Salva os dados demográficos no provider
      settings.setPatientData(
        name: _nameController.text.trim(),
        email: _emailController.text.trim(),
        birthDate: _dobController.text,
        gender: _selectedSex!,
        ethnicity: _selectedRace!,
        medication: medicationString,
        diagnoses: selectedDiagnoses,
      );

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => InstructionsPage(surveyPath: surveyPath),
        ),
      );
    } else {
      // Se o formulário não é válido, mostra mensagem geral
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor, corrija os erros nos campos destacados.'),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 3),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Usa um Consumer para ouvir as mudanças no AppSettings
    return Consumer<AppSettings>(
      builder: (context, settings, child) {
        // Verifica se precisa limpar campos quando o provider muda
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _onProviderDataChanged(settings);
        });

        return Scaffold(
          appBar: AppBar(
            // Atualiza o título dinamicamente com base no questionário selecionado
            title: Text(
              settings.selectedSurveyPath != null
                  ? 'Informações Demográficas: ${settings.selectedSurveyName}'
                  : 'Informações Demográficas - <selecionar questionário>',
              overflow: TextOverflow.ellipsis,
            ),
            backgroundColor: Colors.amber,
            actions: [
              IconButton(
                icon: const Icon(Icons.settings),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const SettingsPage(),
                    ),
                  ).then((_) {
                    // Garante que a UI seja atualizada ao voltar das configurações
                    setState(() {});
                  });
                },
              ),
            ],
          ),
          // O corpo do Scaffold (child) não precisa ser reconstruído quando o provider mudar,
          // o que melhora a performance.
          body: child,
        );
      },
      // O child é o corpo do Scaffold, que não será reconstruído.
      child: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 600),
          child: Form(
            key: _formKey,
            child: ListView(
              padding: const EdgeInsets.all(24.0),
              children: [
                // Campo Nome Completo
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: 'Nome Completo *',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.person),
                    helperText: 'Mínimo 5 caracteres, apenas letras',
                  ),
                  textCapitalization: TextCapitalization.words,
                  inputFormatters: [
                    // Permite apenas letras, espaços e acentos
                    FilteringTextInputFormatter.allow(RegExp(r'[a-zA-ZÀ-ÿ\s]')),
                  ],
                  validator: _validateName,
                ),
                const SizedBox(height: 16),

                // Campo Email de Contato
                TextFormField(
                  controller: _emailController,
                  decoration: const InputDecoration(
                    labelText: 'Email de Contato *',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.email),
                    helperText:
                        'Usado para envio dos resultados (ex: usuario@exemplo.com)',
                  ),
                  keyboardType: TextInputType.emailAddress,
                  autocorrect: false,
                  autovalidateMode: AutovalidateMode
                      .onUserInteraction, // Adiciona validação em tempo real
                  validator: _validateEmail,
                  // Adiciona formatação automática para remover espaços
                  onChanged: (value) {
                    // Remove espaços automaticamente durante a digitação
                    final trimmedValue = value.replaceAll(' ', '');
                    if (trimmedValue != value) {
                      _emailController.value = TextEditingValue(
                        text: trimmedValue,
                        selection: TextSelection.collapsed(
                          offset: trimmedValue.length,
                        ),
                      );
                    }
                  },
                ),
                const SizedBox(height: 16),

                // Campo Data de Nascimento
                TextFormField(
                  controller: _dobController,
                  decoration: const InputDecoration(
                    labelText: 'Data de Nascimento *',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.cake),
                    suffixIcon: Icon(Icons.calendar_today),
                    helperText: 'DD/MM/AAAA - Digite ou clique no calendário',
                  ),
                  keyboardType: TextInputType.datetime,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(
                      10,
                    ), // DD/MM/AAAA = 10 chars
                  ],
                  onChanged: _formatDateInput,
                  onTap: () async {
                    // Permite tanto digitação quanto seleção por calendário
                    DateTime? pickedDate = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now().subtract(
                        const Duration(days: 365 * 25),
                      ), // 25 anos atrás como padrão
                      firstDate: DateTime(1900),
                      lastDate: DateTime.now(),
                      locale: const Locale('pt', 'BR'),
                    );
                    if (pickedDate != null) {
                      setState(() {
                        _dobController.text =
                            "${pickedDate.day.toString().padLeft(2, '0')}/${pickedDate.month.toString().padLeft(2, '0')}/${pickedDate.year}";
                      });
                    }
                  },
                  validator: _validateDate,
                ),
                const SizedBox(height: 16),

                // Campo Sexo
                DropdownButtonFormField<String>(
                  decoration: const InputDecoration(
                    labelText: 'Sexo *',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.wc),
                  ),
                  value: _selectedSex,
                  items: ['Feminino', 'Masculino', 'Outro']
                      .map(
                        (label) =>
                            DropdownMenuItem(value: label, child: Text(label)),
                      )
                      .toList(),
                  onChanged: (value) => setState(() => _selectedSex = value),
                  validator: (value) =>
                      value == null ? 'Campo obrigatório' : null,
                ),
                const SizedBox(height: 16),

                // Campo Raça/Etnia
                DropdownButtonFormField<String>(
                  decoration: const InputDecoration(
                    labelText: 'Raça/Etnia *',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.people),
                  ),
                  value: _selectedRace,
                  items:
                      [
                            'Branca',
                            'Preta',
                            'Parda',
                            'Amarela',
                            'Indígena',
                            'Outra',
                          ]
                          .map(
                            (label) => DropdownMenuItem(
                              value: label,
                              child: Text(label),
                            ),
                          )
                          .toList(),
                  onChanged: (value) => setState(() => _selectedRace = value),
                  validator: (value) =>
                      value == null ? 'Campo obrigatório' : null,
                ),
                const SizedBox(height: 24),

                // Campo de diagnósticos dinâmico
                const Text(
                  'Diagnóstico prévio (selecione se aplicável):',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 8),
                _isLoadingDiagnoses
                    ? const Center(child: CircularProgressIndicator())
                    : _diagnosesList.isEmpty
                    ? Container(
                        padding: const EdgeInsets.all(16.0),
                        decoration: BoxDecoration(
                          color: Colors.orange.shade50,
                          border: Border.all(color: Colors.orange.shade200),
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.warning_amber_outlined,
                              color: Colors.orange.shade700,
                            ),
                            const SizedBox(width: 8),
                            const Expanded(
                              child: Text(
                                'Nenhum diagnóstico foi carregado. Verifique o arquivo de dados.',
                                style: TextStyle(fontSize: 14),
                              ),
                            ),
                          ],
                        ),
                      )
                    : Wrap(
                        spacing: 8.0,
                        runSpacing: 4.0,
                        children: _diagnosesList.map((diagnosis) {
                          return ChoiceChip(
                            label: Text(diagnosis),
                            selected: _selectedDiagnoses[diagnosis] ?? false,
                            onSelected: (bool selected) {
                              setState(() {
                                _selectedDiagnoses[diagnosis] = selected;
                              });
                            },
                            selectedColor: Colors.amber.shade200,
                          );
                        }).toList(),
                      ),
                const SizedBox(height: 24),

                // Campo de medicação condicional com validação visual
                Container(
                  decoration: BoxDecoration(
                    border: (_hasAttemptedSubmit && _usesMedication == null)
                        ? Border.all(color: Colors.red.shade300, width: 1)
                        : null,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  padding: (_hasAttemptedSubmit && _usesMedication == null)
                      ? const EdgeInsets.all(8.0)
                      : EdgeInsets.zero,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Faz uso de medicamento psiquiátrico? *',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color:
                              (_hasAttemptedSubmit && _usesMedication == null)
                              ? Colors.red
                              : null,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Column(
                        children: [
                          RadioListTile<String>(
                            title: const Text('Sim'),
                            value: 'Sim',
                            groupValue: _usesMedication,
                            onChanged: (value) =>
                                setState(() => _usesMedication = value),
                            contentPadding: EdgeInsets.zero,
                          ),
                          RadioListTile<String>(
                            title: const Text('Não'),
                            value: 'Não',
                            groupValue: _usesMedication,
                            onChanged: (value) {
                              setState(() {
                                _usesMedication = value;
                                if (value == 'Não') {
                                  _medicationNameController.clear();
                                }
                              });
                            },
                            contentPadding: EdgeInsets.zero,
                          ),
                        ],
                      ),

                      // Campo condicional para nome do medicamento
                      if (_usesMedication == 'Sim')
                        Column(
                          children: [
                            const SizedBox(height: 16),
                            TextFormField(
                              controller: _medicationNameController,
                              decoration: const InputDecoration(
                                labelText: 'Nome dos Medicamentos',
                                border: OutlineInputBorder(),
                                prefixIcon: Icon(Icons.medical_services),
                                helperText:
                                    'Separe múltiplos medicamentos por vírgula (ex: Litio, Fluoxetina)',
                              ),
                              textCapitalization: TextCapitalization.words,
                              maxLines: 1,
                              inputFormatters: [
                                // Permite letras, números, espaços, vírgulas e hífen
                                FilteringTextInputFormatter.allow(
                                  RegExp(r'[a-zA-Z0-9À-ÿ\s\-,]'),
                                ),
                              ],
                              validator: _usesMedication == 'Sim'
                                  ? _validateMedicationList
                                  : null,
                            ),
                          ],
                        ),
                    ],
                  ),
                ),

                const SizedBox(height: 32),

                // Informação sobre privacidade
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
                        Icons.privacy_tip_outlined,
                        color: Colors.blue.shade700,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      const Expanded(
                        child: Text(
                          'Suas informações são confidenciais e serão usadas apenas para fins de pesquisa.',
                          style: TextStyle(fontSize: 14),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // Botão de submissão
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
                    'Continuar para Instruções',
                    style: TextStyle(fontSize: 18),
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
