import 'package:flutter/material.dart';
import 'package:design_system_flutter/widgets/ds_buttons.dart';

class DsAdminFormShell extends StatelessWidget {
  const DsAdminFormShell({
    super.key,
    required this.child,
    required this.onCancel,
    required this.onSave,
    this.isSaving = false,
    this.saveLabel = 'Salvar',
    this.cancelLabel = 'Cancelar',
  });

  final Widget child;
  final VoidCallback onCancel;
  final VoidCallback onSave;
  final bool isSaving;
  final String saveLabel;
  final String cancelLabel;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Spacer(),
              SizedBox(
                width: 140,
                child: DsOutlinedButton(
                  label: cancelLabel,
                  onPressed: isSaving ? null : onCancel,
                ),
              ),
              const SizedBox(width: 8),
              SizedBox(
                width: 140,
                child: DsFilledButton(
                  label: isSaving ? 'Salvando...' : saveLabel,
                  onPressed: isSaving ? null : onSave,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }
}
