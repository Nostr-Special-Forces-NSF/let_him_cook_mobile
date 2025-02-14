import 'package:flutter/material.dart';
import 'package:let_him_cook/src/features/import/recipe_import_screen.dart';
import 'package:let_him_cook/src/features/home/widgets/recipe_grid_screen.dart';
import 'package:let_him_cook/src/settings/settings_view.dart';

class RecipeHomeView extends StatelessWidget {
  const RecipeHomeView({super.key});

  static const routeName = '/';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Recipes'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              // Navigate to the settings page. If the user leaves and returns
              // to the app after it has been killed while running in the
              // background, the navigation stack is restored.
              Navigator.restorablePushNamed(context, SettingsView.routeName);
            },
          ),
          IconButton(
            icon: const Icon(Icons.file_download),
            onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const RecipeImportScreen(),
                  ),
                );
            },
          ),
        ],
      ),
      body: const RecipeGridScreen(),
    );
  }
}
