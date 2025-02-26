import 'package:dart_nostr/nostr/model/event/event.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:let_him_cook/src/data/models/nostr_event.dart';
import 'package:let_him_cook/src/data/models/tag.dart';
import 'package:let_him_cook/src/data/repositories/tags_repository.dart';
import 'package:let_him_cook/src/features/edit/providers/recipe_edit_provider.dart';
import 'package:let_him_cook/src/features/edit/widgets/nutritional_info_edit.dart';
import 'package:let_him_cook/src/features/edit/widgets/time_servings_widget.dart';
import 'package:let_him_cook/src/features/recipe/widgets/images_combo_box.dart';
import 'package:let_him_cook/src/features/recipe/widgets/markdown_editor.dart';
import 'package:let_him_cook/src/features/recipe/widgets/recipe_combo_box.dart';
import 'package:let_him_cook/src/features/recipe/widgets/tags_combo_box.dart';
import 'package:let_him_cook/src/features/recipe/widgets/tuple_combo_box.dart';

class RecipeEditScreen extends ConsumerStatefulWidget {
  final NostrEvent? recipe;

  const RecipeEditScreen({super.key, this.recipe});

  @override
  ConsumerState<RecipeEditScreen> createState() => _RecipeEditScreenState();
}

class _RecipeEditScreenState extends ConsumerState<RecipeEditScreen> {
  late final TextEditingController titleController;
  late final TextEditingController summaryController;
  late final TextEditingController prepController;
  late final TextEditingController cookController;
  late final TextEditingController servingsController;

  @override
  void initState() {
    super.initState();
    // Read the initial state once, so we can set up controllers
    final editState = ref.read(recipeEditProvider(widget.recipe));

    titleController = TextEditingController(text: editState.title);
    summaryController = TextEditingController(text: editState.summary ?? '');
    prepController = TextEditingController(text: editState.prepTime ?? '');
    cookController = TextEditingController(text: editState.cookTime ?? '');
    servingsController = TextEditingController(text: editState.servings ?? '');
  }

