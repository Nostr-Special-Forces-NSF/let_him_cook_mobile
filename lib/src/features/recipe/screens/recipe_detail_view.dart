import 'package:flutter/material.dart';
import 'package:dart_nostr/dart_nostr.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:let_him_cook/src/app/app_theme.dart';
import 'package:let_him_cook/src/data/models/nostr_event.dart';
import 'package:let_him_cook/src/features/edit/screens/recipe_edit_screen.dart';
import 'package:let_him_cook/src/features/recipe/widgets/nutritional_info_view.dart';
import 'package:let_him_cook/src/features/user/notifiers/user_notifier.dart';
import 'package:let_him_cook/src/shared/providers/recipes_providers.dart';
import 'package:let_him_cook/src/shared/widgets/recipe_card_widget.dart';
import 'package:markdown_widget/markdown_widget.dart';

class RecipeDetailView extends ConsumerWidget {
  final NostrEvent recipe;

  const RecipeDetailView({super.key, required this.recipe});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userState = ref.watch(userNotifierProvider);
    final isLoggedIn = true; //userState.pubkey != null;
    final embedded = ref.watch(embeddedRecipesProvider(recipe.relatedRecipes));

    return DefaultTabController(
      length: 2, // We have 2 tabs: Ingredients & Directions
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.of(context).pop(),
          ),
          title: Text('Recipe'),
          actions: [
            IconButton(
              icon: const Icon(Icons.shopping_cart),
              onPressed: () {
                // TODO: Handle shopping cart logic
              },
            ),
            IconButton(
              icon: const Icon(Icons.event),
              onPressed: () {
                // TODO: Handle calendar logic
              },
            ),
            IconButton(
              icon: const Icon(Icons.favorite_border),
              onPressed: isLoggedIn
                  ? () {
                      // TODO: Handle favorite/like logic
                    }
                  : null,
            ),
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: isLoggedIn
                  ? () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => RecipeEditScreen(recipe: recipe),
                        ),
                      );
                    }
                  : null,
            ),
          ],
        ),
        body: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // -- Recipe Header / Summary
              _buildRecipeHeader(context),

              // -- Embedded Recipes
              if (recipe.relatedRecipes.isNotEmpty)
                Text(
                  'Related Recipes',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),

              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 4,
                  crossAxisSpacing: 8.0,
                  mainAxisSpacing: 8.0,
                  childAspectRatio: 0.75,
                ),
                itemCount: embedded.length,
                itemBuilder: (context, index) {
                  final recipe = embedded[index];
                  return RecipeCard(recipe: recipe);
                },
              ),

              // -- Tabs: Ingredients / Directions
              const TabBar(
                tabs: [
                  Tab(text: 'INGREDIENTS'),
                  Tab(text: 'DIRECTIONS'),
                ],
              ),

              // -- Tab content
              SizedBox(
                // Height needed so the tab views are visible in a scrollable layout
                height: MediaQuery.of(context).size.height * 0.7,
                child: TabBarView(
                  children: [
                    _buildIngredientsTab(),
                    _buildDirectionsTab(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // A widget that shows the main recipe images via CarouselView, plus metadata (title, categories, etc.).
  Widget _buildRecipeHeader(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title
              Text(
                recipe.title,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 16),
              // Tags, e.g. "Cakes, Desserts"
              if (recipe.hashTags.isNotEmpty) ...[
                Wrap(
                  spacing: 8.0,
                  runSpacing: 4.0,
                  children: recipe.hashTags.map((cat) {
                    return ActionChip(
                      label: Text(cat),
                      onPressed: () {
                        // TODO: Filter by category
                      },
                    );
                  }).toList(),
                ),
              ],
              const SizedBox(height: 16),
              // Prep time, Cook time, Servings
              buildInfoChipRow(
                prepTime: recipe.prepTime,
                cookTime: recipe.cookTime,
                servings: recipe.servings,
              ),
            ],
          ),
        ),
        // Main images in a carousel
        AspectRatio(
          aspectRatio: 16 / 9,
          child: recipe.images.length > 1
              ? CarouselView.weighted(
                  flexWeights: [3, 1],
                  children: recipe.images.map((imageUrl) {
                    return Image.network(
                      imageUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return const Center(child: Icon(Icons.broken_image));
                      },
                    );
                  }).toList(),
                )
              : Image.network(
                  recipe.images.isEmpty ? '' : recipe.images.first,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return const Center(child: Icon(Icons.broken_image));
                  },
                ),
        ),

        // Title & metadata
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Category, e.g. "Cakes, Desserts"
              if (recipe.categories.isNotEmpty) ...[
                Wrap(
                  spacing: 8.0,
                  runSpacing: 4.0,
                  children: recipe.categories.map((cat) {
                    return ActionChip(
                      label: Text(cat),
                      onPressed: () {
                        // TODO: Filter by category
                      },
                    );
                  }).toList(),
                ),
              ],
              const SizedBox(height: 16),
              // Summary
              Text(recipe.summary ?? ''),
              const SizedBox(height: 16),
              // Author
              Row(
                children: [
                  CircleAvatar(),
                  const SizedBox(width: 8),
                  Flexible(
                    child: Text(
                      recipe.author,
                      style: Theme.of(context).textTheme.bodySmall,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              // Likes & Zaps
              const Row(
                children: [
                  Row(
                    children: [
                      Icon(Icons.thumb_up, size: 16),
                      SizedBox(width: 4),
                      Text('0'),
                    ],
                  ),
                  SizedBox(width: 16),
                  Row(
                    children: [
                      Icon(Icons.bolt, size: 16, color: Colors.yellowAccent),
                      SizedBox(width: 4),
                      Text('0'),
                    ],
                  ),
                ],
              ),

              NutritionalInfoView(
                data: recipe.nutrition,
              ),

              const SizedBox(height: 16),

              if (recipe.tools.isNotEmpty)
                Text(
                  'Tools',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ...recipe.tools.map((t) => Text(t))
            ],
          ),
        ),
      ],
    );
  }

  // Helper to build small chips for metadata
  Widget _infoChip(IconData icon, String label) {
    return Chip(
      avatar: Icon(icon, size: 16),
      label: Text(label),
    );
  }

  Widget buildInfoChipRow({
    required String? prepTime,
    required String? cookTime,
    required String? servings,
  }) {
    // Build a list of column widgets for each non-empty value
    final columns = <Widget>[];

    if (prepTime != null && prepTime.isNotEmpty) {
      columns.add(_buildInfoColumn('$prepTime minutes', 'Prep Time'));
    }
    if (cookTime != null && cookTime.isNotEmpty) {
      columns.add(_buildInfoColumn('$cookTime minutes', 'Cook Time'));
    }
    if (servings != null && servings.isNotEmpty) {
      columns.add(_buildInfoColumn(servings, 'Serves'));
    }

    // If no data present, return nothing
    if (columns.isEmpty) {
      return const SizedBox.shrink();
    }

    // Otherwise, wrap them in a single "large chip" or card-like container
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withAlpha(64),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: columns,
      ),
    );
  }

  /// Helper method that returns a column with two rows:
  /// 1) the value (e.g. "20 min")
  /// 2) the label (e.g. "Cook Time")
  Widget _buildInfoColumn(String value, String label) {
    return Expanded(
      // Each column expands evenly if you want them to share space
      // or you can remove Expanded if you prefer them to be sized by content
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            value,
            style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: LetHimCookTheme.darkPrimaryColor),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  // Ingredients tab content
  Widget _buildIngredientsTab() {
    List<String> ingredients = recipe.ingredients.entries
        .map((entry) => '${entry.key} ${entry.value}')
        .toList();

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          // "Scale & Convert" link
          Align(
            alignment: Alignment.centerLeft,
            child: TextButton.icon(
              onPressed: () {
                // TODO: Handle scaling logic
              },
              icon: const Icon(Icons.straighten),
              label: const Text('SCALE & CONVERT'),
            ),
          ),
          // List of ingredients
          Expanded(
            child: ListView.builder(
              itemCount: ingredients.length,
              itemBuilder: (context, index) {
                final ingredient = ingredients[index];
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4.0),
                  child: Text(ingredient),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // Directions tab content
  Widget _buildDirectionsTab() {
    return Padding(
        padding: const EdgeInsets.all(16.0),
        child: MarkdownWidget(data: recipe.content!));
  }
}
