import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import 'package:let_him_cook/src/data/models/tag.dart';

Future<List<Tag>> loadDietaryRestrictionsTags() async {
  return await _loadTags('assets/data/dietary_restrictions_tags.json');
}

Future<List<Tag>> loadToolTags() async {
  return await _loadTags('assets/data/tool_tags.json');
}

Future<List<Tag>> loadRecipeTags() async {
  return await _loadTags('assets/data/recipe_tags.json');
}

Future<List<Tag>> _loadTags(String path) async {
  final dataString = await rootBundle.loadString(path);
  final List<dynamic> jsonList = json.decode(dataString);

  return jsonList.map((entry) {
    return Tag.fromJson(entry as Map<String, dynamic>);
  }).toList();
}
