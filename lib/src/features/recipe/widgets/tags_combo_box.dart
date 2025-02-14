import 'package:flutter/material.dart';

class TagsComboBox extends StatefulWidget {
  /// Currently selected tags
  final List<String> selectedTags;
  /// Called when user adds a new tag
  final ValueChanged<String> onTagSelected;
  /// Called when a tag is removed
  final ValueChanged<int>? onTagRemoved;

  const TagsComboBox({
    super.key,
    required this.selectedTags,
    required this.onTagSelected,
    this.onTagRemoved,
  });

  @override
  State<TagsComboBox> createState() => _TagsComboBoxState();
}

class _TagsComboBoxState extends State<TagsComboBox> {
  final TextEditingController _controller = TextEditingController();

  void _addTag() {
    final input = _controller.text.trim();
    if (input.isNotEmpty) {
      widget.onTagSelected(input);
      _controller.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Display the selected tags
        if (widget.selectedTags.isNotEmpty)
          Wrap(
            spacing: 8.0,
            runSpacing: 4.0,
            children: widget.selectedTags.asMap().entries.map((entry) {
              final index = entry.key;
              final tag = entry.value;
              return Chip(
                label: Text(tag),
                deleteIcon: const Icon(Icons.close),
                onDeleted: () {
                  widget.onTagRemoved?.call(index);
                },
              );
            }).toList(),
          ),
        const SizedBox(height: 8),
        // TextField for adding a new tag
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _controller,
                decoration: const InputDecoration(
                  labelText: "Add a tag (e.g. 'italian', 'steak', 'glutenfree')",
                  border: OutlineInputBorder(),
                ),
                onSubmitted: (_) => _addTag(),
              ),
            ),
            const SizedBox(width: 8),
            ElevatedButton(
              onPressed: _addTag,
              child: const Text('Add'),
            ),
          ],
        ),
      ],
    );
  }
}
