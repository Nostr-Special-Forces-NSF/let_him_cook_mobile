import 'package:dart_nostr/dart_nostr.dart';

class BookmarkList {
  final String id;
  final String name;
  final DateTime createdAt;
  final List<String> rawATags;
  List<NostrEvent> items;

  BookmarkList({
    required this.id,
    required this.name,
    required this.createdAt,
    required this.rawATags,
    this.items = const [],
  });
}
