import 'package:design_system_flutter/components/forms/ds_form_validators.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

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
        TextFormField(
          controller: nameController,
          decoration: InputDecoration(labelText: nameLabel),
          validator: (value) =>
              DsFormValidators.validatePersonName(value, context: 'patient'),
        ),
        if (showEmail && emailController != null) ...[
          const SizedBox(height: 16),
          TextFormField(
            controller: emailController,
            decoration: InputDecoration(labelText: emailLabel),
            validator: (value) =>
                DsFormValidators.validateEmail(value, context: 'patient'),
          ),
        ],
        if (showBirthDate && birthDateController != null) ...[
          const SizedBox(height: 16),
          TextFormField(
            controller: birthDateController,
            decoration: InputDecoration(
              labelText: birthDateLabel,
              hintText: birthDateHint,
            ),
            keyboardType: TextInputType.datetime,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              LengthLimitingTextInputFormatter(8),
            ],
            onChanged: onBirthDateChanged,
            validator: DsFormValidators.validateBirthDate,
          ),
        ],
        if (showMedicalRecordId && medicalRecordIdController != null) ...[
          const SizedBox(height: 16),
          TextFormField(
            controller: medicalRecordIdController,
            decoration: InputDecoration(labelText: medicalRecordIdLabel),
            validator: DsFormValidators.validateMedicalRecordId,
          ),
        ],
        if (continueLabel != null && onContinue != null) ...[
          const SizedBox(height: 32),
          ElevatedButton(
            onPressed: onContinue,
            child: Text(continueLabel!),
          ),
        ],
      ],
    );
  }
}
