import 'package:flutter/material.dart';

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

class _PlatformHtmlRichTextEditorState
    extends State<PlatformHtmlRichTextEditor> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialHtml);
  }

  @override
  void didUpdateWidget(covariant PlatformHtmlRichTextEditor oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initialHtml != oldWidget.initialHtml) {
      _controller.text = widget.initialHtml;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: _controller,
      minLines: 8,
      maxLines: null,
      decoration: InputDecoration(
        hintText: widget.hintText,
        helperText: 'Edicao HTML em modo texto fora da web.',
        border: InputBorder.none,
      ),
      onChanged: widget.onChanged,
    );
  }
}
