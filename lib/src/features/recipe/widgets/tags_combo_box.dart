import 'package:flutter/material.dart';
import 'package:let_him_cook/src/data/models/tag.dart';

class TagsComboBox extends StatefulWidget {
  /// List of all known tags (for autocomplete)
  final List<Tag> allTags;

  /// Currently selected tag titles
  final List<String> selectedTags;

  /// Called when user picks or creates a new tag
  final ValueChanged<String> onTagSelected;

  /// Called when a tag is removed from the selected list
  final ValueChanged<int>? onTagRemoved;

  final String? placeholder;

  const TagsComboBox({
    super.key,
    required this.allTags,
    required this.selectedTags,
    required this.onTagSelected,
    this.onTagRemoved,
    this.placeholder,
  });

  @override
  State<TagsComboBox> createState() => _TagsComboBoxState();
}

class _TagsComboBoxState extends State<TagsComboBox> {
  /// We keep a controller for the autocomplete text field
  late TextEditingController _textController;// = TextEditingController();

  void _addTag() {
    final input = _textController.text.trim();
    if (input.isNotEmpty) {
      widget.onTagSelected(input);
      _textController.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Display the selected tags as Chips
        if (widget.selectedTags.isNotEmpty)
          Wrap(
            spacing: 8.0,
            runSpacing: 4.0,
            children: widget.selectedTags.asMap().entries.map((entry) {
              final index = entry.key;
              final tagTitle = entry.value;
              return Chip(
                label: Text(tagTitle),
                deleteIcon: const Icon(Icons.close),
                onDeleted: () {
                  widget.onTagRemoved?.call(index);
                },
              );
            }).toList(),
          ),
        const SizedBox(height: 24),

        // Row with Autocomplete + "Add" button
        Row(
          children: [
            Expanded(
              child: Autocomplete<Tag>(
                // Provide the function that returns a list of matching tags
                optionsBuilder: (TextEditingValue textEditingValue) {
                  final query = textEditingValue.text.toLowerCase();
                  if (query.isEmpty) {
                    return const Iterable<Tag>.empty();
                  }
                  return widget.allTags.where((tag) {
                    return tag.title.toLowerCase().contains(query);
                  });
                },
                // Display the tag's title + optional emoji in the dropdown
                displayStringForOption: (Tag option) => option.title,
                // Called when user taps a suggestion
                onSelected: (Tag selected) {
                  widget.onTagSelected(selected.title);
                  // Clear the input after selection
                  _textController.clear();
                },
                // A custom fieldViewBuilder so we can attach our own controller
                fieldViewBuilder:
                    (BuildContext context, TextEditingController textController,
                        FocusNode focusNode, VoidCallback onFieldSubmitted) {
                  // Keep a reference to the textEditingController, so we can
                  // call _textController as well.
                  _textController = textController;

                  return TextField(
                    controller: textController,
                    focusNode: focusNode,
                    decoration: InputDecoration(
                      labelText: widget.placeholder ?? 'Add a tag',
                      border: OutlineInputBorder(),
                    ),
                    onSubmitted: (_) => _addTag(), // if user hits enter
                  );
                },
                optionsViewBuilder: (BuildContext context,
                    AutocompleteOnSelected<Tag> onSelected,
                    Iterable<Tag> options) {
                  // Build a Material dropdown
                  return Align(
                    alignment: Alignment.topLeft,
                    child: Material(
                      elevation: 4.0,
                      child: SizedBox(
                        width: MediaQuery.of(context).size.width * 0.8,
                        child: ListView.builder(
                          padding: EdgeInsets.zero,
                          itemCount: options.length,
                          itemBuilder: (BuildContext context, int index) {
                            final tag = options.elementAt(index);
                            return ListTile(
                              title: Text("${tag.title}  ${tag.emoji}"),
                              onTap: () => onSelected(tag),
                            );
                          },
                        ),
                      ),
                    ),
                  );
                },
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
