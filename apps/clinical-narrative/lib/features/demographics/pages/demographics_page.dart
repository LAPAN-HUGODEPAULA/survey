/// Collects the patient identity required before the chat workflow starts.
library;

import 'package:clinical_narrative_app/core/navigation/app_navigator.dart';
import 'package:clinical_narrative_app/core/providers/app_settings.dart';
import 'package:design_system_flutter/widgets.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class DemographicsPage extends StatefulWidget {
  const DemographicsPage({super.key});

  @override
  State<DemographicsPage> createState() => _DemographicsPageState();
}

class _DemographicsPageState extends State<DemographicsPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _medicalRecordIdController =
      TextEditingController();
  bool _hasSubmitted = false;
  List<DsValidationSummaryItem> _validationItems =
      const <DsValidationSummaryItem>[];

  @override
  void initState() {
    super.initState();
    _nameController.addListener(_syncValidationSummary);
    _medicalRecordIdController.addListener(_syncValidationSummary);
  }

  @override
  void dispose() {
    _nameController.removeListener(_syncValidationSummary);
    _medicalRecordIdController.removeListener(_syncValidationSummary);
    _nameController.dispose();
    _medicalRecordIdController.dispose();
    super.dispose();
  }

  void _syncValidationSummary() {
    if (!_hasSubmitted || !mounted) {
      return;
    }
    setState(() {
      _validationItems = _buildValidationItems();
    });
  }

  List<DsValidationSummaryItem> _buildValidationItems() {
    final items = <DsValidationSummaryItem>[];

    void addItem(String label, String? message) {
      if (message == null || message.trim().isEmpty) {
        return;
      }
      items.add(DsValidationSummaryItem(label: label, message: message));
    }

    addItem(
      'Nome completo',
      DsFormValidators.validatePersonName(
        _nameController.text,
        context: 'patient',
      ),
    );
    addItem(
      'Número do prontuário',
      DsFormValidators.validateMedicalRecordId(_medicalRecordIdController.text),
    );

    return items;
  }

  void _submitForm() {
    final isFormValid = _formKey.currentState!.validate();
    final validationItems = _buildValidationItems();
    if (!isFormValid || validationItems.isNotEmpty) {
      setState(() {
        _hasSubmitted = true;
        _validationItems = validationItems;
      });
      return;
    }

    setState(() {
      _hasSubmitted = false;
      _validationItems = const <DsValidationSummaryItem>[];
    });

    Provider.of<AppSettings>(context, listen: false).setPatientData(
      name: _nameController.text.trim(),
      medicalRecordId: _medicalRecordIdController.text.trim(),
    );
    AppNavigator.toChat(context);
  }

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<AppSettings>();
    return DsScaffold(
      title: 'Informações do paciente',
      subtitle:
          'Registre a identificação básica antes de iniciar a conversa clínica.',
      userName: settings.screenerDisplayName,
      showAmbientGreeting: true,
      scrollable: true,
      body: Form(
        key: _formKey,
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 720),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (_validationItems.isNotEmpty) ...[
                  DsValidationSummary(
                    items: _validationItems,
                    description:
                        'Corrija os itens abaixo e os campos destacados antes de continuar.',
                  ),
                  const SizedBox(height: 16),
                ],
                DsSection(
                  eyebrow: 'Abertura',
                  title: 'Identificação inicial',
                  subtitle:
                      'Esses dados acompanham a conversa e o prontuário gerado.',
                  child: DsPatientIdentitySection(
                    nameController: _nameController,
                    medicalRecordIdController: _medicalRecordIdController,
                    showMedicalRecordId: true,
                    continueLabel: 'Continuar para o chat',
                    onContinue: _submitForm,
                    submitted: _hasSubmitted,
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
