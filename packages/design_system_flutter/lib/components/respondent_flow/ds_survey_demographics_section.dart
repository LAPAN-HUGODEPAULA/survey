import 'package:design_system_flutter/components/forms/ds_validated_fields.dart';
import 'package:design_system_flutter/components/forms/ds_form_validators.dart';
import 'package:design_system_flutter/components/forms/ds_medication_autocomplete_field.dart';
import 'package:design_system_flutter/components/respondent_flow/respondent_flow_models.dart';
import 'package:design_system_flutter/widgets/ds_buttons.dart';
import 'package:design_system_flutter/widgets/ds_chip.dart';
import 'package:design_system_flutter/widgets/ds_feedback.dart';
import 'package:flutter/material.dart';

class DsSurveyDemographicsSection extends StatelessWidget {
  const DsSurveyDemographicsSection({
    super.key,
    required this.catalogs,
    required this.professionController,
    required this.selectedMedications,
    required this.searchMedications,
    required this.onMedicationAdded,
    required this.onMedicationRemoved,
    required this.selectedDiagnoses,
    required this.selectedSex,
    required this.selectedRace,
    required this.selectedEducationLevel,
    required this.usesMedication,
    required this.onSexChanged,
    required this.onRaceChanged,
    required this.onEducationChanged,
    required this.onUsesMedicationChanged,
    required this.onDiagnosisChanged,
    this.continueLabel,
    this.onContinue,
    this.submitted = false,
    this.usesMedicationErrorText,
    this.requireSelectionFields = true,
    this.requireMedicationChoice = true,
    this.requireMedicationListWhenUsingMedication = true,
  });

  final DsDemographicsCatalogs catalogs;
  final TextEditingController professionController;
  final List<String> selectedMedications;
  final DsMedicationSearchFn searchMedications;
  final ValueChanged<String> onMedicationAdded;
  final ValueChanged<String> onMedicationRemoved;
  final Map<String, bool> selectedDiagnoses;
  final String? selectedSex;
  final String? selectedRace;
  final String? selectedEducationLevel;
  final String? usesMedication;
  final ValueChanged<String?> onSexChanged;
  final ValueChanged<String?> onRaceChanged;
  final ValueChanged<String?> onEducationChanged;
  final ValueChanged<String?> onUsesMedicationChanged;
  final void Function(String diagnosis, bool isSelected) onDiagnosisChanged;
  final String? continueLabel;
  final VoidCallback? onContinue;
  final bool submitted;
  final String? usesMedicationErrorText;
  final bool requireSelectionFields;
  final bool requireMedicationChoice;
  final bool requireMedicationListWhenUsingMedication;

  static const List<String> sexOptions = <String>[
    'Feminino',
    'Masculino',
    'Outro',
  ];

  static const List<String> raceOptions = <String>[
    'Branca',
    'Preta',
    'Parda',
    'Amarela',
    'Indígena',
    'Outra',
  ];

