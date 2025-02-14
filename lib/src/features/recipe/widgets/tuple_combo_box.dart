import 'package:flutter/material.dart';

/// Represents a pair of (amount, item).
/// e.g. "1 cup" + "flour"
class TupleComboBox extends StatefulWidget {
  final List<MapEntry<String, String>> selectedItems;
  final String amountPlaceholder;
  final String itemPlaceholder;
  final bool allowEditing;
  final ValueChanged<List<MapEntry<String, String>>> onChanged;

  const TupleComboBox({
    super.key,
    required this.selectedItems,
    required this.onChanged,
    this.amountPlaceholder = 'Quantity (e.g., 1 cup)',
    this.itemPlaceholder = 'Item (e.g., flour)',
    this.allowEditing = true,
  });

  @override
  State<TupleComboBox> createState() => _TupleComboBoxState();
}

class _TupleComboBoxState extends State<TupleComboBox> {
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _itemController = TextEditingController();

  int? editingIndex;

  List<MapEntry<String, String>> get items => widget.selectedItems;

  void _addItem() {
    final amount = _amountController.text.trim();
    final item = _itemController.text.trim();
    if (amount.isEmpty || item.isEmpty) return;
    setState(() {
      final newList = List<MapEntry<String, String>>.from(items)
        ..add(MapEntry(amount, item));
      widget.onChanged(newList);
      _amountController.clear();
      _itemController.clear();
    });
  }

  void _removeItem(int index) {
    final newList = List<MapEntry<String, String>>.from(items)..removeAt(index);
    widget.onChanged(newList);
  }

  void _startEditing(int index) {
    final entry = items[index];
    _amountController.text = entry.key;
    _itemController.text = entry.value;
    setState(() => editingIndex = index);
  }

  void _saveEditing() {
    if (editingIndex != null) {
      final amount = _amountController.text.trim();
      final item = _itemController.text.trim();
      if (amount.isNotEmpty && item.isNotEmpty) {
        final newList = List<MapEntry<String, String>>.from(items);
        newList[editingIndex!] = MapEntry(amount, item);
        widget.onChanged(newList);
      }
      _cancelEditing();
    }
  }

  void _cancelEditing() {
    editingIndex = null;
    _amountController.clear();
    _itemController.clear();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // List of existing items
        if (items.isNotEmpty)
          Column(
            children: List.generate(items.length, (index) {
              final pair = items[index];
              final isEditing = (index == editingIndex);
              if (isEditing && widget.allowEditing) {
                return Card(
                  child: ListTile(
                    title: Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _amountController,
                            decoration:
                                InputDecoration(hintText: widget.amountPlaceholder),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: TextField(
                            controller: _itemController,
                            decoration:
                                InputDecoration(hintText: widget.itemPlaceholder),
                          ),
                        ),
                      ],
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.check, color: Colors.green),
                          onPressed: _saveEditing,
                        ),
                        IconButton(
                          icon: const Icon(Icons.close, color: Colors.red),
                          onPressed: _cancelEditing,
                        ),
                      ],
                    ),
                  ),
                );
              } else {
                return Card(
                  child: ListTile(
                    title: Text('${pair.key} ${pair.value}'),
                    onTap: widget.allowEditing ? () => _startEditing(index) : null,
                    trailing: IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () => _removeItem(index),
                    ),
                  ),
                );
              }
            }),
          ),
        const SizedBox(height: 8),
        // Form for adding a new pair
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _amountController,
                decoration: InputDecoration(hintText: widget.amountPlaceholder),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: TextField(
                controller: _itemController,
                decoration: InputDecoration(hintText: widget.itemPlaceholder),
              ),
            ),
            const SizedBox(width: 8),
            ElevatedButton(
              onPressed: _addItem,
              child: const Text('Add'),
            ),
          ],
        ),
      ],
    );
  }
}
