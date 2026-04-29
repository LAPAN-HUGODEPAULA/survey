import 'dart:async';

import 'package:design_system_flutter/components/forms/ds_validated_fields.dart';
import 'package:flutter/material.dart';

typedef DsMedicationSearchFn = Future<List<String>> Function(String query);

class DsMedicationAutocompleteField extends StatefulWidget {
  const DsMedicationAutocompleteField({
    super.key,
    required this.selectedMedications,
    required this.onMedicationAdded,
    required this.onMedicationRemoved,
    required this.searchMedications,
    this.submitted = false,
    this.validator,
    this.labelText = 'Nome do(s) medicamento(s)',
    this.debounceDuration = const Duration(milliseconds: 300),
  });

  final List<String> selectedMedications;
  final ValueChanged<String> onMedicationAdded;
  final ValueChanged<String> onMedicationRemoved;
  final DsMedicationSearchFn searchMedications;
  final bool submitted;
  final String? Function()? validator;
  final String labelText;
  final Duration debounceDuration;

  @override
  State<DsMedicationAutocompleteField> createState() =>
      _DsMedicationAutocompleteFieldState();
}

class _DsMedicationAutocompleteFieldState
    extends State<DsMedicationAutocompleteField> {
  static const String _loadingOption = '__loading__';
  static const String _manualOption = '__manual__';

  final TextEditingController _queryController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  final Set<String> _unverifiedMedications = <String>{};

  Timer? _debounceTimer;
  List<String> _suggestions = const <String>[];
  String _activeQuery = '';
  bool _isLoading = false;

  @override
  void didUpdateWidget(covariant DsMedicationAutocompleteField oldWidget) {
    super.didUpdateWidget(oldWidget);
    _unverifiedMedications.removeWhere(
      (item) => !widget.selectedMedications.contains(item),
    );
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _queryController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _handleQueryChanged(String value) {
    final query = value.trim();
    _activeQuery = query;
    _debounceTimer?.cancel();
    if (query.length < 3) {
      setState(() {
        _isLoading = false;
        _suggestions = const <String>[];
      });
      return;
    }
    _debounceTimer = Timer(widget.debounceDuration, () {
      _loadSuggestions(query);
    });
  }

  Future<void> _loadSuggestions(String query) async {
    setState(() {
      _isLoading = true;
    });
    try {
      final results = await widget.searchMedications(query);
      if (!mounted || query != _activeQuery) {
        return;
      }
      final filtered = results
          .where((item) => item.trim().isNotEmpty)
          .where((item) => !widget.selectedMedications.contains(item))
          .toList(growable: false);
      setState(() {
        _suggestions = filtered;
        _isLoading = false;
      });
    } catch (_) {
      if (!mounted || query != _activeQuery) {
        return;
      }
      setState(() {
        _suggestions = const <String>[];
        _isLoading = false;
      });
    }
  }

  Iterable<String> _buildOptions(TextEditingValue value) {
    final query = value.text.trim();
    if (query.length < 3) {
      return const <String>[];
    }
    if (_isLoading) {
      return const <String>[_loadingOption];
    }
    if (_suggestions.isNotEmpty) {
      return _suggestions;
    }
    return const <String>[_manualOption];
  }

  void _addMedication(String rawValue, {required bool verified}) {
    final value = rawValue.trim();
    if (value.isEmpty) {
      return;
    }
    final exists = widget.selectedMedications.any(
      (item) => item.toLowerCase() == value.toLowerCase(),
    );
    if (exists) {
      _queryController.clear();
      return;
    }
    if (verified) {
      _unverifiedMedications.remove(value);
    } else {
      _unverifiedMedications.add(value);
    }
    widget.onMedicationAdded(value);
    _queryController.clear();
    setState(() {
      _activeQuery = '';
      _suggestions = const <String>[];
      _isLoading = false;
    });
  }

  void _removeMedication(String medication) {
    _unverifiedMedications.remove(medication);
    widget.onMedicationRemoved(medication);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RawAutocomplete<String>(
          textEditingController: _queryController,
          focusNode: _focusNode,
          optionsBuilder: _buildOptions,
          displayStringForOption: (option) => option,
          onSelected: (selection) {
            if (selection == _loadingOption || selection == _manualOption) {
              return;
            }
            _addMedication(selection, verified: true);
          },
          fieldViewBuilder: (
            BuildContext context,
            TextEditingController textEditingController,
            FocusNode focusNode,
            VoidCallback onFieldSubmitted,
          ) {
            return DsValidatedTextFormField(
              controller: textEditingController,
              focusNode: focusNode,
              submitted: widget.submitted,
              decoration: InputDecoration(labelText: widget.labelText),
              onChanged: _handleQueryChanged,
              validator: (_) => widget.validator?.call(),
            );
          },
          optionsViewBuilder: (
            BuildContext context,
            AutocompleteOnSelected<String> onSelected,
            Iterable<String> options,
          ) {
            final values = options.toList(growable: false);
            return Align(
              alignment: Alignment.topLeft,
              child: Material(
                elevation: 6,
                borderRadius: BorderRadius.circular(10),
                child: ConstrainedBox(
                  constraints:
                      const BoxConstraints(maxHeight: 220, minWidth: 280),
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    itemCount: values.length,
                    itemBuilder: (context, index) {
                      final option = values[index];
                      if (option == _loadingOption) {
                        return const ListTile(
                          leading: SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                          title: Text('Buscando medicamentos...'),
                        );
                      }
                      if (option == _manualOption) {
                        final manualLabel = _queryController.text.trim();
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Padding(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 8),
                              child: Text('Nenhum medicamento encontrado.'),
                            ),
                            TextButton.icon(
                              onPressed: manualLabel.isEmpty
                                  ? null
                                  : () => _addMedication(
                                        manualLabel,
                                        verified: false,
                                      ),
                              icon: const Icon(Icons.add),
                              label: const Text('Adicionar manualmente'),
                            ),
                          ],
                        );
                      }
                      return ListTile(
                        title: Text(option),
                        onTap: () => onSelected(option),
                      );
                    },
                  ),
                ),
              ),
            );
          },
        ),
        if (widget.selectedMedications.isNotEmpty) ...[
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: widget.selectedMedications.map((medication) {
              final isUnverified = _unverifiedMedications.contains(medication);
              return InputChip(
                label: Text(medication),
                onDeleted: () => _removeMedication(medication),
                deleteIcon: const Icon(Icons.close),
                avatar: isUnverified
                    ? Icon(
                        Icons.edit_note_outlined,
                        size: 18,
                        color: theme.colorScheme.primary,
                      )
                    : null,
                side: isUnverified
                    ? BorderSide(color: theme.colorScheme.primary, width: 1.3)
                    : null,
                backgroundColor: isUnverified
                    ? theme.colorScheme.surfaceContainerHighest
                    : theme.colorScheme.surface,
              );
            }).toList(growable: false),
          ),
        ],
      ],
    );
  }
}
