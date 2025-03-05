import 'package:dart_nostr/dart_nostr.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:let_him_cook/src/data/models/nostr_event.dart';
import 'package:let_him_cook/src/shared/providers/providers.dart';

final recipesProvider = StreamProvider((ref) {
  final recipesRepo = ref.watch(recipeRepositoryProvider);
  recipesRepo.subscribeToRecipes();
  return recipesRepo.recipeStream;
});

final allRecipesProvider = Provider<List<NostrEvent>>((ref) {
  final recipesAsync = ref.watch(recipesProvider);
  return recipesAsync.maybeWhen(
      orElse: () => [],
      data: (recipes) {
        return recipes;
      });
});

final embeddedRecipesProvider =
    Provider.family<List<NostrEvent>, List<String>>((ref, addresses) {
  final all = ref.watch(allRecipesProvider);
  final subRecipes = all.where((event) {
    final evtAddress = event.address;
    return evtAddress != null && addresses.contains(evtAddress);
  }).toList();
  return subRecipes;
});
