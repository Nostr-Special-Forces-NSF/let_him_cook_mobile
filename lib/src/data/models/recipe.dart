class Recipe {
  final String id;
  final String title;
  final String author;
  List<String> cuisine;
  final List<String> categories;
  final Map<String, String> ingredients;
  List<String> tools;
  final List<String> images;
  String? prepTime;
  String? cookTime;
  String? servings;
  Map<String, String> nutrition;
  List<String> dietaryRestrictions;
  String? summary;
  List<String> tags;

  final List<String> directions;
  final Map<String, String> relatedRecipes;


  int likes;
  int zaps;
  final bool isPublishing;

  Recipe({
    required this.id,
    required this.title,
    required this.categories,
    required this.ingredients,
    required this.images,
    required this.directions,
    required this.author,
    required this.cuisine,
    this.prepTime,
    this.cookTime,
    this.servings,
    this.nutrition = const {},
    this.dietaryRestrictions = const [],
    this.summary,
    this.tools = const [],
    this.tags = const [],
    this.relatedRecipes = const {},
    this.likes = 0,
    this.zaps = 0,
    this.isPublishing = false,
  });

  Recipe copyWith({
    String? id,
    String? title,
    String? author,
    List<String>? cuisine,
    List<String>? categories,
    Map<String, String>? ingredients,
    List<String>? tools,
    List<String>? images,
    String? prepTime,
    String? cookTime,
    String? servings,
    Map<String, String>? nutrition,
    List<String>? dietaryRestrictions,
    String? summary,
    List<String>? tags,
    List<String>? directions,
    Map<String, String>? relatedRecipes,
    int? likes,
    int? zaps,
    bool? isPublishing,
  }) {
    return Recipe(
      id: id ?? this.id,
      title: title ?? this.title,
      author: author ?? this.author,
      cuisine: cuisine ?? this.cuisine,
      categories: categories ?? this.categories,
      ingredients: ingredients ?? this.ingredients,
      tools: tools ?? this.tools,
      images: images ?? this.images,
      prepTime: prepTime ?? this.prepTime,
      cookTime: cookTime ?? this.cookTime,
      servings: servings ?? this.servings,
      nutrition: nutrition ?? this.nutrition,
      dietaryRestrictions: dietaryRestrictions ?? this.dietaryRestrictions,
      summary: summary ?? this.summary,
      tags: tags ?? this.tags,
      directions: directions ?? this.directions,
      relatedRecipes: relatedRecipes ?? this.relatedRecipes,
      likes: likes ?? this.likes,
      zaps: zaps ?? this.zaps,
      isPublishing: isPublishing ?? this.isPublishing,
    );
  }

  Recipe.empty()
      : this(
          id: '',
          title: '',
          author: '',
          cuisine: [],
          categories: [],
          images: [],
          ingredients: {},
          directions: [],
          tools: [],
        );

  Map<String, dynamic> toJson() {
    return {
      'kind': 35000,
      'content' : directions.join('\n'),
      'tags': [
        ['d', title.replaceAll(' ', '-').toLowerCase()],
        ['title', title],
        ['alt', 'recipe:$title'],
        ...cuisine.map((e) => ['cuisine', e]),
        ...categories.map((e) => ['category', e]),
        ...ingredients.entries.map((e) => ['ingredient', e.key, e.value]),
        ...tools.map((e) => ['tool', e]),
        ...images.map((e) => ['image', e]),
        ['prep_time', prepTime],
        ['cook_time', cookTime],
        ['servings', servings],
        ...nutrition.entries.map((e) => ['nutrition', e.key, e.value]),
        ...dietaryRestrictions.map((e) => ['dietary_restrictions', e],),
        ['summary', summary],
        ...tags.map((e) => ['t', e],),
        ...relatedRecipes.entries.map((e) => ['a', e.value]),
      ], 
    };
  }

}
