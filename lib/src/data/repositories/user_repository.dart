import 'dart:convert';

import 'package:let_him_cook/src/data/models/bookmark.dart';
import 'package:let_him_cook/src/data/models/user_profile.dart';
import 'package:logger/logger.dart';
import 'package:nip55/signer_plugin.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserRepository {
  static const _prefsKeyPubkey = 'nostr_pubkey';
  final _logger = Logger();
  final nip55 = SignerPlugin();

  Future<String?> loadPubkey() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_prefsKeyPubkey);
  }

  Future<void> savePubkey(String pubkey) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefsKeyPubkey, pubkey);
  }

  /// Launch the Signer app (NIP-55) and retrieve the user’s pubkey.
  Future<String?> loginWithSigner() async {
    nip55.setPackageName('com.greenart7c3.nostrsigner');
    final result = await nip55.getPublicKey();

    _logger.i('Signer responde: $result');    

    final signedInPubkey = result['signature'];

    _logger.i('Fetched public key $signedInPubkey');

    if (signedInPubkey != null) {
      await savePubkey(signedInPubkey);
    }
    return signedInPubkey;
  }

  /// Fetch user profile (Kind 0) from your Nostr relay
  Future<UserProfile?> fetchUserProfile(String pubkey) async {
    return UserProfile(
      pubkey: pubkey,
      displayName: 'Chef Satoshi',
      pictureUrl: 'https://example.com/avatar.jpg',
    );
  }

  /// Fetch user’s bookmarks (Kind=30001) from your Nostr relay
  Future<List<Bookmark>> fetchBookmarks(String pubkey) async {
    // 1) Connect to relay
    // 2) Send filter for kind=30001 & author=pubkey
    // 3) Parse response
    // For demonstration, return mock data:
    return [
      Bookmark(id: '1', title: 'My Favorite Bread Recipe'),
      Bookmark(id: '2', title: 'Chocolate Cake Shortcut'),
    ];
  }
}
