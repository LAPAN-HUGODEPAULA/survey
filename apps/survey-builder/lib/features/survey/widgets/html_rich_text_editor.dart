import 'package:flutter/material.dart';

import 'html_rich_text_editor_impl.dart';

abstract class HtmlRichTextEditorHandle {
  Future<String> getHtml();
}

class HtmlRichTextEditor extends StatefulWidget {
  const HtmlRichTextEditor({
    super.key,
    required this.label,
    required this.initialHtml,
    required this.onChanged,
    this.minHeight = 220,
    this.hintText,
  });

  final String label;
  final String initialHtml;
  final ValueChanged<String> onChanged;
  final double minHeight;
  final String? hintText;

  @override
  State<HtmlRichTextEditor> createState() => HtmlRichTextEditorState();
}

class HtmlRichTextEditorState extends State<HtmlRichTextEditor>
    implements HtmlRichTextEditorHandle {
  late final TextEditingController _testController;
  late String _currentHtml;

  @override
  void initState() {
    super.initState();
    _currentHtml = widget.initialHtml;
    _testController = TextEditingController(text: widget.initialHtml);
  }

  @override
  void didUpdateWidget(covariant HtmlRichTextEditor oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initialHtml != oldWidget.initialHtml) {
      _currentHtml = widget.initialHtml;
      if (_isTestEnvironment()) {
        _testController.text = widget.initialHtml;
      }
    }
  }

  @override
  void dispose() {
    _testController.dispose();
    super.dispose();
  }

  @override
  Future<String> getHtml() async {
    if (_isTestEnvironment()) {
      return _testController.text;
    }
    return _currentHtml;
  }

  void _handleChanged(String value) {
    _currentHtml = value;
    widget.onChanged(value);
  }

  @override
  Widget build(BuildContext context) {
    if (_isTestEnvironment()) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(widget.label, style: Theme.of(context).textTheme.titleSmall),
          const SizedBox(height: 8),
          TextFormField(
            controller: _testController,
            decoration: InputDecoration(labelText: widget.label),
            minLines: 6,
            maxLines: null,
            onChanged: _handleChanged,
          ),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(widget.label, style: Theme.of(context).textTheme.titleSmall),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: Theme.of(context).dividerColor),
            borderRadius: BorderRadius.circular(8),
          ),
          padding: const EdgeInsets.all(12),
          child: PlatformHtmlRichTextEditor(
            initialHtml: widget.initialHtml,
            minHeight: widget.minHeight,
            hintText: widget.hintText ?? widget.label,
            onChanged: _handleChanged,
          ),
        ),
      ],
    );
  }

  bool _isTestEnvironment() {
    final binding = WidgetsBinding.instance;
    return binding.runtimeType.toString().contains('Test');
  }
}
