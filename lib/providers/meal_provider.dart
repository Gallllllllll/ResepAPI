import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/meal.dart';
import '../models/category.dart';

class ApiService {
  static const String _baseUrl = 'https://www.themealdb.com/api/json/v1/1';

  // Random Meal
  static Future<Meal> getRandomMeal() async {
    final url = Uri.parse('$_baseUrl/random.php');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final mealJson = data['meals'][0];
      return Meal.fromMap(mealJson);
    } else {
      throw Exception('Failed to load random meal');
    }
  }

  // Ambil semua kategori
  static Future<List<MealCategory>> getCategories() async {
    final url = Uri.parse('$_baseUrl/categories.php');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return (data['categories'] as List)
          .map((json) => MealCategory.fromMap(json))
          .toList();
    } else {
      throw Exception('Failed to load categories');
    }
  }

  // Meals by category
  static Future<List<Meal>> getMealsByCategory(String category) async {
    final url = Uri.parse('$_baseUrl/filter.php?c=$category');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return (data['meals'] as List)
          .map((json) => Meal.fromMap(json))
          .toList();
    } else {
      throw Exception('Failed to load meals by category');
    }
  }

  // Search meals
  static Future<List<Meal>> searchMeals(String query) async {
    final url = Uri.parse('$_baseUrl/search.php?s=$query');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['meals'] == null) return [];
      return (data['meals'] as List)
          .map((json) => Meal.fromMap(json))
          .toList();
    } else {
      throw Exception('Failed to search meals');
    }
  }
}
