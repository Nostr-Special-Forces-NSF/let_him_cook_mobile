import 'package:dart_nostr/dart_nostr.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:let_him_cook/src/data/models/nostr_event.dart';
import 'package:let_him_cook/src/data/models/recipe.dart';

class RecipeEditNotifier extends StateNotifier<Recipe> {
  RecipeEditNotifier(NostrEvent? recipe)
      : super(recipe != null ? recipe.toRecipe() : Recipe.empty());

  void updateTitle(String val) => state = state.copyWith(title: val);
  void updateSummary(String val) => state = state.copyWith(summary: val);
  void updatePrepTime(String val) => state = state.copyWith(prepTime: val);
  void updateCookTime(String val) => state = state.copyWith(cookTime: val);
  void updateServings(String val) => state = state.copyWith(servings: val);
  void updateIngredients(Map<String, String> val) =>
      state = state.copyWith(ingredients: val);
  void updateDirections(String val) =>
      state = state.copyWith(directions: [val]);
  void addImage(String url) =>
      state = state.copyWith(images: [...state.images, url]);
  void updateRelatedRecipes(Map<String, String> newMap) {
    state = state.copyWith(relatedRecipes: newMap);
  }

  void updateNutrition(Map<String, String> updatedNutrition) {
    state = state.copyWith(nutrition: updatedNutrition);
  }

  Future<void> publishRecipe() async {
    state = state.copyWith(isPublishing: true);
    //await NostrService.publishRecipe(state);
    state = state.copyWith(isPublishing: false);
  }

  removeTag(int index) {
    final newTags = List<String>.from(state.tags);
    newTags.removeAt(index);
    state = state.copyWith(tags: newTags);
  }

  removeImage(int index) {}

  addTag(String newTag) {}
}
