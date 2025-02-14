import 'package:dart_nostr/dart_nostr.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:let_him_cook/src/features/edit/providers/recipe_edit_provider.dart';
import 'package:let_him_cook/src/features/recipe/widgets/images_combo_box.dart';
import 'package:let_him_cook/src/features/recipe/widgets/markdown_editor.dart';
import 'package:let_him_cook/src/features/recipe/widgets/recipe_combo_box.dart';
import 'package:let_him_cook/src/features/recipe/widgets/tags_combo_box.dart';
import 'package:let_him_cook/src/features/recipe/widgets/tuple_combo_box.dart';

class RecipeEditScreen extends ConsumerWidget {
  final NostrEvent? recipe; // If null, create new recipe

  const RecipeEditScreen({super.key, this.recipe});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final editState = ref.watch(recipeEditProvider(recipe));

    final titleController = TextEditingController();
    final summaryController = TextEditingController();
    final prepController = TextEditingController();
    final cookController = TextEditingController();
    final servingsController = TextEditingController();

    return Scaffold(
      appBar: AppBar(
        title: Text(recipe == null ? 'Create Recipe' : 'Edit Recipe'),
        actions: [
          TextButton(
            onPressed: editState.isPublishing
                ? null
                : () {
                    ref
                        .read(recipeEditProvider(recipe).notifier)
                        .publishRecipe();
                  },
            child: Text(
              recipe == null ? 'Publish' : 'Update',
              style: TextStyle(
                  color: editState.isPublishing ? Colors.grey : Colors.white),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildTextField(
              label: 'Title*',
              hint: 'Unique recipe title',
              value: editState.title,
              controller: titleController,
              onChanged: (val) => ref
                  .read(recipeEditProvider(recipe).notifier)
                  .updateTitle(val),
            ),
            const SizedBox(height: 16),
            TagsComboBox(
              selectedTags: editState.tags,
              onTagSelected: (newTag) =>
                  ref.read(recipeEditProvider(recipe).notifier).addTag(newTag),
              onTagRemoved: (index) => ref
                  .read(recipeEditProvider(recipe).notifier)
                  .removeTag(index),
            ),
            const SizedBox(height: 16),
            _buildTextField(
              label: 'Brief Summary',
              hint: 'A short description of the dish',
              value: editState.summary,
              controller: summaryController,
              maxLines: 3,
              onChanged: (val) => ref
                  .read(recipeEditProvider(recipe).notifier)
                  .updateSummary(val),
            ),
            const SizedBox(height: 16),
            RecipeComboBox(
              selectedRecipes: editState.relatedRecipes,
              onChanged: (updatedMap) {
                ref
                    .read(recipeEditProvider(recipe).notifier)
                    .updateRelatedRecipes(updatedMap);
              },
              placeholder: 'Select a recipe...',
            ),
            const SizedBox(height: 16),
            _buildTextField(
              label: 'Prep Time',
              hint: 'e.g., 20 min',
              value: editState.prepTime,
              controller: prepController,
              onChanged: (val) => ref
                  .read(recipeEditProvider(recipe).notifier)
                  .updatePrepTime(val),
            ),
            _buildTextField(
              label: 'Cook Time',
              hint: 'e.g., 1 hour',
              value: editState.cookTime,
              controller: cookController,
              onChanged: (val) => ref
                  .read(recipeEditProvider(recipe).notifier)
                  .updateCookTime(val),
            ),
            _buildTextField(
              label: 'Servings',
              hint: 'e.g., 4 persons',
              value: editState.servings,
              controller: servingsController,
              onChanged: (val) => ref
                  .read(recipeEditProvider(recipe).notifier)
                  .updateServings(val),
            ),
            const SizedBox(height: 16),
            TupleComboBox(
              selectedItems: editState.ingredients.map((i) {
                return MapEntry(i, i);
              }).toList(),
              amountPlaceholder: 'Quantity (e.g., 1 cup)',
              itemPlaceholder: 'Ingredient (e.g., flour)',
              onChanged: (ingredients) => ref
                  .read(recipeEditProvider(recipe).notifier)
                  .updateIngredients(ingredients.map((l) {
                    return l.value;
                  }).toList()),
            ),
            const SizedBox(height: 16),
            MarkdownEditor(
              content: editState.directions.toString(),
              onChanged: (val) => ref
                  .read(recipeEditProvider(recipe).notifier)
                  .updateDirections(val),
            ),
            const SizedBox(height: 16),
            ImagesComboBox(
              images: editState.images,
              onImageAdded: (url) =>
                  ref.read(recipeEditProvider(recipe).notifier).addImage(url),
              onImageRemoved: (index) => ref
                  .read(recipeEditProvider(recipe).notifier)
                  .removeImage(index),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: editState.isPublishing
                  ? null
                  : () {
                      ref
                          .read(recipeEditProvider(recipe).notifier)
                          .publishRecipe();
                    },
              child: editState.isPublishing
                  ? const CircularProgressIndicator()
                  : Text(recipe == null ? 'Publish' : 'Update'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    required String hint,
    required String value,
    required TextEditingController controller,
    int maxLines = 1,
    required Function(String) onChanged,
  }) {
    controller.text = value;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        TextField(
          decoration: InputDecoration(
            hintText: hint,
            border: const OutlineInputBorder(),
          ),
          maxLines: maxLines,
          onChanged: onChanged,
          controller: controller,
        ),
      ],
    );
  }
}
