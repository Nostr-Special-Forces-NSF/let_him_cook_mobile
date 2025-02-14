import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:let_him_cook/src/features/user/notifiers/user_notifier.dart';

class UserAvatar extends ConsumerWidget {
  final GestureTapCallback onPressed;

  const UserAvatar(this.onPressed, {super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userState = ref.watch(userNotifierProvider);

    // Avatar or default icon
    return GestureDetector(
      onTap: onPressed,
      child: Padding(
        padding: const EdgeInsets.only(right: 16.0),
        child: _buildAvatar(userState),
      ),
    );
  }

  Widget _buildAvatar(UserState userState) {
    if (userState.pubkey == null) {
      // Not logged in
      return const CircleAvatar(
        child: Icon(Icons.person_outline),
      );
    } else {
      // Logged in, user profile might have a pictureUrl
      final picUrl = userState.profile?.pictureUrl;
      if (picUrl != null && picUrl.isNotEmpty) {
        return CircleAvatar(
          backgroundImage: NetworkImage(picUrl),
        );
      } else {
        return const CircleAvatar(
          child: Icon(Icons.person),
        );
      }
    }
  }
}
