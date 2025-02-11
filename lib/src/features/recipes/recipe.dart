import 'package:dart_nostr/dart_nostr.dart';

class Recipe {
  final String id;
  final String title;
  final String imageUrl;
  final List<String> ingredients;
  final List<String> directions;
  final List<String> categories;

  String? summary;
  String? author;
  String? prepTime;
  String? cookTime;
  String? servings;

  final int likes;
  final int zaps;

  Recipe({
    required this.id,
    required this.title,
    required this.imageUrl,
    required this.ingredients,
    required this.directions,
    required this.categories,
    this.summary,
    this.author,
    this.cookTime,
    this.prepTime,
    this.servings,
    this.likes = 0,
    this.zaps = 0,
  });
}

extension RecipeEvent on NostrEvent {
  String get title => _getTagValue('title')!;
  String get image => _getTagValue('image')!;
  String? get prepTime => _getTagValue('prep_time');
  String? get cookTime => _getTagValue('cook_time');
  String? get servings => _getTagValue('servings');
  String? get author => _getTagValue('author');
  String? get summary => _getTagValue('summary');

  List<String> get ingredients => _getTags('ingredient');
  List<String> get directions => content!.split('\n');
  List<String> get categories => _getTags('t');

  String? _getTagValue(String key) {
    final tag = tags?.firstWhere((t) => t[0] == key, orElse: () => []);
    return (tag != null && tag.length > 1) ? tag[1] : null;
  }

  List<String> _getTags(String key) {
    final tagList = tags?.where((t) => t[0] == key).map((l) {
      return '${l.length > 2 ? l[2] : ""} ${l[1]}';
    });
    return tagList != null ? tagList.toList() : [];
  }

  Recipe toRecipe() {
    return Recipe(
      id: id!,
      title: title,
      imageUrl: image,
      ingredients: ingredients,
      directions: directions,
      categories: categories,
      summary: summary,
      author: author,
      prepTime: prepTime,
      cookTime: cookTime,
      servings: servings,
    );
  }
}
