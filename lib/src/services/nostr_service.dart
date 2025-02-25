import 'dart:convert';
import 'package:dart_nostr/dart_nostr.dart';
import 'package:logger/logger.dart';
import 'package:let_him_cook/src/utils/nostr_utils.dart';
import 'package:nip55/signer_plugin.dart';

class NostrService {
  static final NostrService _instance = NostrService._internal();
  factory NostrService() => _instance;
  NostrService._internal();

  final Logger _logger = Logger();
  late Nostr _nostr;
  bool _isInitialized = false;
  final nip55 = SignerPlugin();

  Future<void> init() async {
    if (_isInitialized) return;

    _nostr = Nostr.instance;
    try {
      await Nostr.instance.services.relays.init(
        relaysUrl: ['wss://relay.nostrsf.org'],
        onRelayListening: (relay, url, channel) {
          _logger.i('Connected to relay: $url');
        },
        onRelayConnectionError: (relay, error, channel) {
          _logger.w('Failed to connect to relay $relay: $error');
        },
      );
      _isInitialized = true;
      _logger.i('Nostr initialized successfully');
    } catch (e) {
      _logger.e('Failed to initialize Nostr: $e');
      rethrow;
    }
  }

  Future<void> signAndPublishEvent(Map<String, dynamic> eventJson) async {
    if (!_isInitialized) {
      throw Exception('Nostr is not initialized. Call init() first.');
    }

    await nip55.setPackageName('com.greenart7c3.nostrsigner');

    final pubKeyResult = await nip55.getPublicKey();
    final publicKey = NostrUtils.decodeNpubKeyToPublicKey(pubKeyResult['npub']);

    final dtNow = DateTime.now();
    final id = NostrUtils.generateId(eventJson);
    eventJson['id'] = '';
    eventJson['created_at'] = dtNow.millisecondsSinceEpoch ~/ 1000;
    eventJson['pubkey'] = publicKey;
    eventJson['sig'] = '';

    try {
      final signResult = await nip55.signEvent(
        jsonEncode(eventJson),
        id,
        publicKey,
      );

      final jsonMap = jsonDecode(signResult['event']);

      List<List<String>> myNestedList = (jsonMap['tags'] as List).map((inner) {
        return (inner as List).map((item) => item as String).toList();
      }).toList();

      final event = NostrEvent(
          content: jsonMap['content'],
          createdAt: dtNow,
          id: jsonMap['id'] as String,
          kind: jsonMap['kind'],
          pubkey: jsonMap['pubkey'],
          sig: jsonMap['sig'],
          tags: myNestedList);

      await _nostr.services.relays
          .sendEventToRelaysAsync(event, timeout: const Duration(seconds: 5));
      _logger.i('Event published successfully');
    } catch (e) {
      _logger.w('Failed to publish event: $e');
      rethrow;
    }
  }

  Future<void> publishEvent(NostrEvent event) async {
    if (!_isInitialized) {
      throw Exception('Nostr is not initialized. Call init() first.');
    }

    try {
      await _nostr.services.relays
          .sendEventToRelaysAsync(event, timeout: const Duration(seconds: 5));
      _logger.i('Event published successfully');
    } catch (e) {
      _logger.w('Failed to publish event: $e');
      rethrow;
    }
  }

  Stream<NostrEvent> subscribeToEvents(NostrFilter filter) {
    if (!_isInitialized) {
      throw Exception('Nostr is not initialized. Call init() first.');
    }

    final request = NostrRequest(filters: [filter]);
    final subscription =
        _nostr.services.relays.startEventsSubscription(request: request);

    return subscription.stream;
  }

  Future<void> disconnectFromRelays() async {
    if (!_isInitialized) return;

    await _nostr.services.relays.disconnectFromRelays();
    _isInitialized = false;
    _logger.i('Disconnected from all relays');
  }

  bool get isInitialized => _isInitialized;

  Future<NostrKeyPairs> generateKeyPair() async {
    final keyPair = NostrUtils.generateKeyPair();
    //await AuthUtils.savePrivateKeyAndPin(
    //    keyPair.private, ''); // Consider adding a password parameter
    return keyPair;
  }

  NostrKeyPairs generateKeyPairFromPrivateKey(String privateKey) {
    return NostrUtils.generateKeyPairFromPrivateKey(privateKey);
  }
}
