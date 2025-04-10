import 'package:dart_nostr/dart_nostr.dart';
import 'package:flutter/material.dart';
import 'package:let_him_cook/src/data/models/nostr_event.dart';
import 'package:let_him_cook/src/features/recipe/screens/recipe_detail_view.dart';

class RecipeCard extends StatelessWidget {
  final NostrEvent recipe;
  const RecipeCard({super.key, required this.recipe});

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => RecipeDetailView(recipe: recipe),
            ),
          );
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Recipe image
            AspectRatio(
              aspectRatio: 16 / 9,
              child: Image.network(
                recipe.images.isNotEmpty ? recipe.images[0] : '',
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return const Center(child: Icon(Icons.broken_image));
                },
              ),
            ),
            // Title
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                recipe.title,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            // Likes and Zaps
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Row(
                children: [
                  // Likes
                  const Icon(Icons.thumb_up, size: 16, color: Colors.grey),
                  const SizedBox(width: 4),
                  const Text('0'),
                  const SizedBox(width: 16),
                  // Zaps (Lightning Bolt icon)
                  Icon(
                    Icons.bolt,
                    size: 16,
                    color: Colors.yellow[700],
                  ),
                  const SizedBox(width: 4),
                  const Text('0'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
