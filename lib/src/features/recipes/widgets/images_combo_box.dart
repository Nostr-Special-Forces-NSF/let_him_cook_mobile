import 'package:flutter/material.dart';

class ImagesComboBox extends StatefulWidget {
  final List<String> images;
  final ValueChanged<String>? onImageAdded;
  final ValueChanged<int>? onImageRemoved;
  final int limit;

  const ImagesComboBox({
    super.key,
    required this.images,
    this.onImageAdded,
    this.onImageRemoved,
    this.limit = 0, // 0 = unlimited
  });

  @override
  State<ImagesComboBox> createState() => _ImagesComboBoxState();
}

class _ImagesComboBoxState extends State<ImagesComboBox> {
  final TextEditingController _urlController = TextEditingController();

  void _addImage() {
    final url = _urlController.text.trim();
    if (url.isNotEmpty) {
      // If limit is set & images are at limit, we do nothing
      if (widget.limit > 0 && widget.images.length >= widget.limit) {
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text('Image limit reached')));
        return;
      }
      widget.onImageAdded?.call(url);
      _urlController.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Text field for adding an image by URL
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _urlController,
                decoration: const InputDecoration(
                  labelText: 'Enter Image URL',
                  border: OutlineInputBorder(),
                ),
                onSubmitted: (_) => _addImage(),
              ),
            ),
            const SizedBox(width: 8),
            ElevatedButton(
              onPressed: _addImage,
              child: const Text('Add'),
            ),
          ],
        ),
        const SizedBox(height: 16),
        // Show current images (if any)
        if (widget.images.isNotEmpty)
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: widget.images.length,
            itemBuilder: (context, index) {
              final imageUrl = widget.images[index];
              return ListTile(
                contentPadding: EdgeInsets.zero,
                leading: SizedBox(
                  width: 60,
                  height: 60,
                  child: Image.network(imageUrl, fit: BoxFit.cover, errorBuilder:
                      (context, error, stack) {
                    return const Icon(Icons.broken_image);
                  }),
                ),
                title: Text(imageUrl, maxLines: 1, overflow: TextOverflow.ellipsis),
                trailing: IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () => widget.onImageRemoved?.call(index),
                ),
              );
            },
          ),
      ],
    );
  }
}
