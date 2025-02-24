import 'package:flutter/material.dart';
import 'package:let_him_cook/src/features/edit/screens/recipe_edit_screen.dart';
import 'package:let_him_cook/src/features/home/widgets/action_button.dart';
import 'package:let_him_cook/src/features/home/widgets/expandable_fab.dart';
import 'package:let_him_cook/src/features/import/recipe_import_screen.dart';
import 'package:let_him_cook/src/features/home/widgets/recipe_grid_screen.dart';
import 'package:let_him_cook/src/features/user/screens/user_screen.dart';
import 'package:let_him_cook/src/features/user/widgets/user_avatar.dart';
import 'package:let_him_cook/src/settings/settings_view.dart';

class RecipeHomeView extends StatelessWidget {
  const RecipeHomeView({super.key});

  static const routeName = '/';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Let Him Cook'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.restorablePushNamed(context, SettingsView.routeName);
            },
          ),            const SizedBox(width: 8),

          UserAvatar(() {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const UserScreen()),
            );
          }),
        ],
      ),
      body: const RecipeGridScreen(),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      floatingActionButton: ExpandableFab(
        distance: 90,
        children: [
          ActionButton(
            onPressed: () => {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const RecipeEditScreen()),
              )
            },
            icon: const Icon(Icons.restaurant),
          ),
          ActionButton(
            onPressed: () => {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const RecipeImportScreen(),
                ),
              )
            },
            icon: const Icon(Icons.copy),
          ),
          ActionButton(
            onPressed: () => {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const RecipeImportScreen(),
                ),
              )
            },
            icon: const Icon(Icons.file_download),
          ),
        ],
      ),
    );
  }
}
