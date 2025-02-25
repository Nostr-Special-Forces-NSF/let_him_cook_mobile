import 'package:dart_nostr/nostr/model/event/event.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:let_him_cook/src/data/models/recipe.dart';
import 'package:let_him_cook/src/data/repositories/recipe_repository.dart';
import 'package:let_him_cook/src/features/edit/screens/recipe_edit_notifier.dart';
import 'package:let_him_cook/src/shared/providers/providers.dart';

final recipeEditProvider =
    StateNotifierProvider.family<RecipeEditNotifier, Recipe, NostrEvent?>(
  (ref, recipe) {
    final RecipeRepository recipeRepository =
        ref.watch(recipeRepositoryProvider);
    return RecipeEditNotifier(recipeRepository, recipe);
  },
);
