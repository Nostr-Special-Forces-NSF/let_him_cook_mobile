import 'dart:async';
import 'dart:math';
import 'dart:convert';
import 'package:dart_nostr/dart_nostr.dart';
import 'package:let_him_cook/src/services/nostr_service.dart';
import 'package:nip44/nip44.dart';

/// A minimal plugin that demonstrates the NIP-46 flow:
/// 1) ephemeral keypair generation
/// 2) connecting to a remote signer on one or more relays
/// 3) sending requests as kind=24133 events with NIP-44 encryption
/// 4) receiving and decrypting the remote signer’s responses
class RemoteSignerPlugin {
  final NostrService nostrService;

  String? remoteSignerPubkey;

  String? _clientSecretKey;
  String? _clientPubkey;

  final _pendingRequests = <String, Completer<Map<String, dynamic>>>{};

  bool _connected = false;

  RemoteSignerPlugin(this.nostrService);

  /// Connect to the remote signer via the specified relays.
  /// Generates ephemeral keys, opens relay connections, and subscribes
  /// for any kind=24133 events from the remote signer to handle responses.
  Future<void> connect() async {
    // Generate ephemeral key pair.
    final keyPair = Nostr.instance.services.keys.generateKeyPair();

    _clientSecretKey = keyPair.private;
    _clientPubkey = keyPair.public;

    // Subscribe for events from the remote-signer:
    // We need to watch for kind=24133 events that are p-tagged with our ephemeral pubkey.
    final filter = NostrFilter(
      kinds: [24133],
      // Use #p to filter events that p-tag our ephemeral pubkey if your library supports it.
      // The dart_nostr library doesn’t yet have an explicit param for #p filter,
      // so you might either omit or do an extended filter that matches "tags":[["p",_clientPubkey],..].
      since: DateTime.now().subtract(const Duration(seconds: 5)), // optional
    );
    final stream = nostrService.subscribeToEvents(filter);
    stream.listen(_handleIncomingEvent);

    _connected = true;
  }

  Future<void> disconnect() async {
    _connected = false;
  }

  Future<String> getPublicKey() async {
    final response = await request('get_public_key', []);
    final pubkey = response['result'];
    if (pubkey == null) {
      throw Exception('Remote signer get_public_key returned null');
    }
    return pubkey;
  }

  Future<Map<String, dynamic>> signEvent(Map<String, dynamic> event) async {
    // Param must be a single JSON-serialized event in an array, e.g. [ "..." ]
    final eventJson = jsonEncode(event);
    final response = await request('sign_event', [eventJson]);
    final resultStr = response['result'];
    if (resultStr == null) {
      throw Exception('No result from sign_event');
    }
    // The remote signer typically returns the *fully signed event* as a JSON string.
    final signedEvent = jsonDecode(resultStr) as Map<String, dynamic>;
    return signedEvent;
  }

  /// The main method that sends a NIP-46 JSON-RPC request:
  /// 1) Build JSON: { id, method, params }
  /// 2) Encrypt content via NIP-44
  /// 3) Publish a kind=24133 event referencing the remote signer pubkey
  /// 4) Return a Future that completes when the remote signer responds
  Future<Map<String, dynamic>> request(
    String methodName,
    List<String> params,
  ) async {
    if (!_connected) {
      throw Exception('RemoteSignerPlugin not connected');
    }
    if (remoteSignerPubkey == null || remoteSignerPubkey!.isEmpty) {
      // If you truly don’t know it, you might do a "connect" handshake
      // or discover it from the remote signer’s response pubkey.
      throw Exception('remoteSignerPubkey is not set!');
    }

    final requestId = _randomId();
    final nowSec = DateTime.now().millisecondsSinceEpoch ~/ 1000;

    final payload = {
      'id': requestId,
      'method': methodName,
      'params': params,
    };
    final plainText = jsonEncode(payload);

    // 1) Encrypt (NIP-44) with ephemeral keys => ciphertext
    final cipherText = await Nip44.encryptMessage(
      plainText,
      _clientSecretKey!,
      remoteSignerPubkey!,
    );

    // 2) Build a NostrEvent for kind=24133
    final event = NostrEvent.fromPartialData(
      kind: 24133,
      content: cipherText,
      createdAt: DateTime.fromMillisecondsSinceEpoch(nowSec * 1000),
      tags: [
        // p-tag the remote signer’s pubkey
        ['p', remoteSignerPubkey!],
      ],
      // ephemeral pubkey — we’ll fill in after signing
      keyPairs: NostrKeyPairs(private: _clientSecretKey!),
    );

    // 4) Store a completer so we can wait for the response
    final completer = Completer<Map<String, dynamic>>();
    _pendingRequests[requestId] = completer;

    // 5) Publish via NostrService
    await nostrService.publishEvent(event);

    // 6) Return future that will complete when the remote signer responds
    return completer.future;
  }

  /// Called whenever a new event from `subscribeToEvents` arrives.
  /// We'll try to decrypt if it’s kind=24133, p-tagging our ephemeral pubkey, etc.
  Future<void> _handleIncomingEvent(NostrEvent e) async {
    if (e.kind != 24133) return;
    if (e.pubkey == _clientPubkey) return; // skip if we ourselves published it

    // Check if e.tags has ["p", <_clientPubkey>] => means it’s for us
    final isForUs =
        e.tags?.any((t) => t.length > 1 && t[0] == 'p' && t[1] == _clientPubkey) ?? false;
    if (!isForUs) return;

    // Decrypt
    String decrypted;
    try {
      decrypted = await Nip44.decryptMessage(
        e.content!,
        _clientSecretKey!,
        e.pubkey,
      );
    } catch (err) {
      // Could not decrypt => skip or handle error
      return;
    }

    Map<String, dynamic>? jsonMsg;
    try {
      jsonMsg = jsonDecode(decrypted) as Map<String, dynamic>;
    } catch (_) {
      return; // not valid JSON
    }

    final requestId = jsonMsg['id'] as String?;
    if (requestId == null) return;

    final completer = _pendingRequests.remove(requestId);
    if (completer != null && !completer.isCompleted) {
      // E.g. { "id": "abcd1234", "result": "...", "error": "..." }
      completer.complete(jsonMsg);
    }
  }

  String _randomId() {
    const chars = 'abcdefghijklmnopqrstuvwxyz0123456789';
    final rand = Random.secure();
    return List.generate(8, (_) => chars[rand.nextInt(chars.length)]).join();
  }
}
