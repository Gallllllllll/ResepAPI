import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/recipe_model.dart';

class BookmarkService {
  static const String _key = 'bookmarks';

  /// Mendapatkan daftar resep yang di-bookmark
  static Future<List<Recipe>> getBookmarks() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getStringList(_key) ?? [];
    return data.map((e) => Recipe.fromMap(jsonDecode(e))).toList();
  }

  /// Menambahkan resep ke bookmark
  static Future<void> addBookmark(Recipe recipe) async {
    final prefs = await SharedPreferences.getInstance();
    final list = prefs.getStringList(_key) ?? [];
    list.add(jsonEncode(recipe.toMap()));
    await prefs.setStringList(_key, list);
  }

  /// Menghapus resep dari bookmark
  static Future<void> removeBookmark(int recipeId) async {
    final prefs = await SharedPreferences.getInstance();
    final list = prefs.getStringList(_key) ?? [];
    list.removeWhere((e) => Recipe.fromMap(jsonDecode(e)).id == recipeId);
    await prefs.setStringList(_key, list);
  }

  /// Cek apakah resep sudah di-bookmark
  static Future<bool> isBookmarked(int recipeId) async {
    final prefs = await SharedPreferences.getInstance();
    final list = prefs.getStringList(_key) ?? [];
    return list.any((e) => Recipe.fromMap(jsonDecode(e)).id == recipeId);
  }
}
