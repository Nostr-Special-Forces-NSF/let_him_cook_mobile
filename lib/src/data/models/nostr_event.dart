import 'package:dart_nostr/nostr/model/event/event.dart';
import 'package:let_him_cook/src/data/models/recipe.dart';

extension RecipeEvent on NostrEvent {
  String get title => _getTagValue('title')!;
  String get author => _getTagValue('author') ?? pubkey;
  List<String> get cuisine => _getTags('cuisine');
  List<String> get categories => _getTags('category');
  Map<String, String> get ingredients => _getTagMap('ingredient');
  List<String> get tools => _getTags('tool');
  List<String> get images => _getTags('image');
  String? get prepTime => _getTagValue('prep_time');
  String? get cookTime => _getTagValue('cook_time');
  String? get servings => _getTagValue('servings');
  Map<String, String> get nutrition => _getTagMap('nutrition');
  List<String> get dietaryRestrictions => _getTags('dietary_restrictions');
  String? get summary => _getTagValue('summary');
  List<String> get hashTags => _getTags('t');

  List<String> get directions => content!.split('\n');

  Map<String, String> get relatedRecipes => {
    
  };

  String? _getTagValue(String key) {
    final tag = tags?.firstWhere((t) => t[0] == key, orElse: () => []);
    return (tag != null && tag.length > 1) ? tag[1] : null;
  }

  List<String> _getTags(String key) {
    final tagList = tags?.where((t) => t[0] == key).map((l) {
      return '${l.length > 2 ? l[2] : ""} ${l[1]}'.trim();
    });
    return tagList != null ? tagList.toList() : [];
  }

  Map<String, String> _getTagMap(String key) {
    final tagList = tags?.where((t) => t[0] == key).map((l) {
      return MapEntry(l[1], l[2]);
    });
    return tagList != null ? Map.fromEntries(tagList) : {};
  }

  Recipe toRecipe() {
    return Recipe(
      id: id!,
      title: title,
      categories: categories,
      ingredients: ingredients,
      images: images,
      directions: directions,
      author: author,
      cuisine: cuisine,
      prepTime: prepTime,
      cookTime: cookTime,
      servings: servings,
      nutrition: nutrition,
      dietaryRestrictions: dietaryRestrictions,
      summary: summary,
      tools: tools,
      tags: hashTags,
    );
  }
}
