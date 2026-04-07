import 'package:design_system_flutter/components/forms/ds_form_formatters.dart';
import 'package:design_system_flutter/components/forms/ds_form_validators.dart';
import 'package:design_system_flutter/components/forms/ds_validated_fields.dart';
import 'package:design_system_flutter/widgets/ds_buttons.dart';
import 'package:flutter/material.dart';

class DsPatientIdentitySection extends StatelessWidget {
  const DsPatientIdentitySection({
    super.key,
    required this.nameController,
    this.emailController,
    this.birthDateController,
    this.medicalRecordIdController,
    this.onBirthDateChanged,
    this.continueLabel,
    this.onContinue,
    this.submitted = false,
    this.nameLabel = 'Nome Completo *',
    this.emailLabel = 'E-mail *',
    this.birthDateLabel = 'Data de Nascimento *',
    this.birthDateHint = 'DD/MM/AAAA',
    this.medicalRecordIdLabel = 'Número do prontuário *',
    this.showEmail = false,
    this.showBirthDate = false,
    this.showMedicalRecordId = false,
  });

  final TextEditingController nameController;
  final TextEditingController? emailController;
  final TextEditingController? birthDateController;
  final TextEditingController? medicalRecordIdController;
  final ValueChanged<String>? onBirthDateChanged;
  final String? continueLabel;
  final VoidCallback? onContinue;
  final bool submitted;
  final String nameLabel;
  final String emailLabel;
  final String birthDateLabel;
  final String birthDateHint;
  final String medicalRecordIdLabel;
  final bool showEmail;
  final bool showBirthDate;
  final bool showMedicalRecordId;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        DsValidatedTextFormField(
          controller: nameController,
          submitted: submitted,
          textCapitalization: TextCapitalization.words,
          decoration: InputDecoration(labelText: nameLabel),
          validator: (value) =>
              DsFormValidators.validatePersonName(value, context: 'patient'),
        ),
        if (showEmail && emailController != null) ...[
          const SizedBox(height: 16),
          DsValidatedTextFormField(
            controller: emailController,
            submitted: submitted,
            keyboardType: TextInputType.emailAddress,
            autofillHints: const [AutofillHints.email],
            decoration: InputDecoration(labelText: emailLabel),
            validator: (value) =>
                DsFormValidators.validateEmail(value, context: 'patient'),
          ),
        ],
        if (showBirthDate && birthDateController != null) ...[
          const SizedBox(height: 16),
          DsValidatedTextFormField(
            controller: birthDateController,
            submitted: submitted,
            decoration: InputDecoration(
              labelText: birthDateLabel,
              hintText: birthDateHint,
              helperText: 'Use o formato DD/MM/AAAA.',
            ),
            keyboardType: TextInputType.datetime,
            inputFormatters: DsFormFormatters.dateBr(),
            onChanged: onBirthDateChanged,
            validator: DsFormValidators.validateBirthDate,
          ),
        ],
        if (showMedicalRecordId && medicalRecordIdController != null) ...[
          const SizedBox(height: 16),
          DsValidatedTextFormField(
            controller: medicalRecordIdController,
            submitted: submitted,
            decoration: InputDecoration(labelText: medicalRecordIdLabel),
            validator: DsFormValidators.validateMedicalRecordId,
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
