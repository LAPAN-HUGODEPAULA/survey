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
    this.loadMedicationCatalog,
    this.persistManualMedication,
    this.submitted = false,
    this.validator,
    this.labelText = 'Nome do(s) medicamento(s)',
  });

  final List<String> selectedMedications;
  final ValueChanged<String> onMedicationAdded;
  final ValueChanged<String> onMedicationRemoved;
  final DsMedicationSearchFn searchMedications;
  final Future<List<String>> Function()? loadMedicationCatalog;
  final Future<void> Function(String medication)? persistManualMedication;
  final bool submitted;
  final String? Function()? validator;
  final String labelText;

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
  final Set<String> _pendingManualPersist = <String>{};

  List<String> _suggestions = const <String>[];
  List<String> _catalog = const <String>[];
  bool _isCatalogLoading = false;
  bool _isSearchingRemote = false;
  bool _catalogLoaded = false;
  bool _hasPersistError = false;

  @override
  void didUpdateWidget(covariant DsMedicationAutocompleteField oldWidget) {
    super.didUpdateWidget(oldWidget);
    _unverifiedMedications.removeWhere(
      (item) => !widget.selectedMedications.contains(item),
    );
    _pendingManualPersist.removeWhere(
      (item) => !widget.selectedMedications.contains(item),
    );
  }

  @override
  void dispose() {
    unawaited(_flushPendingManualPersist());
    _queryController.dispose();
    _focusNode.removeListener(_handleFocusChanged);
    _focusNode.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(_handleFocusChanged);
  }

  void _handleFocusChanged() {
    if (_focusNode.hasFocus) {
      unawaited(_ensureCatalogLoaded());
      return;
    }
    unawaited(_flushPendingManualPersist());
  }

  Future<void> _ensureCatalogLoaded() async {
    if (_catalogLoaded || _isCatalogLoading) {
      return;
    }
    setState(() {
      _isCatalogLoading = true;
      _hasPersistError = false;
    });
    try {
      final loader = widget.loadMedicationCatalog;
      final catalog = loader != null
          ? await loader()
          : await widget.searchMedications('a');
      if (!mounted) {
        return;
      }
      final normalizedCatalog = catalog
          .where((item) => item.trim().isNotEmpty)
          .map((item) => item.trim())
          .toList(growable: false);
      setState(() {
        _catalog = normalizedCatalog;
        _catalogLoaded = true;
        _isCatalogLoading = false;
      });
    } catch (_) {
      if (!mounted) {
        return;
      }
      setState(() {
        _catalog = const <String>[];
        _catalogLoaded = true;
        _isCatalogLoading = false;
      });
    }
  }

  void _handleQueryChanged(String value) {
    final query = value.trim().toLowerCase();
    if (query.isEmpty) {
      setState(() {
        _suggestions = const <String>[];
      });
      return;
    }

    if (widget.loadMedicationCatalog == null) {
      if (query.length < 3) {
        setState(() {
          _suggestions = const <String>[];
          _isSearchingRemote = false;
        });
        return;
      }
      unawaited(_loadRemoteSuggestions(query));
      return;
    }

    final localSuggestions = _catalog
        .where(
          (item) => item.toLowerCase().contains(query),
        )
        .where(
          (item) => !widget.selectedMedications.any(
            (selected) => selected.toLowerCase() == item.toLowerCase(),
          ),
        )
        .toList(growable: false);

    setState(() {
      _suggestions = localSuggestions;
    });
  }

  Future<void> _loadRemoteSuggestions(String query) async {
    setState(() {
      _isSearchingRemote = true;
    });
    try {
      final response = await widget.searchMedications(query);
      if (!mounted) {
        return;
      }
      setState(() {
        _suggestions = response
            .where((item) => item.trim().isNotEmpty)
            .where(
              (item) => !widget.selectedMedications.any(
                (selected) => selected.toLowerCase() == item.toLowerCase(),
              ),
            )
            .toList(growable: false);
        _isSearchingRemote = false;
      });
    } catch (_) {
      if (!mounted) {
        return;
      }
      setState(() {
        _suggestions = const <String>[];
        _isSearchingRemote = false;
      });
    }
  }

  Iterable<String> _buildOptions(TextEditingValue value) {
    final query = value.text.trim();
    if (query.isEmpty) {
      return const <String>[];
    }
    if (_isCatalogLoading || _isSearchingRemote) {
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
      _pendingManualPersist.add(value);
    }
    widget.onMedicationAdded(value);
    _queryController.clear();
    setState(() {
      _suggestions = const <String>[];
      _hasPersistError = false;
      if (!_catalog.any((item) => item.toLowerCase() == value.toLowerCase())) {
        _catalog = <String>[..._catalog, value];
      }
    });
  }

  void _removeMedication(String medication) {
    _unverifiedMedications.remove(medication);
    _pendingManualPersist.remove(medication);
    widget.onMedicationRemoved(medication);
  }

  Future<void> _flushPendingManualPersist() async {
    if (_pendingManualPersist.isEmpty || widget.persistManualMedication == null) {
      return;
    }

    final pending = List<String>.from(_pendingManualPersist);
    var hasError = false;
    for (final medication in pending) {
      try {
        await widget.persistManualMedication!(medication);
        _pendingManualPersist.remove(medication);
      } catch (_) {
        hasError = true;
      }
    }

    if (!mounted) {
      return;
    }
    setState(() {
      _hasPersistError = hasError;
    });
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
                          title: Text('Carregando catálogo de medicamentos...'),
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
        if (_hasPersistError) ...[
          const SizedBox(height: 8),
          TextButton.icon(
            onPressed: _flushPendingManualPersist,
            icon: const Icon(Icons.refresh),
            label: const Text(
              'Falha ao sincronizar medicação manual. Tocar para tentar novamente.',
            ),
          ),
        ],
      ],
    );
  }
}
