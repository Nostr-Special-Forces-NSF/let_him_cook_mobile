import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import 'package:html/parser.dart' as html;
import 'dart:convert';

class RecipeImportScreen extends ConsumerStatefulWidget {
  const RecipeImportScreen({super.key});

  @override
  ConsumerState<RecipeImportScreen> createState() => _RecipeImportScreenState();
}

class _RecipeImportScreenState extends ConsumerState<RecipeImportScreen> {
  final TextEditingController _urlController = TextEditingController(
    text:
        'https://www.kingarthurbaking.com/recipes/no-knead-crusty-white-bread-recipe',
  );

  bool _isLoading = false;
  NostrEvent? _nostrEvent;
  String? _errorMessage;

  Future<void> _loadAndConvert() async {
    final url = _urlController.text.trim();
    if (url.isEmpty) {
      setState(() {
        _errorMessage = 'Please enter a URL.';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _nostrEvent = null;
    });

    try {
      // 1) Fetch the page HTML (with optional custom headers).
      final htmlContent = await _fetchHtml(url);

      // 2) Parse the ld+json data from the HTML.
      final schemaJsonString = _extractSchemaJson(htmlContent);
      if (schemaJsonString == null) {
        throw Exception(
            'No <script type="application/ld+json"> with @context=schema.org found.');
      }

      // 3) Decode the JSON into a Map or a List of Maps.
      final dynamic decoded = json.decode(schemaJsonString);

      // Usually, the root might be an object with "@graph" or a single object with "@type": "Recipe".
      // We'll find the relevant recipe JSON object.
      final recipeObj = _findRecipeNode(decoded);
      if (recipeObj == null) {
        throw Exception('No "@type": "Recipe" node found in the JSON.');
      }

      // 4) Convert to a NostrEvent.
      final event = _convertSchemaOrgRecipeToNostrEvent(recipeObj);

      setState(() {
        _nostrEvent = event;
      });
    } catch (err) {
      setState(() {
        _errorMessage = err.toString();
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  /// Fetch HTML from [url], including optional headers to mimic a common browser user agent.
  Future<String> _fetchHtml(String url) async {
    final dio = Dio(
      BaseOptions(
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 10),
        headers: {
          'User-Agent':
              'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 '
                  '(KHTML, like Gecko) Chrome/114.0.0.0 Safari/537.36',
          // Add more headers if needed
        },
      ),
    );
    final response = await dio.get<String>(url);
    return response.data ?? '';
  }

  /// Extract the JSON from the <script type="application/ld+json"> that has
  /// `"@context": "https://schema.org"` or `"schema.org"` in it.
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
    final event = NostrEvent(
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Import Schema.org Recipe'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _urlController,
              decoration: const InputDecoration(
                labelText: 'Recipe URL',
                hintText: 'https://example.com/some-recipe',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _isLoading ? null : _loadAndConvert,
              icon: const Icon(Icons.upload),
              label: const Text('Load & Convert'),
            ),
            const SizedBox(height: 16),
            if (_isLoading) const CircularProgressIndicator(),
            if (_errorMessage != null)
              Text(
                _errorMessage!,
                style: const TextStyle(color: Colors.red),
              ),
            if (_nostrEvent != null) ...[
              const SizedBox(height: 16),
              const Text('Converted NostrEvent:',
                  style: TextStyle(fontWeight: FontWeight.bold)),
              _NostrEventPreview(event: _nostrEvent!),
            ],
          ],
        ),
      ),
    );
  }
}

class _NostrEventPreview extends StatelessWidget {
  final NostrEvent event;
  const _NostrEventPreview({required this.event});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(8.0),
      color: Colors.black12,
      child: Text(event.toDebugString()),
    );
  }
}

/// Minimal example NostrEvent class. In real app, use your existing event model.
class NostrEvent {
  final int kind;
  final String content;
  final List<List<String>> tags;

  NostrEvent({
    required this.kind,
    required this.content,
    required this.tags,
  });

  /// Helper method for debugging
  String toDebugString() {
    final tagsStr = tags.map((t) => t.toString()).join('\n');
    return 'kind=$kind\n'
        'content:\n$content\n\n'
        'tags:\n$tagsStr';
  }
}
