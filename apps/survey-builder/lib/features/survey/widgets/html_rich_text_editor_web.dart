import 'dart:js_interop';
import 'dart:ui_web' as ui;

import 'package:flutter/material.dart';
import 'package:web/web.dart' as web;

class PlatformHtmlRichTextEditor extends StatefulWidget {
  const PlatformHtmlRichTextEditor({
    super.key,
    required this.initialHtml,
    required this.onChanged,
    required this.minHeight,
    required this.hintText,
  });

  final String initialHtml;
  final ValueChanged<String> onChanged;
  final double minHeight;
  final String hintText;

  @override
  State<PlatformHtmlRichTextEditor> createState() =>
      _PlatformHtmlRichTextEditorState();
}

class _PlatformHtmlRichTextEditorState extends State<PlatformHtmlRichTextEditor> {
  late final String _viewType;
  late final web.HTMLDivElement _editorElement;
  JSFunction? _inputListener;
  JSFunction? _focusListener;
  JSFunction? _blurListener;
  bool _hasFocus = false;
  bool _isEmpty = true;
  String _lastHtml = '';

  @override
  void initState() {
    super.initState();
    _viewType = 'survey-builder-html-editor-${identityHashCode(this)}';
    _editorElement = _buildEditorElement();
    _setEditorHtml(widget.initialHtml, notify: false);
    ui.platformViewRegistry.registerViewFactory(_viewType, (int _) {
      return _editorElement;
    });
  }

  @override
  void didUpdateWidget(covariant PlatformHtmlRichTextEditor oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initialHtml != oldWidget.initialHtml &&
        widget.initialHtml != _lastHtml) {
      _setEditorHtml(widget.initialHtml, notify: false);
    }
  }

  @override
  void dispose() {
    if (_inputListener != null) {
      _editorElement.removeEventListener('input', _inputListener!);
    }
    if (_focusListener != null) {
      _editorElement.removeEventListener('focus', _focusListener!);
    }
    if (_blurListener != null) {
      _editorElement.removeEventListener('blur', _blurListener!);
    }
    super.dispose();
  }

  web.HTMLDivElement _buildEditorElement() {
    final element = web.HTMLDivElement()
      ..contentEditable = 'true'
      ..spellcheck = true
      ..style.width = '100%'
      ..style.minHeight = '${widget.minHeight}px'
      ..style.padding = '12px'
      ..style.outline = 'none'
      ..style.overflowY = 'auto'
      ..style.lineHeight = '1.5'
      ..style.fontSize = '14px'
      ..style.fontFamily = 'NotoSans, sans-serif'
      ..style.whiteSpace = 'pre-wrap';

    _inputListener = ((web.Event _) => _syncFromDom()).toJS;
    _focusListener = ((web.Event _) {
      if (!mounted) return;
      setState(() => _hasFocus = true);
    }).toJS;
    _blurListener = ((web.Event _) {
      _syncFromDom();
      if (!mounted) return;
      setState(() => _hasFocus = false);
    }).toJS;

    element.addEventListener('input', _inputListener!);
    element.addEventListener('focus', _focusListener!);
    element.addEventListener('blur', _blurListener!);
    return element;
  }

  void _setEditorHtml(String html, {required bool notify}) {
    final normalized = _normalizeHtml(html);
    _lastHtml = normalized;
    _isEmpty = normalized.isEmpty;
    _editorElement.innerHTML = normalized.toJS;
    if (notify) {
      widget.onChanged(normalized);
    }
    if (mounted) {
      setState(() {});
    }
  }

  void _syncFromDom() {
    final normalized =
        _normalizeHtml((_editorElement.innerHTML as JSString).toDart);
    if (normalized == _lastHtml && _isEmpty == normalized.isEmpty) {
      return;
    }
    _lastHtml = normalized;
    if (!mounted) {
      _isEmpty = normalized.isEmpty;
      widget.onChanged(normalized);
      return;
    }
    setState(() => _isEmpty = normalized.isEmpty);
    widget.onChanged(normalized);
  }

  void _applyCommand(String command, {String value = ''}) {
    _editorElement.focus();
    web.document.execCommand(command, false, value);
    _syncFromDom();
  }

  Future<void> _insertLink() async {
    final controller = TextEditingController();
    final link = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Inserir link'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(labelText: 'URL'),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(controller.text.trim()),
            child: const Text('Inserir'),
          ),
        ],
      ),
    );
    if (!mounted || link == null || link.isEmpty) return;
    _applyCommand('createLink', value: link);
  }

  String _normalizeHtml(String html) {
    final trimmed = html.trim();
    if (trimmed.isEmpty ||
        trimmed == '<br>' ||
        trimmed == '<div><br></div>' ||
        trimmed == '<p><br></p>') {
      return '';
    }
    return trimmed;
  }

  Widget _toolbarButton({
    required IconData icon,
    required String tooltip,
    required VoidCallback onPressed,
  }) {
    return IconButton(
      tooltip: tooltip,
      visualDensity: VisualDensity.compact,
      onPressed: onPressed,
      icon: Icon(icon, size: 18),
    );
  }

  @override
  Widget build(BuildContext context) {
    final borderColor = _hasFocus
        ? Theme.of(context).colorScheme.primary
        : Theme.of(context).dividerColor;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: 4,
          runSpacing: 4,
          children: [
            _toolbarButton(
              icon: Icons.format_bold,
              tooltip: 'Negrito',
              onPressed: () => _applyCommand('bold'),
            ),
            _toolbarButton(
              icon: Icons.format_italic,
              tooltip: 'Itálico',
              onPressed: () => _applyCommand('italic'),
            ),
            _toolbarButton(
              icon: Icons.format_underline,
              tooltip: 'Sublinhado',
              onPressed: () => _applyCommand('underline'),
            ),
            _toolbarButton(
              icon: Icons.format_list_bulleted,
              tooltip: 'Lista com marcadores',
              onPressed: () => _applyCommand('insertUnorderedList'),
            ),
            _toolbarButton(
              icon: Icons.format_list_numbered,
              tooltip: 'Lista numerada',
              onPressed: () => _applyCommand('insertOrderedList'),
            ),
            _toolbarButton(
              icon: Icons.link,
              tooltip: 'Inserir link',
              onPressed: _insertLink,
            ),
            _toolbarButton(
              icon: Icons.format_clear,
              tooltip: 'Limpar formatação',
              onPressed: () => _applyCommand('removeFormat'),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Stack(
          children: [
            Container(
              constraints: BoxConstraints(minHeight: widget.minHeight),
              decoration: BoxDecoration(
                border: Border.all(color: borderColor),
                borderRadius: BorderRadius.circular(8),
              ),
              clipBehavior: Clip.antiAlias,
              child: SizedBox(
                width: double.infinity,
                height: widget.minHeight,
                child: HtmlElementView(viewType: _viewType),
              ),
            ),
            if (_isEmpty && !_hasFocus)
              IgnorePointer(
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Text(
                    widget.hintText,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context).hintColor,
                        ),
                  ),
                ),
              ),
          ],
        ),
      ],
    );
  }
}
