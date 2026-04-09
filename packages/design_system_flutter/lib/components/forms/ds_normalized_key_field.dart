import 'package:flutter/material.dart';

class DsKeyFieldSupport {
  DsKeyFieldSupport._();

  static final RegExp _allowedKeyPattern = RegExp(r'^[a-z0-9:_-]+$');

  static String normalizeKeyField(String value) {
    return value.trim().toLowerCase();
  }

  static String normalizeTextField(String value) {
    return value.trim();
  }

  static String? validateRequired(String? value) {
    if (normalizeTextField(value ?? '').isEmpty) {
      return 'Campo obrigatório';
    }
    return null;
  }

  static String? validateKeyField(String? value) {
    final normalized = normalizeKeyField(value ?? '');
    if (normalized.isEmpty) {
      return 'Campo obrigatório';
    }
    if (!_allowedKeyPattern.hasMatch(normalized)) {
      return 'Use letras, números, ":" , "_" ou "-".';
    }
    return null;
  }
}

class DsNormalizedKeyField extends StatelessWidget {
  const DsNormalizedKeyField({
    super.key,
    required this.controller,
    required this.label,
    this.readOnly = false,
    this.helperText,
  });

  final TextEditingController controller;
  final String label;
  final bool readOnly;
  final String? helperText;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      readOnly: readOnly,
      decoration: InputDecoration(
        labelText: label,
        helperText: helperText,
      ),
      validator: DsKeyFieldSupport.validateKeyField,
    );
  }
}
