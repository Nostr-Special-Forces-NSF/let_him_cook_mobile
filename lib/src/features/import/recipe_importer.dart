import 'package:html/parser.dart' as html;
import 'dart:convert';

class RecipeImporter {


  Map<String, dynamic> convert(String htmlContent) {
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

    return recipeObj;
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

}
