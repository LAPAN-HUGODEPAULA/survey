import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class DsValidatedTextFormField extends StatefulWidget {
  const DsValidatedTextFormField({
    super.key,
    this.controller,
    this.initialValue,
    this.focusNode,
    this.decoration = const InputDecoration(),
    this.keyboardType,
    this.textInputAction,
    this.textCapitalization = TextCapitalization.none,
    this.inputFormatters,
    this.minLines,
    this.maxLines = 1,
    this.enabled = true,
    this.readOnly = false,
    this.autofillHints,
    this.enableSuggestions = true,
    this.autocorrect = true,
    this.obscureText = false,
    this.validator,
    this.onChanged,
    this.onFieldSubmitted,
    this.submitted = false,
  }) : assert(
          controller == null || initialValue == null,
          'Use controller ou initialValue, mas não ambos.',
        );

  final TextEditingController? controller;
  final String? initialValue;
  final FocusNode? focusNode;
  final InputDecoration decoration;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final TextCapitalization textCapitalization;
  final List<TextInputFormatter>? inputFormatters;
  final int? minLines;
  final int? maxLines;
  final bool enabled;
  final bool readOnly;
  final Iterable<String>? autofillHints;
  final bool enableSuggestions;
  final bool autocorrect;
  final bool obscureText;
  final String? Function(String?)? validator;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onFieldSubmitted;
  final bool submitted;

  @override
  State<DsValidatedTextFormField> createState() =>
      _DsValidatedTextFormFieldState();
}

class _DsValidatedTextFormFieldState extends State<DsValidatedTextFormField> {
  final GlobalKey<FormFieldState<String>> _fieldKey =
      GlobalKey<FormFieldState<String>>();

  late FocusNode _focusNode;
  bool _ownsFocusNode = false;
  bool _validationActive = false;

  @override
  void initState() {
    super.initState();
    _bindFocusNode(widget.focusNode);
    _validationActive = widget.submitted;
  }

  @override
  void didUpdateWidget(covariant DsValidatedTextFormField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.focusNode != widget.focusNode) {
      _unbindFocusNode();
      _bindFocusNode(widget.focusNode);
    }
    if (widget.submitted && !_validationActive) {
      _activateValidation(validateNow: true);
    }
  }

  @override
  void dispose() {
    _unbindFocusNode();
    super.dispose();
  }

  void _bindFocusNode(FocusNode? focusNode) {
    if (focusNode == null) {
      _focusNode = FocusNode();
      _ownsFocusNode = true;
    } else {
      _focusNode = focusNode;
      _ownsFocusNode = false;
    }
    _focusNode.addListener(_handleFocusChange);
  }

  void _unbindFocusNode() {
    _focusNode.removeListener(_handleFocusChange);
    if (_ownsFocusNode) {
      _focusNode.dispose();
    }
  }

  void _handleFocusChange() {
    if (_focusNode.hasFocus || _validationActive) {
      return;
    }
    _activateValidation(validateNow: true);
  }

  void _activateValidation({required bool validateNow}) {
    setState(() {
      _validationActive = true;
    });

    if (validateNow) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _fieldKey.currentState?.validate();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      key: _fieldKey,
      controller: widget.controller,
      initialValue: widget.initialValue,
      focusNode: _focusNode,
      decoration: widget.decoration,
      keyboardType: widget.keyboardType,
      textInputAction: widget.textInputAction,
      textCapitalization: widget.textCapitalization,
      inputFormatters: widget.inputFormatters,
      minLines: widget.minLines,
      maxLines: widget.maxLines,
      enabled: widget.enabled,
      readOnly: widget.readOnly,
      autofillHints: widget.autofillHints,
      enableSuggestions: widget.enableSuggestions,
      autocorrect: widget.autocorrect,
      obscureText: widget.obscureText,
      validator: widget.validator,
      autovalidateMode: _validationActive
          ? AutovalidateMode.onUserInteraction
          : AutovalidateMode.disabled,
      onChanged: widget.onChanged,
      onFieldSubmitted: widget.onFieldSubmitted,
    );
  }
}

class DsValidatedDropdownButtonFormField<T> extends StatefulWidget {
  const DsValidatedDropdownButtonFormField({
    super.key,
    required this.items,
    this.initialValue,
    this.onChanged,
    this.validator,
    this.decoration = const InputDecoration(),
    this.focusNode,
    this.submitted = false,
    this.enabled = true,
  });

  final List<DropdownMenuItem<T>> items;
  final T? initialValue;
  final ValueChanged<T?>? onChanged;
  final String? Function(T?)? validator;
  final InputDecoration decoration;
  final FocusNode? focusNode;
  final bool submitted;
  final bool enabled;

  @override
  State<DsValidatedDropdownButtonFormField<T>> createState() =>
      _DsValidatedDropdownButtonFormFieldState<T>();
}

class _DsValidatedDropdownButtonFormFieldState<T>
    extends State<DsValidatedDropdownButtonFormField<T>> {
  final GlobalKey<FormFieldState<T>> _fieldKey = GlobalKey<FormFieldState<T>>();

  late FocusNode _focusNode;
  bool _ownsFocusNode = false;
  bool _validationActive = false;

  @override
  void initState() {
    super.initState();
    _bindFocusNode(widget.focusNode);
    _validationActive = widget.submitted;
  }

  @override
  void didUpdateWidget(
    covariant DsValidatedDropdownButtonFormField<T> oldWidget,
  ) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.focusNode != widget.focusNode) {
      _unbindFocusNode();
      _bindFocusNode(widget.focusNode);
    }
    if (widget.submitted && !_validationActive) {
      _activateValidation(validateNow: true);
    }
  }

  @override
  void dispose() {
    _unbindFocusNode();
    super.dispose();
  }

  void _bindFocusNode(FocusNode? focusNode) {
    if (focusNode == null) {
      _focusNode = FocusNode();
      _ownsFocusNode = true;
    } else {
      _focusNode = focusNode;
      _ownsFocusNode = false;
    }
    _focusNode.addListener(_handleFocusChange);
  }

  void _unbindFocusNode() {
    _focusNode.removeListener(_handleFocusChange);
    if (_ownsFocusNode) {
      _focusNode.dispose();
    }
  }

  void _handleFocusChange() {
    if (_focusNode.hasFocus || _validationActive) {
      return;
    }
    _activateValidation(validateNow: true);
  }

  void _activateValidation({required bool validateNow}) {
    setState(() {
      _validationActive = true;
    });

    if (validateNow) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _fieldKey.currentState?.validate();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<T>(
      key: _fieldKey,
      focusNode: _focusNode,
      initialValue: widget.initialValue,
      decoration: widget.decoration,
      items: widget.items,
      validator: widget.validator,
      autovalidateMode: _validationActive
          ? AutovalidateMode.onUserInteraction
          : AutovalidateMode.disabled,
      onChanged: !widget.enabled
          ? null
          : (value) {
              if (!_validationActive && widget.submitted) {
                _activateValidation(validateNow: false);
              }
              widget.onChanged?.call(value);
            },
    );
  }
}
