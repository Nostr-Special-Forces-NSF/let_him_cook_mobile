import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:markdown_toolbar/markdown_toolbar.dart';

class MarkdownEditor extends StatefulWidget {
  final String content;
  final ValueChanged<String>? onChanged;
  final String placeholder;

  const MarkdownEditor({
    super.key,
    required this.content,
    this.onChanged,
    this.placeholder = 'Write your recipe here...',
  });

  @override
  State<MarkdownEditor> createState() => _MarkdownEditorState();
}

class _MarkdownEditorState extends State<MarkdownEditor> {
  bool _preview = false;
  final TextEditingController _controller =
      TextEditingController(); // Declare the TextEditingController
  late final FocusNode _focusNode; // Declare the FocusNode

  @override
  void initState() {
    _controller
        .addListener(() => setState(() {})); // Update the text when typing
    _focusNode = FocusNode(); // Assign a FocusNode
    super.initState();
  }

  @override
  void didUpdateWidget(MarkdownEditor oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.content != widget.content) {
      _controller.text = widget.content;
    }
  }

  void _togglePreview() {
    setState(() {
      _preview = !_preview;
    });
  }

  // Inserts or wraps selected text in the editor with [before] and [after]
  void _formatText({required String before, String after = ''}) {
    final text = _controller.text;
    final selection = _controller.selection;
    final start = selection.start;
    final end = selection.end;

    if (start < 0 || end < 0) return; // no real selection
    final selectedText = text.substring(start, end);
    final newText = text.replaceRange(
      start,
      end,
      '$before$selectedText$after',
    );

    _controller.value = TextEditingValue(
      text: newText,
      selection: TextSelection.collapsed(
          offset: start + before.length + selectedText.length),
    );

    widget.onChanged?.call(_controller.text);
  }

  void _insertText(String snippet) {
    final text = _controller.text;
    final selection = _controller.selection;
    final start = selection.start;
    final end = selection.end;

    final newText = text.replaceRange(start, end, snippet);
    _controller.value = TextEditingValue(
      text: newText,
      selection: TextSelection.collapsed(offset: start + snippet.length),
    );
    widget.onChanged?.call(_controller.text);
  }

  @override
  Widget build(BuildContext context) {
    final currentMarkdown = _controller.text;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Toolbar
        MarkdownToolbar(
          useIncludedTextField:
              false, // Because we want to use our own, set useIncludedTextField to false
          controller: _controller, // Add the _controller
          focusNode: _focusNode, // Add the _focusNode
        ),
        const SizedBox(height: 8),
        // Editor or Preview
        _preview
            ? Container(
                padding: const EdgeInsets.all(8.0),
                color: Colors.grey[200],
                height: 250,
                child: Markdown(
                  data: currentMarkdown,
                  selectable: true,
                ),
              )
            : TextField(
                controller: _controller,
                focusNode: _focusNode, // Add the _focusNode
                minLines: 6,
                maxLines: null,
                decoration: InputDecoration(
                  hintText: widget.placeholder,
                  border: const OutlineInputBorder(),
                ),
                onChanged: (val) => widget.onChanged?.call(val),
              ),
      ],
    );
  }
}
