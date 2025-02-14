import 'package:dart_nostr/dart_nostr.dart';
import 'package:html/parser.dart' as html;
import 'dart:convert';

class RecipeImporter {
  NostrEvent convert(String htmlContent) {
    final schemaJsonString = _extractSchemaJson(htmlContent);
    if (schemaJsonString == null) {
      throw Exception(
          'No <script type="application/ld+json"> with @context=schema.org found.');
    }

    final dynamic decoded = json.decode(schemaJsonString);

    // Usually, the root might be an object with "@graph" or a single object with "@type": "Recipe".
    // We'll find the relevant recipe JSON object.
    final recipeObj = _findRecipeNode(decoded);
    if (recipeObj == null) {
      throw Exception('No "@type": "Recipe" node found in the JSON.');
    }

    // 4) Convert to a NostrEvent.
    return _convertSchemaOrgRecipeToNostrEvent(recipeObj);
  }

  String? _extractSchemaJson(String htmlContent) {
    final document = html.parse(htmlContent);
    final scripts =
        document.querySelectorAll('script[type="application/ld+json"]');
    for (final script in scripts) {
      final jsonText = script.text.trim();
      if (jsonText.contains('"@context":') && jsonText.contains('"Recipe')) {
        return jsonText;
      }
    }
    return null; // Not found
  }

  /// If the JSON has `"@graph": [ ... ]`, we need to search within that array for a node
  /// with `"@type": "Recipe"`.
  dynamic _findRecipeNode(dynamic decoded) {
    // If top-level is an object and has "@type": "Recipe", return it.
    if (decoded is Map<String, dynamic>) {
      if (decoded['@type'] == 'Recipe') {
        return decoded;
      }
      // If it has "@graph", search within that.
      final graph = decoded['@graph'];
      if (graph is List) {
        for (final item in graph) {
          if (item is Map && item['@type'] == 'Recipe') {
            return item;
          }
        }
      }
      return null;
    }

    // If top-level is a list, search each item
    if (decoded is List) {
      for (final item in decoded) {
        final found = _findRecipeNode(item);
        if (found != null) return found;
      }
    }

    return null;
  }

  /// Convert the schema.org "Recipe" JSON into a minimal NostrEvent
  /// ignoring "recipeInstructions" from the tags and putting them
  /// as event content.
  NostrEvent _convertSchemaOrgRecipeToNostrEvent(
      Map<String, dynamic> recipeJson) {
    String content = '';
    List<List<String>> tags = [[]];

    // For each JSON key, add a tag. Except for `recipeInstructions`.
    // We'll store instructions in the event content.
    for (final entry in recipeJson.entries) {
      final key = entry.key;
      final value = entry.value;

      if (key == 'recipeInstructions') {
        // Our rule: Put instructions in event.content, flattening to a single text block.
        final instructions = _flattenInstructions(value);
        content = instructions;
      } else {
        // Otherwise store as a tag: e.g. ['title', 'No-Knead Crusty White Bread']
        // Obviously you'd want to sanitize or handle arrays vs strings, etc.
        final stringValue = _stringify(value);
        tags.add([key, stringValue]);
      }
    }
    // Create a minimal NostrEvent. Typically we set `kind=35000` for recipes, etc.
    final event = NostrEvent.fromPartialData(
      kind: 35000,
      content: content,
      tags: tags,
    );

    // Possibly rename some keys or do more custom logic here
    return event;
  }

  /// Flatten instructions which might be a string, list of strings, or list of objects.
  /// Return a single text block with each step on its own line.
  String _flattenInstructions(dynamic raw) {
    if (raw is String) {
      return raw;
    } else if (raw is List) {
      // Some recipes store instructions as an array of strings or array of objects
      final lines = <String>[];
      for (final item in raw) {
        if (item is String) {
          lines.add(_cleanLineNumbers(item));
        } else if (item is Map && item['text'] is String) {
          lines.add(_cleanLineNumbers(item['text']));
        }
      }
      return lines.join('\n');
    } else if (raw is Map && raw['text'] is String) {
      // single object with text
      return _cleanLineNumbers(raw['text']);
    }
    return '';
  }

  /// Optionally strip markdown line numbers like `1. Step`.
  /// Adjust to your preference.
  String _cleanLineNumbers(String text) {
    return text.replaceAll(RegExp(r'^\d+\.\s*', multiLine: true), '');
  }

  /// Attempt to turn an object or array into a single string for the tag value
  String _stringify(dynamic value) {
    if (value == null) return '';
    if (value is String) return value;
    if (value is num) return value.toString();
    if (value is bool) return value.toString();
    // If it's a list or map, JSON-encode it
    return json.encode(value);
  }
}