  @override
  Widget build(BuildContext context) {
    final editState = ref.watch(recipeEditProvider(widget.recipe));

    return DefaultTabController(
      length: 2, // INGREDIENTS & DIRECTIONS
      child: Scaffold(
        appBar: AppBar(
          title: Text(widget.recipe == null ? 'Create Recipe' : 'Edit Recipe'),
          actions: [
            TextButton(
              onPressed: editState.isPublishing
                  ? null
                  : () {
                      ref
                          .read(recipeEditProvider(widget.recipe).notifier)
                          .publishRecipe();
                    },
              child: Text(
                widget.recipe == null ? 'Publish' : 'Update',
                style: TextStyle(
                  color: editState.isPublishing ? Colors.grey : Colors.white,
                ),
              ),
            ),
          ],
        ),

        // Use ListView so the entire form is scrollable on mobile.
        body: ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            // Title text field
            _buildTextField(
              label: 'Title*',
              hint: 'Unique recipe title',
              controller: titleController,
              onChanged: (val) => ref
                  .read(recipeEditProvider(widget.recipe).notifier)
                  .updateTitle(val),
            ),
            const SizedBox(height: 16),

            // Images
            ImagesComboBox(
              images: editState.images,
              onImageAdded: (url) => ref
                  .read(recipeEditProvider(widget.recipe).notifier)
                  .addImage(url),
              onImageRemoved: (index) => ref
                  .read(recipeEditProvider(widget.recipe).notifier)
                  .removeImage(index),
            ),
            const SizedBox(height: 24),

            FutureBuilder<List<Tag>>(
                future: loadRecipeTags(),
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    return TagsComboBox(
                      allTags: snapshot.data!,
                      selectedTags: editState.tags,
                      onTagSelected: (newTag) => ref
                          .read(recipeEditProvider(widget.recipe).notifier)
                          .addTag(newTag),
                      onTagRemoved: (index) => ref
                          .read(recipeEditProvider(widget.recipe).notifier)
                          .removeTag(index),
                      placeholder:
                          "Add a tag (e.g. 'desert', 'greek', 'italian')",
                    );
                  } else {
                    return const CircularProgressIndicator();
                  }
                }),
            const SizedBox(height: 16),
            FutureBuilder<List<Tag>>(
                future: loadDietaryRestrictionsTags(),
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    return TagsComboBox(
                      allTags: snapshot.data!,
                      selectedTags: editState.dietaryRestrictions,
                      onTagSelected: (newTag) => ref
                          .read(recipeEditProvider(widget.recipe).notifier)
                          .addDietraryRestrictionTag(newTag),
                      onTagRemoved: (index) => ref
                          .read(recipeEditProvider(widget.recipe).notifier)
                          .removeDietaryRestriction(index),
                      placeholder:
                          "Add any dietary restrictions (e.g. 'vegan', 'gluten-free')",
                    );
                  } else {
                    return const CircularProgressIndicator();
                  }
                }),

            // Summary
            _buildTextField(
              label: 'Brief Summary',
              hint: 'A short description of the dish',
              controller: summaryController,
              maxLines: 4,
              onChanged: (val) => ref
                  .read(recipeEditProvider(widget.recipe).notifier)
                  .updateSummary(val),
            ),
            const SizedBox(height: 16),

            // Related recipes
            RecipeComboBox(
              selectedRecipes: editState.relatedRecipes,
              onChanged: (updatedMap) => ref
                  .read(recipeEditProvider(widget.recipe).notifier)
                  .updateRelatedRecipes(updatedMap),
              placeholder: 'Related Recipes...',
            ),
            const SizedBox(height: 16),

            TimeServingsEdit(
              prepController: prepController,
              cookController: cookController,
              servingsController: servingsController,
            ),
            const SizedBox(height: 16),

            // Nutritional Info
            NutritionalInfoEdit(
              initialData: widget.recipe?.nutrition ?? {},
              onSave: (updatedMap) {
                ref
                    .read(recipeEditProvider(widget.recipe).notifier)
                    .updateNutrition(updatedMap);
              },
            ),
            const SizedBox(height: 16),

            // Tools
            const SizedBox(height: 16),
            FutureBuilder<List<Tag>>(
                future: loadToolTags(),
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    return TagsComboBox(
                      allTags: snapshot.data!,
                      selectedTags: editState.tools,
                      onTagSelected: (newTag) => ref
                          .read(recipeEditProvider(widget.recipe).notifier)
                          .addToolTag(newTag),
                      onTagRemoved: (index) => ref
                          .read(recipeEditProvider(widget.recipe).notifier)
                          .removeToolTag(index),
                      placeholder:
                          "Add any Tools (e.g. 'vegan', 'gluten-free')",
                    );
                  } else {
                    return const CircularProgressIndicator();
                  }
                }),
            const SizedBox(height: 16),

            // The TabBar for Ingredients & Directions
            const TabBar(
              tabs: [
                Tab(text: 'INGREDIENTS'),
                Tab(text: 'DIRECTIONS'),
              ],
            ),

            // The TabBarView
            // The TabBarView content. Because we used a DefaultTabController,
            // we can place the TabBarView anywhere in the widget tree.
            // We'll do "physics: NeverScrollableScrollPhysics()" to avoid nested scrolling.
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.5,
              child: TabBarView(
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  // INGREDIENTS TAB
                  SingleChildScrollView(
                    physics: const NeverScrollableScrollPhysics(),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const SizedBox(height: 16),
                        TupleComboBox(
                          selectedItems: editState.ingredients.entries.toList(),
                          amountPlaceholder: 'Quantity (e.g., 1 cup)',
                          itemPlaceholder: 'Ingredient (e.g., flour)',
                          onChanged: (ingredients) => ref
                              .read(recipeEditProvider(widget.recipe).notifier)
                              .updateIngredients(
                            Map.fromEntries(ingredients.map((l) {
                              return MapEntry(l.key, l.value);
                            })),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // DIRECTIONS TAB
                  SingleChildScrollView(
                    physics: const NeverScrollableScrollPhysics(),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const SizedBox(height: 16),
                        MarkdownEditor(
                          content: editState.directions.join('\n'),
                          onChanged: (val) => ref
                              .read(recipeEditProvider(widget.recipe).notifier)
                              .updateDirections(val),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Bottom "Publish" or "Update" button
            ElevatedButton(
              onPressed: editState.isPublishing
                  ? null
                  : () {
                      ref
                          .read(recipeEditProvider(widget.recipe).notifier)
                          .publishRecipe();
                    },
              child: editState.isPublishing
                  ? const CircularProgressIndicator()
                  : Text(widget.recipe == null ? 'Publish' : 'Update'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    required String hint,
    required TextEditingController controller,
    int maxLines = 1,
    required Function(String) onChanged,
  }) {
    // IMPORTANT: do NOT assign `controller.text = ...` here.
    // Let the controller hold the user’s typed value.
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: TextField(
        minLines: 1,
        maxLines: maxLines,
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
        ),
        onChanged: onChanged,
      ),
    );
  }
}
