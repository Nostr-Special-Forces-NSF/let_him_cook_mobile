import 'dart:async';
import 'package:dart_nostr/dart_nostr.dart';
import 'package:let_him_cook/src/data/models/recipe.dart';
import 'package:let_him_cook/src/services/nostr_service.dart';
import 'package:logger/logger.dart';

class RecipeRepository {
  final NostrService _nostrService;
  final Map<String, NostrEvent> _events = {};
  final StreamController<List<NostrEvent>> _eventStreamController =
      StreamController.broadcast();
  StreamSubscription<NostrEvent>? _subscription;
  final _logger = Logger();

  RecipeRepository(this._nostrService);

  void subscribeToRecipes() {
    _subscription?.cancel();

    var filter = const NostrFilter(
      kinds: [35000],
    );
    
    _subscription = _nostrService.subscribeToEvents(filter).listen((event) {
      _events[event.id!] = event;
      _eventStreamController.add(_events.values.toList());
    }, onError: (error) {
      _logger.e('Error in order subscription: $error');
    });
  }

  Stream<List<NostrEvent>> get nostrEventStream =>
      _eventStreamController.stream;

  // Expose a stream of Recipe lists
  Stream<List<NostrEvent>> get recipeStream {
    return nostrEventStream;
  }

  void dispose() {
    _subscription?.cancel();
    _eventStreamController.close();
    _events.clear();
  }

  Future<void> publishRecipe(Recipe recipe) async {

    final recipeJson = recipe.toJson();
    await _nostrService.signAndPublishEvent(recipeJson);

  }
  
}
