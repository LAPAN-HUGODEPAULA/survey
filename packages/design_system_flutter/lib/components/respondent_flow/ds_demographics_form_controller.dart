import 'package:design_system_flutter/components/forms/ds_form_validators.dart';
import 'package:design_system_flutter/components/respondent_flow/ds_demographics_catalog_loader.dart';
import 'package:design_system_flutter/components/respondent_flow/respondent_flow_models.dart';
import 'package:design_system_flutter/widgets/ds_feedback.dart';
import 'package:flutter/material.dart';

typedef DsAdditionalValidationItemsBuilder = List<DsValidationSummaryItem>
    Function();

class DsDemographicsSubmission {
  const DsDemographicsSubmission({
    required this.name,
    required this.email,
    required this.birthDate,
    required this.gender,
    required this.ethnicity,
    required this.educationLevel,
    required this.profession,
    required this.medication,
    required this.diagnoses,
  });

  final String name;
  final String email;
  final String birthDate;
  final String gender;
  final String ethnicity;
  final String educationLevel;
  final String profession;
  final List<String> medication;
  final List<String> diagnoses;
}

class DsDemographicsFormController extends ChangeNotifier {
  DsDemographicsFormController({
    DsDemographicsCatalogLoader? catalogLoader,
    required this.usesMedicationRequiredMessage,
    this.additionalValidationItemsBuilder,
    this.requireIdentityFields = true,
    this.requireSelectionFields = true,
    this.requireMedicationChoice = true,
    this.requireMedicationListWhenUsingMedication = true,
  }) : _catalogLoader = catalogLoader ?? DsDemographicsCatalogLoader() {
    nameController.addListener(_syncValidationSummary);
    emailController.addListener(_syncValidationSummary);
    birthDateController.addListener(_syncValidationSummary);
    professionController.addListener(_syncValidationSummary);
  }

  static const DsDemographicsCatalogs _emptyCatalogs = DsDemographicsCatalogs(
    diagnoses: <String>[],
    educationLevels: <String>[],
    professions: <String>[],
  );

  final DsDemographicsCatalogLoader _catalogLoader;
  final String usesMedicationRequiredMessage;
  final DsAdditionalValidationItemsBuilder? additionalValidationItemsBuilder;
  final bool requireIdentityFields;
  final bool requireSelectionFields;
  final bool requireMedicationChoice;
  final bool requireMedicationListWhenUsingMedication;

  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController birthDateController = TextEditingController();
  final TextEditingController professionController = TextEditingController();

  DsDemographicsCatalogs? _catalogs;
  String? _catalogError;
  bool _isLoadingCatalogs = true;
  bool _hasSubmitted = false;
  List<DsValidationSummaryItem> _validationItems =
      const <DsValidationSummaryItem>[];
  String? _selectedSex;
  String? _selectedRace;
  String? _selectedEducationLevel;
  String? _usesMedication;
  Map<String, bool> _selectedDiagnoses = <String, bool>{};
  final List<String> _selectedMedications = <String>[];

  DsDemographicsCatalogs get catalogs => _catalogs ?? _emptyCatalogs;
  String? get catalogError => _catalogError;
  bool get isLoadingCatalogs => _isLoadingCatalogs;
  bool get hasSubmitted => _hasSubmitted;
  List<DsValidationSummaryItem> get validationItems => _validationItems;
  String? get selectedSex => _selectedSex;
  String? get selectedRace => _selectedRace;
  String? get selectedEducationLevel => _selectedEducationLevel;
  String? get usesMedication => _usesMedication;
  List<String> get selectedMedications =>
      List<String>.unmodifiable(_selectedMedications);
  Map<String, bool> get selectedDiagnoses =>
      Map<String, bool>.unmodifiable(_selectedDiagnoses);
  String? get usesMedicationErrorText =>
      _hasSubmitted ? _validateUsesMedication() : null;

  Future<void> loadInitialData() async {
    _isLoadingCatalogs = true;
    _catalogError = null;
    notifyListeners();

    try {
      final catalogs = await _catalogLoader.loadAll();
      _catalogs = catalogs;
      _selectedDiagnoses = <String, bool>{
        for (final String diagnosis in catalogs.diagnoses) diagnosis: false,
      };
    } catch (error) {
      _catalogError = 'Erro ao carregar dados do formulário: $error';
    } finally {
      _isLoadingCatalogs = false;
      notifyListeners();
    }
  }

  void reset() {
    nameController.clear();
    emailController.clear();
    birthDateController.clear();
    professionController.clear();
    _selectedMedications.clear();
    _selectedSex = null;
    _selectedRace = null;
    _selectedEducationLevel = null;
    _usesMedication = null;
    _hasSubmitted = false;
    _validationItems = const <DsValidationSummaryItem>[];
    _selectedDiagnoses = <String, bool>{
      for (final String diagnosis in catalogs.diagnoses) diagnosis: false,
    };
    notifyListeners();
  }

