import 'package:dart_nostr/dart_nostr.dart';
import 'package:flutter/material.dart';
import 'package:let_him_cook/src/features/recipes/recipe.dart';
import 'package:let_him_cook/src/features/recipes/recipe_edit_screen.dart';

class RecipeDetailView extends StatelessWidget {
  final NostrEvent recipe;

  const RecipeDetailView({super.key, required this.recipe});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2, // We have 2 tabs: Ingredients & Directions
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.of(context).pop(),
          ),
          title: Text(recipe.title),
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
              onPressed: () {
                // TODO: Handle favorite/like logic
              },
            ),
            TextButton(
              onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => RecipeEditScreen(recipe: recipe),
            ),
          );
              },
              child: const Text(
                'EDIT',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
        body: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // -- Recipe Header / Summary
              _buildRecipeHeader(context),

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

  // A widget that shows the main recipe image, rating (or likes/zaps),
  // category, author, times, difficulty, etc.
  Widget _buildRecipeHeader(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Main image
        AspectRatio(
          aspectRatio: 16 / 9,
          child: Image.network(
            recipe.image,
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
              // Title
              Text(
                recipe.title,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 8),
              // Category, e.g. "Cakes, Desserts"
              if (recipe.categories.isNotEmpty) ...[
                Wrap(
                  spacing: 8.0,
                  runSpacing: 4.0,
                  children: recipe.categories.map((cat) {
                    return ActionChip(
                      label: Text(cat),
                      onPressed: () {
                        // TODO: Show a filtered page or perform any action
                        // e.g., Navigator.push(...) to a "FilteredRecipeScreen(cat)"
                      },
                    );
                  }).toList(),
                ),
              ],
              const SizedBox(height: 16),
              Text(
                recipe.summary ?? '',
              ),
              const SizedBox(height: 4),
              // Author
              Text(
                recipe.author ?? '',
                style: Theme.of(context).textTheme.bodySmall,
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Row(
                    children: [
                      Icon(Icons.thumb_up, size: 16),
                      SizedBox(width: 4),
                      Text('0'),
                    ],
                  ),
                  const SizedBox(width: 16),
                  Row(
                    children: [
                      Icon(Icons.bolt, size: 16, color: Colors.yellow[700]),
                      const SizedBox(width: 4),
                      const Text('0'),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 16),
              // Prep time, Cook time, Servings, Difficulty
              Wrap(
                spacing: 8.0,
                runSpacing: 4.0,
                children: [
                  _infoChip(Icons.timer, 'Prep ${recipe.prepTime ?? ''}'),
                  _infoChip(Icons.schedule, 'Cook ${recipe.cookTime ?? ''}'),
                  _infoChip(Icons.people, 'Serves ${recipe.servings ?? ''}'),
                  _infoChip(Icons.assignment_turned_in, 'Difficulty '),
                ],
              ),
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

  // Ingredients tab content
  Widget _buildIngredientsTab() {
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
              itemCount: recipe.ingredients.length,
              itemBuilder: (context, index) {
                final ingredient = recipe.ingredients[index];
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
      child: ListView.builder(
        itemCount: recipe.directions.length,
        itemBuilder: (context, index) {
          final step = recipe.directions[index];
          return ListTile(
            leading: CircleAvatar(child: Text('${index + 1}')),
            title: Text(step),
          );
        },
      ),
    );
  }
}
