import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:let_him_cook/src/data/models/bookmark.dart';
import 'package:let_him_cook/src/data/models/user_profile.dart';
import 'package:let_him_cook/src/data/repositories/user_repository.dart';

class UserState {
  final bool isLoading;
  final String? pubkey;
  final UserProfile? profile;
  final List<Bookmark> bookmarks;
  final String? error;

  UserState({
    this.isLoading = false,
    this.pubkey,
    this.profile,
    this.bookmarks = const [],
    this.error,
  });

  UserState copyWith({
    bool? isLoading,
    String? pubkey,
    UserProfile? profile,
    List<Bookmark>? bookmarks,
    String? error,
  }) {
    return UserState(
      isLoading: isLoading ?? this.isLoading,
      pubkey: pubkey ?? this.pubkey,
      profile: profile ?? this.profile,
      bookmarks: bookmarks ?? this.bookmarks,
      error: error,
    );
  }
}

class UserNotifier extends StateNotifier<UserState> {
  final UserRepository _repository;

  UserNotifier(this._repository) : super(UserState()) {
    // Load existing pubkey from prefs
    _init();
  }

  Future<void> _init() async {
    state = state.copyWith(isLoading: true);
    try {
      final storedPubkey = await _repository.loadPubkey();
      if (storedPubkey != null) {
        // user is logged in
        state = state.copyWith(pubkey: storedPubkey);
        await fetchProfileAndBookmarks(storedPubkey);
      }
    } catch (e) {
      state = state.copyWith(error: e.toString());
    } finally {
      state = state.copyWith(isLoading: false);
    }
  }

  /// Called when user taps "Log in with Signer App"
  Future<void> login() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final pubkey = await _repository.loginWithSigner();
      if (pubkey != null) {
        state = state.copyWith(pubkey: pubkey);
        await fetchProfileAndBookmarks(pubkey);
      }
    } catch (e) {
      state = state.copyWith(error: e.toString());
    } finally {
      state = state.copyWith(isLoading: false);
    }
  }

  /// Fetch user profile & bookmarks from Nostr
  Future<void> fetchProfileAndBookmarks(String pubkey) async {
    try {
      final profile = await _repository.fetchUserProfile(pubkey);
      final bookmarks = await _repository.fetchBookmarks(pubkey);
      state = state.copyWith(profile: profile, bookmarks: bookmarks);
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  /// Logout
  Future<void> logout() async {
    state = UserState(isLoading: false);
    // you might also remove the pubkey from prefs
  }
}

// Provide the Notifier
final userNotifierProvider = StateNotifierProvider<UserNotifier, UserState>(
  (ref) => UserNotifier(UserRepository()),
);
