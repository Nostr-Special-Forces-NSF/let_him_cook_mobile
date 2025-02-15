import 'dart:async';
import 'dart:convert';
import 'package:dart_nostr/dart_nostr.dart';
import 'package:let_him_cook/src/data/models/bookmark_list.dart';
import 'package:let_him_cook/src/data/models/user_profile.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserRepository {
  static const _prefsKeyPubkey = 'nostr_pubkey';

  String? userPubKey;

  Future<String?> loadPubkey() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_prefsKeyPubkey);
  }

  Future<void> savePubkey(String pubkey) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefsKeyPubkey, pubkey);
  }

  Future<String?> login(String pubKey) async {
    userPubKey = pubKey;
    await savePubkey(pubKey);
    return pubKey;
  }

  Future<UserProfile?> fetchUserProfile(String pubkey) async {
    final pkHex = Nostr.instance.services.bech32.decodeBech32(pubkey);

    final request = NostrRequest(
      filters: <NostrFilter>[
        NostrFilter(
          kinds: [0],
          authors: [pkHex[0]],
          limit: 1,
        ),
      ],
    );

    final subscription = Nostr.instance.services.relays.startEventsSubscription(
      request: request,
      relays: [
        'wss://relay.primal.net',
        'wss://nos.lol',
        'wss://relay.nostrsf.org'
      ],
      onEose: (relayUrl, eoseMessage) {
        // EOSE => end of stream for this subscription
        Nostr.instance.services.relays.closeEventsSubscription(
          eoseMessage.subscriptionId,
        );
      },
    );

    final completer = Completer<UserProfile?>();

    final streamSubscription = subscription.stream.listen(
      (NostrEvent event) {
        final content = event.content;
        try {
          final data = json.decode(content!) as Map<String, dynamic>;

          final displayName = data['name'] as String?;
          final pictureUrl = data['picture'] as String?;

          final userProfile = UserProfile(
            pubkey: pubkey,
            displayName: displayName,
            pictureUrl: pictureUrl,
          );

          completer.complete(userProfile);
          Nostr.instance.services.relays.closeEventsSubscription(
            event.subscriptionId!,
          );
        } catch (e) {
          completer.completeError(e);
        }
      },
      onError: (error) {
        if (!completer.isCompleted) completer.completeError(error);
      },
    );

    final profile = await completer.future.catchError((e) {
      streamSubscription.cancel();
      return null;
    });

    streamSubscription.cancel();
    return profile;
  }

  Future<List<BookmarkList>> fetchBookmarkLists(String pubkey) async {
    final pkHex = Nostr.instance.services.bech32.decodeBech32(pubkey);

    final request = NostrRequest(
      filters: <NostrFilter>[
        NostrFilter(
          kinds: [30003],
          authors: [pkHex[0]],
        ),
      ],
    );

    final subscription = Nostr.instance.services.relays.startEventsSubscription(
      request: request,
      relays: [
        'wss://relay.primal.net',
        'wss://nos.lol',
        'wss://relay.nostrsf.org'
      ],
      onEose: (relayUrl, eoseMessage) {
        Nostr.instance.services.relays.closeEventsSubscription(
          eoseMessage.subscriptionId,
        );
      },
    );

    final completer = Completer<List<BookmarkList>>();
    final lists = <BookmarkList>[];

    final streamSubscription = subscription.stream.listen(
      (NostrEvent event) {
        String name = '';
        final aTags = <String>[];
        for (final tag in event.tags!) {
          if (tag.isNotEmpty) {
            if (tag.length > 1 && tag[0] == 'a') {
              final aValue = tag[1];
              aTags.add(aValue);
            } else if (tag.length > 1 && tag[0] == 'name') {
              name = tag[1];
            }
          }
        }

        final bookmarkList = BookmarkList(
          id: event.id!,
          name: name,
          createdAt: event.createdAt!,
          rawATags: aTags,
        );
        lists.add(bookmarkList);
      },
      onError: (error) {
        if (!completer.isCompleted) completer.completeError(error);
      },
      onDone: () {
        if (!completer.isCompleted) {
          completer.complete(lists);
        }
      },
    );

    return completer.future.whenComplete(() {
      streamSubscription.cancel();
    });
  }

  Future<List<BookmarkList>> fetchBookmarkListsAndItems(String pubkey) async {
    final bookmarkLists = await fetchBookmarkLists(pubkey);

    final allARefs = <String>[];
    for (final list in bookmarkLists) {
      allARefs.addAll(list.rawATags);
    }
    final uniqueARefs = allARefs.toSet().toList();

    if (uniqueARefs.isEmpty) {
      return bookmarkLists;
    }

    final filters = <NostrFilter>[];

    final filter = (<int>{}, <String>{}, <String>{});
    uniqueARefs.map((s) => s.split(':')).fold(
        filter,
        (p, v) =>
            ({...p.$1, int.parse(v[0])}, {...p.$2, v[1]}, {...p.$3, v[2]}));

    filters.add(
      NostrFilter(
        kinds: filter.$1.toList(),
        authors: filter.$2.toList(),
        additionalFilters: {'#d': filter.$3.toList()},
      ),
    );

    final request = NostrRequest(filters: filters);

    final subscription = Nostr.instance.services.relays.startEventsSubscription(
      request: request,
      relays: [
        'wss://relay.primal.net',
        'wss://nos.lol',
        'wss://relay.nostrsf.org'
      ],
      onEose: (relayUrl, eoseMessage) {
        // close subscription
        Nostr.instance.services.relays.closeEventsSubscription(
          eoseMessage.subscriptionId,
        );
      },
    );

    final completer = Completer<List<NostrEvent>>();
    final resolvedEvents = <NostrEvent>[];

    final sub = subscription.stream.listen(
      (NostrEvent event) {
        resolvedEvents.add(event);
      },
      onDone: () {
        if (!completer.isCompleted) {
          completer.complete(resolvedEvents);
        }
      },
      onError: (e) {
        if (!completer.isCompleted) {
          completer.completeError(e);
        }
      },
    );

    final events = await completer.future.whenComplete(() => sub.cancel());

    // 3. Attach each resolved event to the correct BookmarkList
    // We'll map them by the "kind:author:d" triple
    final eventMap = <String, NostrEvent>{};
    for (final e in events) {
      final triple = '${e.kind}:${e.pubkey}:${_extractDTag(e.tags!)}';
      eventMap[triple] = e;
    }

    // update each bookmark list
    for (final list in bookmarkLists) {
      final itemEvents = <NostrEvent>[];
      for (final aRef in list.rawATags) {
        final e = eventMap[aRef];
        if (e != null) {
          itemEvents.add(e);
        }
      }
      // set the items
      list.items = itemEvents;
    }

    return bookmarkLists;
  }

  String _extractDTag(List<List<String>> tags) {
    // Typically a tag like: ["d", "identifier"]
    // find the first tag where tag[0] == 'd'
    // or you might have a more robust approach
    for (final t in tags) {
      if (t.isNotEmpty && t[0] == 'd') {
        return t.length > 1 ? t[1] : '';
      }
    }
    return '';
  }
}
