/// Página de coleta de informações demográficas do usuário.
///
/// Esta página é responsável por coletar dados pessoais do usuário antes
/// do início do questionário principal, incluindo informações como nome,
/// data de nascimento, sexo, raça, diagnósticos prévios, medicamentos
/// e email de contato.
library;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:survey_app/core/providers/app_settings.dart';
import 'package:survey_app/core/navigation/app_navigator.dart';
import 'package:survey_app/core/services/demographics_data_service.dart';
import 'package:survey_app/core/utils/validator_sets.dart';
import 'package:survey_app/features/settings/pages/settings_page.dart';

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

  /// Controlador para o campo profissão
  final _professionController = TextEditingController();

  /// Controlador para o campo nome do medicamento
  final _medicationNameController = TextEditingController();

  // Variáveis de seleção única
  /// Sexo selecionado pelo usuário
  String? _selectedSex;

  /// Raça/etnia selecionada pelo usuário
  String? _selectedRace;

  /// Grau de escolaridade selecionado pelo usuário
  String? _selectedEducationLevel;

  /// Indica se o usuário usa medicamento psiquiátrico
  String? _usesMedication;

  // Variáveis para diagnósticos dinâmicos
  /// Lista de diagnósticos carregados do arquivo JSON
  List<String> _diagnosesList = [];

  /// Map que controla quais diagnósticos foram selecionados
  Map<String, bool> _selectedDiagnoses = {};

  /// Lista de níveis de escolaridade carregados do arquivo JSON
  List<String> _educationLevels = [];

  /// Indica se os diagnósticos ainda estão sendo carregados
  bool _isLoadingDiagnoses = true;

  /// Indica se os níveis de escolaridade ainda estão sendo carregados
  bool _isLoadingEducationLevels = true;

  /// Lista de profissões carregadas do arquivo JSON
  List<String> _professions = [];

  /// Indica se as profissões ainda estão sendo carregadas
  bool _isLoadingProfessions = true;

  /// Indica se o formulário já foi submetido pelo menos uma vez
  bool _hasAttemptedSubmit = false;

  /// Flag para controlar se os dados foram limpos recentemente
  bool _lastPatientDataWasEmpty = true;

  @override
  void initState() {
    super.initState();
    _loadAllDemographicsData();
    _professionController.addListener(() {
      setState(() {});
    });
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
        settings.patient.name.isEmpty &&
        settings.patient.email.isEmpty &&
        settings.patient.birthDate.isEmpty;

    // Se os dados estavam preenchidos antes e agora estão vazios, limpa os campos
    if (!_lastPatientDataWasEmpty && patientDataIsEmpty) {
      _clearAllFields();
    }

    _lastPatientDataWasEmpty = patientDataIsEmpty;
  }

  /// Método chamado quando os dados do provider mudam
  void _onProviderDataChanged(AppSettings settings) {
    final patientDataIsEmpty =
        settings.patient.name.isEmpty &&
        settings.patient.email.isEmpty &&
        settings.patient.birthDate.isEmpty;

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
      _professionController.clear();
      _medicationNameController.clear();

      // Reseta seleções
      _selectedSex = null;
      _selectedRace = null;
      _selectedEducationLevel = null;
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

  /// Carrega todos os dados demográficos usando o serviço centralizado.
  ///
  /// Este método substitui os antigos métodos individuais de carregamento
  /// e usa o DemographicsDataService para carregar todos os dados de uma vez.
  Future<void> _loadAllDemographicsData() async {
    try {
      final dataService = DemographicsDataService.instance;
      final data = await dataService.loadAllData();

      setState(() {
        _diagnosesList = data.diagnoses;
        _educationLevels = data.educationLevels;
        _professions = data.professions;

        // Inicializa todos os diagnósticos como não selecionados
        _selectedDiagnoses = {
          for (String diagnosis in _diagnosesList) diagnosis: false,
        };

        // Marca todos os dados como carregados
        _isLoadingDiagnoses = false;
        _isLoadingEducationLevels = false;
        _isLoadingProfessions = false;
      });
    } catch (e) {
      setState(() {
        // Em caso de erro, marca todos como não carregando
        _isLoadingDiagnoses = false;
        _isLoadingEducationLevels = false;
        _isLoadingProfessions = false;
      });

      // Mostra erro para o usuário
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao carregar dados do formulário: $e'),
            backgroundColor: Theme.of(context).colorScheme.error,
            duration: const Duration(seconds: 4),
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
    _professionController.dispose();
    _medicationNameController.dispose();
    super.dispose();
  }

  // Validation methods are now provided by ValidatorSets and FormValidators

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
      validationErrors.add('Raça/Etnia');
    }

    if (_selectedEducationLevel == null) {
      validationErrors.add('Grau de Escolaridade');
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
          backgroundColor: Theme.of(context).colorScheme.error,
          duration: const Duration(seconds: 4),
        ),
      );
      return;
    }

    // Só prossegue se o formulário estiver válido E todos os campos obrigatórios estiverem preenchidos
    if (isFormValid) {
      // Coleta os dados do formulário
      final settings = Provider.of<AppSettings>(context, listen: false);

      // Coleta os diagnósticos selecionados
      final selectedDiagnosesList = _selectedDiagnoses.entries
          .where((entry) => entry.value)
          .map((entry) => entry.key)
          .toList();

      // Atualiza o provider com os dados do paciente
      settings.setPatientData(
        name: _nameController.text.trim(),
        email: _emailController.text.trim(),
        birthDate: _dobController.text,
        gender: _selectedSex!,
        ethnicity: _selectedRace!,
        educationLevel: _selectedEducationLevel!,
        profession: _professionController.text.trim(),
        medication: _usesMedication == 'Sim'
            ? _medicationNameController.text.trim()
            : 'Não aplicável',
        diagnoses: selectedDiagnosesList,
      );

      // Navega para a nova página clínica antes das instruções
      AppNavigator.toClinical(
        context,
        surveyPath: settings.selectedSurveyPath!,
      );
    } else {
      // Se o formulário não for válido, exibe uma mensagem de erro geral
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
                    hintText: 'Digite seu nome completo',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.person),
                    helperText: 'Mínimo 5 caracteres, apenas letras',
                  ),
                  textCapitalization: TextCapitalization.words,
                  inputFormatters: [
                    // Permite apenas letras, espaços e acentos
                    FilteringTextInputFormatter.allow(RegExp(r'[a-zA-ZÀ-ÿ\s]')),
                  ],
                  validator: ValidatorSets.patientName,
                ),
                const SizedBox(height: 16),

                // Campo Email
                TextFormField(
                  controller: _emailController,
                  decoration: const InputDecoration(
                    labelText: 'Email *',
                    hintText: 'Digite seu email',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.email),
                    helperText:
                        'Usado para envio dos resultados (ex: usuario@exemplo.com)',
                  ),
                  keyboardType: TextInputType.emailAddress,
                  autocorrect: false,
                  autovalidateMode: AutovalidateMode
                      .onUserInteraction, // Adiciona validação em tempo real
                  validator: ValidatorSets.patientEmail,
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
                    hintText: 'DD/MM/AAAA',
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
                  validator: ValidatorSets.patientBirthDate,
                ),
                const SizedBox(height: 16),

                // Campo Sexo
                DropdownButtonFormField<String>(
                  value: _selectedSex,
                  decoration: InputDecoration(
                    labelText: 'Sexo *',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.wc),
                  ),
                  items: ['Feminino', 'Masculino', 'Outro']
                      .map(
                        (label) =>
                            DropdownMenuItem(value: label, child: Text(label)),
                      )
                      .toList(),
                  onChanged: (value) => setState(() => _selectedSex = value),
                  validator: ValidatorSets.genderSelection,
                ),
                const SizedBox(height: 16),

                // Campo Raça/Etnia
                DropdownButtonFormField<String>(
                  value: _selectedRace,
                  decoration: InputDecoration(
                    labelText: 'Raça/Etnia *',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.people),
                  ),
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
                  validator: ValidatorSets.raceSelection,
                ),
                const SizedBox(height: 16),

                // Campo de seleção para Grau de Escolaridade
                _isLoadingEducationLevels
                    ? const Center(child: CircularProgressIndicator())
                    : DropdownButtonFormField<String>(
                        value: _selectedEducationLevel,
                        decoration: const InputDecoration(
                          labelText: 'Grau de Escolaridade *',
                          border: OutlineInputBorder(),
                        ),
                        items: _educationLevels.map<DropdownMenuItem<String>>((
                          String value,
                        ) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          );
                        }).toList(),
                        onChanged: (String? newValue) {
                          setState(() {
                            _selectedEducationLevel = newValue;
                          });
                        },
                        validator: ValidatorSets.educationLevelSelection,
                      ),

                const SizedBox(height: 16),

                // Campo de texto para Profissão com Autocomplete
                _isLoadingProfessions
                    ? const Center(child: CircularProgressIndicator())
                    : Autocomplete<String>(
                        optionsBuilder: (TextEditingValue textEditingValue) {
                          if (textEditingValue.text.isEmpty) {
                            return const Iterable<String>.empty();
                          }
                          return _professions.where((String option) {
                            return option.toLowerCase().contains(
                              textEditingValue.text.toLowerCase(),
                            );
                          });
                        },
                        onSelected: (String selection) {
                          _professionController.text = selection;
                        },
                        fieldViewBuilder:
                            (
                              BuildContext context,
                              TextEditingController fieldTextEditingController,
                              FocusNode fieldFocusNode,
                              VoidCallback onFieldSubmitted,
                            ) {
                              return TextFormField(
                                controller: _professionController,
                                focusNode: fieldFocusNode,
                                decoration: const InputDecoration(
                                  labelText: 'Profissão',
                                  border: OutlineInputBorder(),
                                  hintText: 'Ex: Estudante, Engenheiro, etc.',
                                ),
                                validator: ValidatorSets.patientProfession,
                              );
                            },
                      ),

                const SizedBox(height: 24),

                // Título da seção de saúde
                Text(
                  'Informações de Saúde',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.amber.shade800,
                  ),
                ),

                const SizedBox(height: 16),

                // Seção de Diagnósticos
                const Text(
                  'Diagnósticos Prévios',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
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
                                  ? ValidatorSets.medicationList
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
