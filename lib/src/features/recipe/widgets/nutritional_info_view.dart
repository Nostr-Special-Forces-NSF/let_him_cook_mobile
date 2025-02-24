import 'package:flutter/material.dart';
import 'package:let_him_cook/src/app/app_theme.dart';

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

/// Displays nutritional info in a read-only, compact manner.
class NutritionalInfoView extends StatelessWidget {
  final Map<String, String> data;

  const NutritionalInfoView({
    super.key,
    required this.data,
  });

  @override
  Widget build(BuildContext context) {
    // Filter out empty or missing keys
    final nonEmptyKeys = nutritionKeys.where((k) {
      final val = data[k];
      return val != null && val.isNotEmpty;
    }).toList();

    if (nonEmptyKeys.isEmpty) {
      // No data to show => show nothing or a placeholder
      return const SizedBox.shrink();
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Wrap(
          spacing: 16,
          runSpacing: 8,
          children: nonEmptyKeys.map((k) => _buildChip(k)).toList(),
        ),
      ),
    );
  }

  Widget _buildChip(String key) {
    final val = data[key] ?? '';
    final label =
        nutritionLabels[key] ?? key; // fallback to the key if no label is found

    return Container(
      width: 80,
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            val,
            style: const TextStyle(fontWeight: FontWeight.bold, color: LetHimCookTheme.darkPrimaryColor),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(fontSize: 12, color: Colors.black54),
          ),
        ],
      ),
    );
  }
}
