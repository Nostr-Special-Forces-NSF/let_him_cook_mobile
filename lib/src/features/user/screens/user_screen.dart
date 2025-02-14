// user_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:let_him_cook/src/features/user/notifiers/user_notifier.dart';

class UserScreen extends ConsumerWidget {
  const UserScreen({super.key});


  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userState = ref.watch(userNotifierProvider);
    final userNotifier = ref.read(userNotifierProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: const Text('User Profile'),
      ),
      body: userState.isLoading
          ? const Center(child: CircularProgressIndicator())
          : userState.pubkey == null
              ? _buildLoggedOutView(context, userNotifier)
              : _buildLoggedInView(context, userState, userNotifier),
    );
  }

  Widget _buildLoggedOutView(BuildContext context, UserNotifier userNotifier) {
    return Center(
      child: ElevatedButton(
        onPressed: () {
          userNotifier.login();
        },
        child: const Text('Log in with Signer App'),
      ),
    );
  }

  Widget _buildLoggedInView(
      BuildContext context, UserState userState, UserNotifier userNotifier) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // DisplayName
          if (userState.profile?.displayName != null)
            Text(
              userState.profile!.displayName!,
              style: Theme.of(context).textTheme.headlineSmall,
            ),
          const SizedBox(height: 8),
          // Avater
          if (userState.profile?.pictureUrl != null)
            CircleAvatar(
              radius: 50,
              backgroundImage: NetworkImage(userState.profile!.pictureUrl!),
            ),
          const SizedBox(height: 16),
          // Bookmarks
          Text('My Bookmarks:', style: Theme.of(context).textTheme.titleMedium),
          const Divider(),
          ...userState.bookmarks.map(
            (b) => ListTile(
              title: Text(b.title),
              onTap: () {
                // TODO: maybe open the bookmarked recipe
              },
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              userNotifier.logout();
              Navigator.pop(context); // Return to previous screen
            },
            child: const Text('Log Out'),
          ),
        ],
      ),
    );
  }
}
