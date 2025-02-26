import 'package:dart_nostr/dart_nostr.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:let_him_cook/src/shared/providers/providers.dart';

// The provider that exposes our Recipe stream as an AsyncValue
final recipesProvider = StreamProvider((ref) {
    final recipesRepo = ref.watch(recipeRepositoryProvider);
    recipesRepo.subscribeToRecipes();
    return recipesRepo.recipeStream;
});

final allRecipesProvider = Provider<List<NostrEvent>>((ref) {
  final recipesAsync = ref.watch(recipesProvider);
  return recipesAsync.maybeWhen(orElse: () => [], data: (recipes) {
    return recipes;
  });
});