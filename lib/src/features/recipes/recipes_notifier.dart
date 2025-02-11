import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:let_him_cook/src/features/recipes/providers.dart';
import 'package:let_him_cook/src/features/recipes/recipe.dart';

class RecipesNotifier extends AsyncNotifier<List<Recipe>> {
  StreamSubscription<List<Recipe>>? _subscription;

  // We’ll read the repository from the provider in build()
  @override
  Future<List<Recipe>> build() async {
    state = const AsyncLoading();

    final repository = ref.watch(recipeRepositoryProvider);

    repository.subscribeToRecipes();

    repository.recipeStream.listen((recipes) {
      state = AsyncData(recipes);
    }, onError: (err) {
      state = AsyncError(err, StackTrace.current);
    });

    ref.onDispose(() {
      _subscription?.cancel();
    });

    return [];
  }
}

// The provider that exposes our Recipe stream as an AsyncValue
final recipesProvider =
    AsyncNotifierProvider<RecipesNotifier, List<Recipe>>(
  RecipesNotifier.new,
);
