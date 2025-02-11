import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:let_him_cook/src/features/recipes/recipe_repository.dart';
import 'package:let_him_cook/src/services/nostr_service.dart';

final nostrServicerProvider = Provider<NostrService>((ref) {
  return NostrService();
});

final recipeRepositoryProvider = Provider<RecipeRepository>((ref) {
  final nostrService = ref.watch(nostrServicerProvider);
  final recipeRepository = RecipeRepository(nostrService);
  recipeRepository.subscribeToRecipes();
  return recipeRepository;
});
