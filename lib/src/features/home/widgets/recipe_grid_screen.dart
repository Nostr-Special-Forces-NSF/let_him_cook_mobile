import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:let_him_cook/src/shared/providers/recipes_providers.dart';
import 'package:let_him_cook/src/shared/widgets/recipe_card_widget.dart';

class RecipeGridScreen extends ConsumerWidget {
  const RecipeGridScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final recipes = ref.watch(allRecipesProvider); // from your provider

    return GridView.builder(
      padding: const EdgeInsets.all(8.0),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2, // 2 columns
        childAspectRatio: 0.9, // Adjust to taste
        crossAxisSpacing: 8.0,
        mainAxisSpacing: 8.0,
      ),
      itemCount: recipes.length,
      itemBuilder: (context, index) {
        final recipe = recipes[index];
        return RecipeCard(recipe: recipe);
      },
    );
  }
}

