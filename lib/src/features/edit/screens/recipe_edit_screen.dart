import 'package:dart_nostr/dart_nostr.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:let_him_cook/src/data/models/nostr_event.dart';
import 'package:let_him_cook/src/features/edit/providers/recipe_edit_provider.dart';
import 'package:let_him_cook/src/features/edit/widgets/nutritional_info_edit.dart';
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

    return DefaultTabController(
      length: 2, // We have 2 tabs: Ingredients & Directions
      child: Scaffold(
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
              ImagesComboBox(
                images: editState.images,
                onImageAdded: (url) =>
                    ref.read(recipeEditProvider(recipe).notifier).addImage(url),
                onImageRemoved: (index) => ref
                    .read(recipeEditProvider(recipe).notifier)
                    .removeImage(index),
              ),
              const SizedBox(height: 24),
              TagsComboBox(
                selectedTags: editState.tags,
                onTagSelected: (newTag) => ref
                    .read(recipeEditProvider(recipe).notifier)
                    .addTag(newTag),
                onTagRemoved: (index) => ref
                    .read(recipeEditProvider(recipe).notifier)
                    .removeTag(index),
              ),
              const SizedBox(height: 16),
              TagsComboBox(
                selectedTags: editState.tags,
                onTagSelected: (newTag) => ref
                    .read(recipeEditProvider(recipe).notifier)
                    .addTag(newTag),
                onTagRemoved: (index) => ref
                    .read(recipeEditProvider(recipe).notifier)
                    .removeTag(index),
              ),
              const SizedBox(height: 16),
              _buildTextField(
                label: 'Brief Summary',
                hint: 'A short description of the dish',
                value: editState.summary!,
                controller: summaryController,
                maxLines: 4,
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
                value: editState.prepTime ?? '',
                controller: prepController,
                onChanged: (val) => ref
                    .read(recipeEditProvider(recipe).notifier)
                    .updatePrepTime(val),
              ),
              _buildTextField(
                label: 'Cook Time',
                hint: 'e.g., 1 hour',
                value: editState.cookTime ?? '',
                controller: cookController,
                onChanged: (val) => ref
                    .read(recipeEditProvider(recipe).notifier)
                    .updateCookTime(val),
              ),
              _buildTextField(
                label: 'Servings',
                hint: 'e.g., 4 persons',
                value: editState.servings ?? '',
                controller: servingsController,
                onChanged: (val) => ref
                    .read(recipeEditProvider(recipe).notifier)
                    .updateServings(val),
              ),
              const SizedBox(height: 16),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  NutritionalInfoEdit(
                    initialData: recipe?.nutrition ?? {},
                    onSave: (updatedMap) {
                      ref
                          .read(recipeEditProvider(recipe).notifier)
                          .updateNutrition(updatedMap);
                    },
                  ),
                ],
              ),
              const SizedBox(height: 16),
              const TabBar(
                tabs: [
                  Tab(text: 'INGREDIENTS'),
                  Tab(text: 'DIRECTIONS'),
                ],
              ),
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.7,
                child: TabBarView(
                  children: [
                    SingleChildScrollView(
                      // Wrap the Column in SingleChildScrollView
                      child: Column(
                        children: [
                          const SizedBox(height: 16),
                          TupleComboBox(
                            selectedItems:
                                editState.ingredients.entries.toList(),
                            amountPlaceholder: 'Quantity (e.g., 1 cup)',
                            itemPlaceholder: 'Ingredient (e.g., flour)',
                            onChanged: (ingredients) => ref
                                .read(recipeEditProvider(recipe).notifier)
                                .updateIngredients(
                                    Map.fromEntries(ingredients.map((l) {
                              return MapEntry(l.key, l.value);
                            }))),
                          ),
                        ],
                      ),
                    ),
                    Column(
                      children: [
                        const SizedBox(height: 16),
                        MarkdownEditor(
                          content: editState.directions.join('\n'),
                          onChanged: (val) => ref
                              .read(recipeEditProvider(recipe).notifier)
                              .updateDirections(val),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
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
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
      ),
      child: TextField(
        minLines: null,
        maxLines: maxLines,
        decoration: InputDecoration(
          hintText: hint,
          labelText: label,
        ),
        onSubmitted: onChanged,
        controller: controller,
      ),
    );
  }
}