  static const List<String> medicationOptions = <String>['Sim', 'Não'];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        DsValidatedDropdownButtonFormField<String>(
          key: const ValueKey('sex'),
          submitted: submitted,
          initialValue: selectedSex,
          decoration: InputDecoration(
            labelText: requireSelectionFields ? 'Sexo *' : 'Sexo',
          ),
          items: sexOptions
              .map(
                (String option) => DropdownMenuItem<String>(
                  value: option,
                  child: Text(option),
                ),
              )
              .toList(),
          onChanged: onSexChanged,
          validator: (value) => requireSelectionFields
              ? DsFormValidators.validateDropdownSelection(value, 'Sexo')
              : null,
        ),
        const SizedBox(height: 16),
        DsValidatedDropdownButtonFormField<String>(
          key: const ValueKey('race'),
          submitted: submitted,
          initialValue: selectedRace,
          decoration: InputDecoration(
            labelText: requireSelectionFields ? 'Raça/Etnia *' : 'Raça/Etnia',
          ),
          items: raceOptions
              .map(
                (String option) => DropdownMenuItem<String>(
                  value: option,
                  child: Text(option),
                ),
              )
              .toList(),
          onChanged: onRaceChanged,
          validator: (value) => requireSelectionFields
              ? DsFormValidators.validateDropdownSelection(value, 'Raça/Etnia')
              : null,
        ),
        const SizedBox(height: 16),
        DsValidatedDropdownButtonFormField<String>(
          key: const ValueKey('education'),
          submitted: submitted,
          initialValue: selectedEducationLevel,
          decoration: InputDecoration(
            labelText: requireSelectionFields
                ? 'Grau de Escolaridade *'
                : 'Grau de Escolaridade',
          ),
          items: catalogs.educationLevels
              .map(
                (String option) => DropdownMenuItem<String>(
                  value: option,
                  child: Text(option),
                ),
              )
              .toList(),
          onChanged: onEducationChanged,
          validator: (value) => requireSelectionFields
              ? DsFormValidators.validateDropdownSelection(
                  value,
                  'Grau de Escolaridade',
                )
              : null,
        ),
        const SizedBox(height: 16),
        Autocomplete<String>(
          optionsBuilder: (TextEditingValue textEditingValue) {
            if (textEditingValue.text.isEmpty) {
              return const Iterable<String>.empty();
            }
            return catalogs.professions.where((String option) {
              return option.toLowerCase().contains(
                    textEditingValue.text.toLowerCase(),
                  );
            });
          },
          onSelected: (String selection) {
            professionController.text = selection;
          },
          fieldViewBuilder: (
            BuildContext context,
            TextEditingController controller,
            FocusNode focusNode,
            VoidCallback onFieldSubmitted,
          ) {
            return DsValidatedTextFormField(
              controller: professionController,
              focusNode: focusNode,
              submitted: submitted,
              textCapitalization: TextCapitalization.words,
              decoration: const InputDecoration(labelText: 'Profissão'),
              validator: (value) => DsFormValidators.validateProfession(value),
            );
          },
        ),
        const SizedBox(height: 24),
        const Text(
          'Informações de Saúde',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        const Text('Diagnósticos Prévios'),
        Wrap(
          spacing: 8,
          children: catalogs.diagnoses.map((String diagnosis) {
            return ChoiceChip(
              label: Text(diagnosis),
              selected: selectedDiagnoses[diagnosis] ?? false,
              onSelected: (bool selected) {
                onDiagnosisChanged(diagnosis, selected);
              },
            );
          }).toList(),
        ),
        const SizedBox(height: 24),
        Text(
          requireMedicationChoice
              ? 'Faz uso de medicamento psiquiátrico? *'
              : 'Faz uso de medicamento psiquiátrico?',
        ),
        if (usesMedicationErrorText != null) ...[
          const SizedBox(height: 8),
          DsInlineMessage(
            feedback: DsFeedbackMessage(
              severity: DsStatusType.error,
              title: 'Revise este campo',
              message: usesMedicationErrorText!,
            ),
          ),
          const SizedBox(height: 8),
        ],
        RadioGroup<String>(
          groupValue: usesMedication,
          onChanged: onUsesMedicationChanged,
          child: Row(
            children: medicationOptions.map((String option) {
              return Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Radio<String>(value: option),
                  Text(option),
                ],
              );
            }).toList(),
          ),
        ),
        if (usesMedication == 'Sim') ...[
          const SizedBox(height: 8),
          DsMedicationAutocompleteField(
            selectedMedications: selectedMedications,
            searchMedications: searchMedications,
            onMedicationAdded: onMedicationAdded,
            onMedicationRemoved: onMedicationRemoved,
            submitted: submitted,
            labelText: 'Nome do(s) medicamento(s)',
            validator: () {
              if (!requireMedicationListWhenUsingMedication ||
                  usesMedication != 'Sim') {
                return null;
              }
              return selectedMedications.isEmpty ? 'Campo obrigatório' : null;
            },
          ),
        ],
        if (continueLabel != null && onContinue != null) ...[
          const SizedBox(height: 32),
          DsFilledButton(
            label: continueLabel!,
            onPressed: onContinue,
          ),
        ],
      ],
    );
  }
}
