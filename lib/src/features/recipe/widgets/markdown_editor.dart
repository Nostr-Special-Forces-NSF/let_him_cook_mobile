import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';

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
  late TextEditingController _controller;
  bool _preview = false;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.content);
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
      selection: TextSelection.collapsed(offset: start + before.length + selectedText.length),
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
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              IconButton(
                icon: const Icon(Icons.list),
                tooltip: "Insert Steps",
                onPressed: () => _insertText('\n## Directions\n1. Step 1\n2. Step 2\n\n'),
              ),
              IconButton(
                icon: const Icon(Icons.title),
                tooltip: "Header 1",
                onPressed: () => _formatText(before: '# ', after: ''),
              ),
              IconButton(
                icon: const Icon(Icons.format_bold),
                tooltip: "Bold",
                onPressed: () => _formatText(before: '**', after: '**'),
              ),
              IconButton(
                icon: const Icon(Icons.format_italic),
                tooltip: "Italic",
                onPressed: () => _formatText(before: '*', after: '*'),
              ),
              IconButton(
                icon: const Icon(Icons.format_quote),
                tooltip: "Quote",
                onPressed: () => _formatText(before: '> ', after: ''),
              ),
              IconButton(
                icon: const Icon(Icons.format_list_bulleted),
                tooltip: "List",
                onPressed: () => _insertText('- Item\n- Item\n'),
              ),
              IconButton(
                icon: Icon(_preview ? Icons.edit : Icons.preview),
                tooltip: "Toggle Preview",
                onPressed: _togglePreview,
              ),
            ],
          ),
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
