import 'package:dart_nostr/dart_nostr.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:let_him_cook/src/features/recipes/recipe.dart';

class RecipeEditState {
  final String title;
  final List<String> tags;
  final String summary;
  final String prepTime;
  final String cookTime;
  final String servings;
  final List<MapEntry<String, String>> ingredients;
  final List<String> directions;
  final List<String> images;
  final Map<String, String> relatedRecipes;
  final bool isPublishing;

  RecipeEditState({
    this.title = '',
    this.tags = const [],
    this.summary = '',
    this.prepTime = '',
    this.cookTime = '',
    this.servings = '',
    this.ingredients = const [],
    this.directions = const [],
    this.images = const [],
    this.relatedRecipes = const {},
    this.isPublishing = false,
  });

  RecipeEditState copyWith({
    String? title,
    List<String>? tags,
    String? summary,
    String? prepTime,
    String? cookTime,
    String? servings,
    List<MapEntry<String, String>>? ingredients,
    List<String>? directions,
    List<String>? images,
    Map<String, String>? relatedRecipes,
    bool? isPublishing,
  }) {
    return RecipeEditState(
      title: title ?? this.title,
      tags: tags ?? this.tags,
      summary: summary ?? this.summary,
      prepTime: prepTime ?? this.prepTime,
      cookTime: cookTime ?? this.cookTime,
      servings: servings ?? this.servings,
      ingredients: ingredients ?? this.ingredients,
      directions: directions ?? this.directions,
      images: images ?? this.images,
      relatedRecipes: relatedRecipes ?? this.relatedRecipes,
      isPublishing: isPublishing ?? this.isPublishing,
    );
  }
}

class RecipeEditNotifier extends StateNotifier<RecipeEditState> {
  RecipeEditNotifier(NostrEvent? recipe) : super(RecipeEditState()) {
    if (recipe != null) {
      state = state.copyWith(
        title: recipe.title,
        tags: recipe.categories,
        summary: recipe.summary,
        prepTime: recipe.prepTime,
        cookTime: recipe.cookTime,
        servings: recipe.servings,
        ingredients:
            recipe.ingredients.map((e) => MapEntry(e, e)).toList(),
        directions: recipe.directions,
        images: [recipe.image],
      );
    }
  }

  void updateTitle(String val) => state = state.copyWith(title: val);
  void updateSummary(String val) => state = state.copyWith(summary: val);
  void updatePrepTime(String val) => state = state.copyWith(prepTime: val);
  void updateCookTime(String val) => state = state.copyWith(cookTime: val);
  void updateServings(String val) => state = state.copyWith(servings: val);
  void updateIngredients(List<MapEntry<String, String>> val) =>
      state = state.copyWith(ingredients: val);
  void updateDirections(String val) => state = state.copyWith(directions: [val]);
  void addImage(String url) =>
      state = state.copyWith(images: [...state.images, url]);
  void updateRelatedRecipes(Map<String, String> newMap) {
    state = state.copyWith(relatedRecipes: newMap);
  }

  Future<void> publishRecipe() async {
    state = state.copyWith(isPublishing: true);
    //await NostrService.publishRecipe(state);
    state = state.copyWith(isPublishing: false);
  }

  removeTag(int index) {}

  removeImage(int index) {}

  addTag(String newTag) {}
}

final recipeEditProvider =
    StateNotifierProvider.family<RecipeEditNotifier, RecipeEditState, NostrEvent?>(
  (ref, recipe) => RecipeEditNotifier(recipe),
);
