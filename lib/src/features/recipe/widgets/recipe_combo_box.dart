import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:let_him_cook/src/data/models/nostr_event.dart';
import 'package:let_him_cook/src/features/recipe/notifiers/recipes_notifier.dart';

/// A combo box that fetches the user's recipes, shows them in a dropdown,
/// and stores a selected map of { recipeId -> recipeTitle }.
class RecipeComboBox extends ConsumerStatefulWidget {
  /// The initial map of selected recipes (id->title).
  final Map<String, String> selectedRecipes;
  final String placeholder;

  /// Callback if the selected map changes (e.g., to store in your Notifier).
  final ValueChanged<Map<String, String>>? onChanged;

  const RecipeComboBox({
    super.key,
    required this.selectedRecipes,
    required this.placeholder,
    this.onChanged,
  });

  @override
  ConsumerState<RecipeComboBox> createState() => _RecipeComboBoxState();
}

class _RecipeComboBoxState extends ConsumerState<RecipeComboBox> {
  late Map<String, String> _selectedRecipes;

  @override
  void initState() {
    super.initState();
    _selectedRecipes = Map.from(widget.selectedRecipes);
  }

  void _handleSelection(String recipeId, String recipeTitle) {
    setState(() {
      _selectedRecipes[recipeId] = recipeTitle;
    });
    widget.onChanged?.call(_selectedRecipes);
  }

  void _removeItem(String recipeId) {
    setState(() {
      _selectedRecipes.remove(recipeId);
    });
    widget.onChanged?.call(_selectedRecipes);
  }

  @override
  Widget build(BuildContext context) {
    final userRecipesAsync = ref.watch(recipesProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        userRecipesAsync.when(
          loading: () => DropdownButtonFormField<String>(
            decoration: const InputDecoration(
              labelText: 'Loading recipes...',
              border: OutlineInputBorder(),
            ),
            items: const [],
            onChanged: null, // disabled
          ),
          error: (err, st) => DropdownButtonFormField<String>(
            decoration: const InputDecoration(
              labelText: 'Error loading recipes',
              border: OutlineInputBorder(),
            ),
            items: const [],
            onChanged: null,
          ),
          data: (recipes) {
            if (recipes.isEmpty) {
              return DropdownButtonFormField<String>(
                decoration: const InputDecoration(
                  labelText: 'No recipes found',
                  border: OutlineInputBorder(),
                ),
                items: const [],
                onChanged: null, // disabled
              );
            }

            // Provide a dummy item for "select a recipe"
            final items = [
              DropdownMenuItem<String>(
                value: '',
                child: Text(widget.placeholder),
              ),
              ...recipes.map((r) {
                return DropdownMenuItem<String>(
                  value: r.id,
                  child: Text(
                    r.title.isNotEmpty ? r.title : 'Untitled Recipe',
                    overflow: TextOverflow.ellipsis,
                  ),
                );
              }),
            ];

            return DropdownButtonFormField<String>(
              isExpanded: true,
              decoration: InputDecoration(
                labelText: widget.placeholder,
                border: const OutlineInputBorder(),
              ),
              items: items,
              // By default, no selection
              value: '',
              onChanged: (value) {
                if (value == null || value.isEmpty) return;
                final recipe = recipes.firstWhere((r) => r.id == value);
                _handleSelection(recipe.id!, recipe.title);
              },
            );
          },
        ),
        const SizedBox(height: 8),
        // Display the currently selected recipes
        if (_selectedRecipes.isNotEmpty)
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _selectedRecipes.length,
            itemBuilder: (context, index) {
              final entries = _selectedRecipes.entries.toList();
              final recipeId = entries[index].key;
              final recipeTitle = entries[index].value;
              return Container(
                margin: const EdgeInsets.only(bottom: 4),
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: ListTile(
                  title: Text(
                      recipeTitle.isNotEmpty ? recipeTitle : 'Untitled Recipe'),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () => _removeItem(recipeId),
                  ),
                ),
              );
            },
          ),
      ],
    );
  }
}
