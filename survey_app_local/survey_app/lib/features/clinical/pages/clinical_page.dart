library;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:survey_app/core/navigation/app_navigator.dart';
import 'package:survey_app/core/providers/app_settings.dart';

/// Página de dados clínicos opcionais.
///
/// Coleta quatro campos de texto multilinha opcionais:
/// - Histórico médico
/// - Histórico familiar
/// - Dados sociais
/// - Histórico de medicação
class ClinicalPage extends StatefulWidget {
  final String surveyPath;

  const ClinicalPage({super.key, required this.surveyPath});

  @override
  State<ClinicalPage> createState() => _ClinicalPageState();
}

class _ClinicalPageState extends State<ClinicalPage> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _medicalHistoryController =
      TextEditingController();
  final TextEditingController _familyHistoryController =
      TextEditingController();
  final TextEditingController _socialDataController = TextEditingController();
  final TextEditingController _medicationHistoryController =
      TextEditingController();

  @override
  void initState() {
    super.initState();
    // Pré-carrega dados existentes (se houver)
    final clinical = Provider.of<AppSettings>(
      context,
      listen: false,
    ).clinicalData;
    _medicalHistoryController.text = clinical.medicalHistory;
    _familyHistoryController.text = clinical.familyHistory;
    _socialDataController.text = clinical.socialData;
    _medicationHistoryController.text = clinical.medicationHistory;
  }

  @override
  void dispose() {
    _medicalHistoryController.dispose();
    _familyHistoryController.dispose();
    _socialDataController.dispose();
    _medicationHistoryController.dispose();
    super.dispose();
  }

  void _goNext() {
    final settings = Provider.of<AppSettings>(context, listen: false);

    // Salva dados clínicos (todos opcionais)
    settings.setClinicalData(
      medicalHistory: _medicalHistoryController.text.trim(),
      familyHistory: _familyHistoryController.text.trim(),
      socialData: _socialDataController.text.trim(),
      medicationHistory: _medicationHistoryController.text.trim(),
    );

    // Avança para as instruções
    AppNavigator.toInstructions(context, surveyPath: widget.surveyPath);
  }

  Widget _buildMultilineField({
    required String label,
    required String hint,
    required TextEditingController controller,
    int minLines = 4,
    int maxLines = 8,
  }) {
    return TextFormField(
      controller: controller,
      minLines: minLines,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        hintText: 'Opcional — $hint',
        alignLabelWithHint: true,
        border: const OutlineInputBorder(),
        helperText: hint,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Dados Clínicos (opcional)')),
      body: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 700),
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: ListView(
              children: [
                _buildMultilineField(
                  label: 'Histórico médico',
                  hint:
                      'Lista de condições e diagnósticos prévios/atuais do paciente.',
                  controller: _medicalHistoryController,
                ),
                const SizedBox(height: 16),
                _buildMultilineField(
                  label: 'Histórico familiar',
                  hint:
                      'Informações de saúde de parentes biológicos (pais, irmãos, filhos).',
                  controller: _familyHistoryController,
                ),
                const SizedBox(height: 16),
                _buildMultilineField(
                  label: 'Dados sociais',
                  hint:
                      'Informações não clínicas que impactam a saúde (tabagismo, álcool, ocupação, moradia, etc.).',
                  controller: _socialDataController,
                ),
                const SizedBox(height: 16),
                _buildMultilineField(
                  label: 'Histórico de medicação',
                  hint:
                      'Lista de medicações atuais ou recentes, incluindo dose, frequência e via.',
                  controller: _medicationHistoryController,
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _goNext,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          backgroundColor: Colors.amber,
                          foregroundColor: Colors.black,
                        ),
                        child: const Text(
                          'Continuar para Instruções',
                          style: TextStyle(fontSize: 16),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
