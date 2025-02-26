import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:let_him_cook/src/features/nip46/nip46_provider.dart';
import 'package:let_him_cook/src/features/nip46/remote_signer_plugin.dart';
import 'package:let_him_cook/src/features/user/notifiers/user_notifier.dart';
import 'package:let_him_cook/src/shared/providers/signer_provider.dart';
import 'package:nip55/signer_app_info.dart';
import 'package:nip55/signer_plugin.dart';

class UserScreen extends ConsumerStatefulWidget {
  const UserScreen({super.key});

  @override
  ConsumerState<UserScreen> createState() => _UserScreenState();
}

class _UserScreenState extends ConsumerState<UserScreen> {
  late SignerPlugin nip55;
  late RemoteSignerPlugin nip46;

  List<SignerAppInfo> _signerApps = [];
  bool _isLoadingApps = false;

  @override
  void initState() {
    super.initState();
    if (Platform.isAndroid) {
      _loadSignerApps();
    }
  }

  Future<void> _loadSignerApps() async {
    setState(() => _isLoadingApps = true);

    nip55 = ref.watch(signerProvider);
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

  // ─────────────────────────────────────────────────────────────────────────────
  // NIP-46 Flow:
  // ─────────────────────────────────────────────────────────────────────────────
  Future<void> _loginWithRemoteBunker() async {
    final userNotifier = ref.read(userNotifierProvider.notifier);

    nip46.remoteSignerPubkey = '79be667ef9dcbbac55a06295ce870b07029bfcdb2dce28d959f2815b16f81798';

    try {
      // 1. Connect to the remote bunker (NIP-46).
      //    E.g. nip46.connect(bunkerUri) if you have a user-provided connection token.
      await nip46.connect();

      // 2. Ask the remote bunker for the user’s real pubkey (NIP-46 get_public_key).
      final userPubkey = await nip46.getPublicKey();

      // 3. Log in using that pubkey in your app’s existing flow.
      await userNotifier.login(userPubkey);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Login with remote bunker failed: $e')),
      );
    }
  }
  // ─────────────────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final userState = ref.watch(userNotifierProvider);
    final userNotifier = ref.read(userNotifierProvider.notifier);
    nip46 = ref.watch(nip46Provider);

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
    BuildContext context,
    UserNotifier userNotifier,
    UserState userState,
  ) {
    // If we’re on Android, show the list of NIP-55 apps if any:
    if (Platform.isAndroid) {
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
      // Show a list of installed NIP-55 signer apps.
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
    } else {
      // If not Android, show a button that triggers NIP-46 remote bunker login.
      return Center(
        child: ElevatedButton(
          onPressed: _loginWithRemoteBunker,
          child: const Text('Login with NIP-46 Remote Bunker'),
        ),
      );
    }
  }

  Widget _buildLoggedInView(
    BuildContext context,
    UserState userState,
    UserNotifier userNotifier,
  ) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          if (userState.profile?.pictureUrl != null)
            CircleAvatar(
              radius: 50,
              backgroundImage: NetworkImage(userState.profile!.pictureUrl!),
            ),
          const SizedBox(height: 16),
          if (userState.profile?.displayName != null)
            Text(
              userState.profile!.displayName!,
              style: Theme.of(context).textTheme.headlineSmall,
            ),
          const SizedBox(height: 8),
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