  void updateSex(String? value) {
    _selectedSex = value;
    _refreshValidationSummary();
  }

  void updateRace(String? value) {
    _selectedRace = value;
    _refreshValidationSummary();
  }

  void updateEducationLevel(String? value) {
    _selectedEducationLevel = value;
    _refreshValidationSummary();
  }

  void updateUsesMedication(String? value) {
    _usesMedication = value;
    if (value != 'Sim') {
      _selectedMedications.clear();
    }
    _refreshValidationSummary();
  }

  void addMedication(String medication) {
    final value = medication.trim();
    if (value.isEmpty) {
      return;
    }
    final exists = _selectedMedications.any(
      (item) => item.toLowerCase() == value.toLowerCase(),
    );
    if (exists) {
      return;
    }
    _selectedMedications.add(value);
    _refreshValidationSummary();
  }

  void removeMedication(String medication) {
    _selectedMedications.removeWhere(
      (item) => item.toLowerCase() == medication.toLowerCase(),
    );
    _refreshValidationSummary();
  }

  void updateDiagnosis(String diagnosis, bool isSelected) {
    _selectedDiagnoses[diagnosis] = isSelected;
    notifyListeners();
  }

  DsDemographicsSubmission? submit(GlobalKey<FormState> formKey) {
    final isFormValid = formKey.currentState!.validate();
    final validationItems = _buildValidationItems();

    if (!isFormValid || validationItems.isNotEmpty) {
      _hasSubmitted = true;
      _validationItems = validationItems;
      notifyListeners();
      return null;
    }

    _hasSubmitted = false;
    _validationItems = const <DsValidationSummaryItem>[];
    notifyListeners();

    return DsDemographicsSubmission(
      name: nameController.text.trim(),
      email: emailController.text.trim(),
      birthDate: birthDateController.text,
      gender: _selectedSex ?? '',
      ethnicity: _selectedRace ?? '',
      educationLevel: _selectedEducationLevel ?? '',
      profession: professionController.text.trim(),
      medication: _usesMedication == 'Sim'
          ? List<String>.unmodifiable(_selectedMedications)
          : const <String>[],
      diagnoses: _selectedDiagnoses.entries
          .where((MapEntry<String, bool> entry) => entry.value)
          .map((MapEntry<String, bool> entry) => entry.key)
          .toList(growable: false),
    );
  }

  String? _validateUsesMedication() {
    if (!requireMedicationChoice) {
      return null;
    }
    if (_usesMedication == null) {
      return usesMedicationRequiredMessage;
    }
    return null;
  }

  void _refreshValidationSummary() {
    if (!_hasSubmitted) {
      notifyListeners();
      return;
    }
    _validationItems = _buildValidationItems();
    notifyListeners();
  }

  void _syncValidationSummary() {
    if (!_hasSubmitted) {
      return;
    }
    _validationItems = _buildValidationItems();
    notifyListeners();
  }

  List<DsValidationSummaryItem> _buildValidationItems() {
    final items = <DsValidationSummaryItem>[];

    void addItem(String label, String? message) {
      if (message == null || message.trim().isEmpty) {
        return;
      }
      items.add(DsValidationSummaryItem(label: label, message: message));
    }

    if (requireIdentityFields) {
      addItem(
        'Nome completo',
        DsFormValidators.validatePersonName(nameController.text,
            context: 'patient'),
      );
      addItem(
        'E-mail',
        DsFormValidators.validateEmail(emailController.text,
            context: 'patient'),
      );
      addItem(
        'Data de nascimento',
        DsFormValidators.validateBirthDate(birthDateController.text),
      );
    }
    if (requireSelectionFields) {
      addItem(
        'Sexo',
        DsFormValidators.validateDropdownSelection(_selectedSex, 'Sexo'),
      );
      addItem(
        'Raça/Etnia',
        DsFormValidators.validateDropdownSelection(_selectedRace, 'Raça/Etnia'),
      );
      addItem(
        'Grau de escolaridade',
        DsFormValidators.validateDropdownSelection(
          _selectedEducationLevel,
          'Grau de Escolaridade',
        ),
      );
    }
    addItem('Uso de medicação psiquiátrica', _validateUsesMedication());
    if (requireMedicationListWhenUsingMedication && _usesMedication == 'Sim') {
      addItem(
        'Nome do(s) medicamento(s)',
        _selectedMedications.isEmpty ? 'Campo obrigatório' : null,
      );
    }

    final additionalItems = additionalValidationItemsBuilder?.call();
    if (additionalItems != null && additionalItems.isNotEmpty) {
      items.addAll(additionalItems);
    }

    return items;
  }

  @override
  void dispose() {
    nameController.removeListener(_syncValidationSummary);
    emailController.removeListener(_syncValidationSummary);
    birthDateController.removeListener(_syncValidationSummary);
    professionController.removeListener(_syncValidationSummary);
    nameController.dispose();
    emailController.dispose();
    birthDateController.dispose();
    professionController.dispose();
    super.dispose();
  }
}
