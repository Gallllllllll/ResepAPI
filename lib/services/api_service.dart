import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/recipe_model.dart';

class ApiService {
  // Search resep by name
  static Future<List<Recipe>> searchRecipes(String keyword) async {
    final url = Uri.parse('https://www.themealdb.com/api/json/v1/1/search.php?s=$keyword');
    try {
      final response = await http.get(url);
      if (response.statusCode != 200) throw Exception("Gagal load resep dari API");
      final data = jsonDecode(response.body);
      if (data['meals'] == null) return [];
      return (data['meals'] as List).map((item) {
        return Recipe(
          id: int.tryParse(item['idMeal'] ?? '0') ?? 0,
          title: item['strMeal'] ?? '',
          image: item['strMealThumb'] ?? '',
          ingredients: [
            for (int i = 1; i <= 20; i++)
              if (item['strIngredient$i'] != null &&
                  item['strIngredient$i'].toString().isNotEmpty)
                '${item['strIngredient$i']} - ${item['strMeasure$i']}'
          ],
          steps: item['strInstructions'] != null
              ? item['strInstructions'].toString().split('\n')
              : [],
        );
      }).toList();
    } catch (e) {
      print("Error searchRecipes: $e");
      return [];
    }
  }

  // Search resep by category
  static Future<List<Recipe>> searchByCategory(String category) async {
    final url = Uri.parse('https://www.themealdb.com/api/json/v1/1/filter.php?c=$category');

    try {
      final response = await http.get(url);
      if (response.statusCode != 200) throw Exception("Gagal load resep dari API");

      final data = jsonDecode(response.body);
      if (data['meals'] == null) return [];

      // data['meals'] hanya mengandung id, title, image
      return (data['meals'] as List).map((item) {
        return Recipe(
          id: int.tryParse(item['idMeal'] ?? '0') ?? 0,
          title: item['strMeal'] ?? '',
          image: item['strMealThumb'] ?? '',
          ingredients: [], // kosong, karena endpoint filter.php tidak menyediakan
          steps: [],       // kosong, karena endpoint filter.php tidak menyediakan
        );
      }).toList();
    } catch (e) {
      print("Error searchByCategory: $e");
      return [];
    }
  }

  // Optional: get detail recipe by id
  static Future<Recipe?> getRecipeById(int id) async {
    final url = Uri.parse('https://www.themealdb.com/api/json/v1/1/lookup.php?i=$id');

    try {
      final response = await http.get(url);
      if (response.statusCode != 200) throw Exception("Gagal load resep dari API");

      final data = jsonDecode(response.body);
      if (data['meals'] == null) return null;

      final item = data['meals'][0];
      return Recipe(
        id: int.tryParse(item['idMeal'] ?? '0') ?? 0,
        title: item['strMeal'] ?? '',
        image: item['strMealThumb'] ?? '',
        ingredients: [
          for (int i = 1; i <= 20; i++)
            if (item['strIngredient$i'] != null &&
                item['strIngredient$i'].toString().isNotEmpty)
              '${item['strIngredient$i']} - ${item['strMeasure$i']}'
        ],
        steps: item['strInstructions'] != null
            ? item['strInstructions'].toString().split('\n')
            : [],
      );
    } catch (e) {
      print("Error getRecipeById: $e");
      return null;
    }
  }
}
