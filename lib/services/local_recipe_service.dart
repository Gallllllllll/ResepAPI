import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/recipe_model.dart';

class LocalRecipeService {
  static const String _keyLocalRecipes = 'local_recipes';

  // Create
  static Future<void> createRecipe(Recipe recipe) async {
    final prefs = await SharedPreferences.getInstance();
    List<String> recipes = prefs.getStringList(_keyLocalRecipes) ?? [];
    recipes.add(jsonEncode(recipe.toMap()));
    await prefs.setStringList(_keyLocalRecipes, recipes);
  }

  // Read
  static Future<List<Recipe>> getRecipes() async {
    final prefs = await SharedPreferences.getInstance();
    List<String> recipes = prefs.getStringList(_keyLocalRecipes) ?? [];
    return recipes.map((e) => Recipe.fromMap(jsonDecode(e))).toList();
  }

  // Update
  static Future<void> updateRecipe(Recipe recipe) async {
    final prefs = await SharedPreferences.getInstance();
    List<String> recipes = prefs.getStringList(_keyLocalRecipes) ?? [];
    int index = recipes.indexWhere((e) => Recipe.fromMap(jsonDecode(e)).id == recipe.id);
    if (index != -1) {
      recipes[index] = jsonEncode(recipe.toMap());
      await prefs.setStringList(_keyLocalRecipes, recipes);
    }
  }

  // Delete
  static Future<void> deleteRecipe(int id) async {
    final prefs = await SharedPreferences.getInstance();
    List<String> recipes = prefs.getStringList(_keyLocalRecipes) ?? [];
    recipes.removeWhere((e) => Recipe.fromMap(jsonDecode(e)).id == id);
    await prefs.setStringList(_keyLocalRecipes, recipes);
  }
}
