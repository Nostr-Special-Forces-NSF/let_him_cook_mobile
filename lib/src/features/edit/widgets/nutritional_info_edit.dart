import 'package:flutter/material.dart';

const nutritionKeys = [
  "calories",
  "fat_content",
  "carbohydrate_content",
  "protein_content",
  "fiber_content",
  "sugar_content",
  "sodium_content",
  "cholesterol_content",
  "saturated_fat_content",
  "serving_size",
];

const nutritionLabels = {
  "calories": "Calories",
  "fat_content": "Fat",
  "carbohydrate_content": "Carbs",
  "protein_content": "Protein",
  "fiber_content": "Fiber",
  "sugar_content": "Sugar",
  "sodium_content": "Sodium",
  "cholesterol_content": "Cholesterol",
  "saturated_fat_content": "Sat. Fat",
  "serving_size": "Servings",
};

/// Allows editing nutritional info in a compact layout.
/// On pressing "Save," we call onSave(...) with the updated map.
class NutritionalInfoEdit extends StatefulWidget {
  final Map<String, String> initialData;
  final ValueChanged<Map<String, String>> onSave;

  const NutritionalInfoEdit({
    super.key,
    required this.initialData,
    required this.onSave,
  });

  @override
  State<NutritionalInfoEdit> createState() => _NutritionalInfoEditState();
}

class _NutritionalInfoEditState extends State<NutritionalInfoEdit> {
  late Map<String, TextEditingController> _controllers;

  @override
  void initState() {
    super.initState();
    // Create a TextEditingController for each key
    _controllers = {};
    for (final k in nutritionKeys) {
      final initialVal = widget.initialData[k] ?? '';
      _controllers[k] = TextEditingController(text: initialVal);
    }
  }

  @override
  void dispose() {
    // Dispose controllers
    for (final c in _controllers.values) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Edit Nutritional Info',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 16,
              runSpacing: 8,
              children: nutritionKeys.map((k) => _buildField(k)).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildField(String key) {
    final label = nutritionLabels[key] ?? key;
    final controller = _controllers[key]!;

    return SizedBox(
      width: 100,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
          TextField(
            controller: controller,
            textAlign: TextAlign.center,
            decoration: const InputDecoration(
              isDense: true,
              contentPadding: EdgeInsets.symmetric(vertical: 6, horizontal: 4),
            ),
          ),
        ],
      ),
    );
  }
}
