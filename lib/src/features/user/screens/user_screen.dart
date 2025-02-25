import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:let_him_cook/src/features/user/notifiers/user_notifier.dart';
import 'package:nip55/signer_app_info.dart';
import 'package:nip55/signer_plugin.dart';

class UserScreen extends ConsumerStatefulWidget {
  
  const UserScreen({super.key});

  @override
  ConsumerState<UserScreen> createState() => _UserScreenState();
}

class _UserScreenState extends ConsumerState<UserScreen> {
  final nip55 = SignerPlugin();

  List<SignerAppInfo> _signerApps = [];
  bool _isLoadingApps = false;

  @override
  void initState() {
    super.initState();
    _loadSignerApps();
  }

  Future<void> _loadSignerApps() async {
    setState(() => _isLoadingApps = true);
    final apps = await nip55.getInstalledSignerApps();
    setState(() {
      _signerApps = apps;
      _isLoadingApps = false;
    });
  }

  Future<void> _loginWithApp(SignerAppInfo app) async {
    final userNotifier = ref.read(userNotifierProvider.notifier);

    try {
      await nip55.setPackageName(app.packageName);
      final result = await nip55.getPublicKey();
      final userPubkey = result['signature'];
      if (userPubkey != null) {
        await userNotifier.login(userPubkey);
      } else {
        throw Exception('Failed to login with ${app.name}');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Login failed: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final userState = ref.watch(userNotifierProvider);
    final userNotifier = ref.read(userNotifierProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: const Text('User Profile'),
      ),
      body: userState.isLoading
          ? const Center(child: CircularProgressIndicator())
          : userState.pubkey == null
              ? _buildLoggedOutView(context, userNotifier, userState)
              : _buildLoggedInView(context, userState, userNotifier),
    );
  }

  Widget _buildLoggedOutView(
      BuildContext context, UserNotifier userNotifier, UserState userState) {
    if (_isLoadingApps) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_signerApps.isEmpty) {
      return Center(
        child: ElevatedButton(
          onPressed: _loadSignerApps,
          child: const Text('No signer apps found. Refresh?'),
        ),
      );
    }

    // Show a list of installed NIP-55 signer apps
    return Center(
      child: ListView.builder(
        shrinkWrap: true,
        itemCount: _signerApps.length,
        itemBuilder: (context, index) {
          final app = _signerApps[index];
          return ListTile(
            leading: Image.memory(
              base64Decode(app.iconData),
              width: 40,
              height: 40,
              errorBuilder: (ctx, e, stack) {
                return const Icon(Icons.android);
              },
            ),
            title: Text(app.name),
            subtitle: Text(app.packageName),
            onTap: () => _loginWithApp(app),
          );
        },
      ),
    );
  }

  Widget _buildLoggedInView(
      BuildContext context, UserState userState, UserNotifier userNotifier) {

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Avater
          if (userState.profile?.pictureUrl != null)
            CircleAvatar(
              radius: 50,
              backgroundImage: NetworkImage(userState.profile!.pictureUrl!),
            ),
          const SizedBox(height: 16),
          // DisplayName
          if (userState.profile?.displayName != null)
            Text(
              userState.profile!.displayName!,
              style: Theme.of(context).textTheme.headlineSmall,
            ),
          const SizedBox(height: 8),
          // Bookmarks
          Text('My Bookmarks:', style: Theme.of(context).textTheme.titleMedium),
          const Divider(),
          ...userState.bookmarks.map(
            (b) => ListTile(
              title: Text(b.name),
              onTap: () {
                // maybe open or do something with the bookmarked item
              },
            ),
          ),
          const SizedBox(height: 16),

          // Logout
          ElevatedButton(
            onPressed: () {
              userNotifier.logout();
              Navigator.pop(context);
            },
            child: const Text('Log Out'),
          ),
        ],
      ),
    );
  }
}
