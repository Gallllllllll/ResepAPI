import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/meal.dart';
import '../models/category.dart';

class ApiService {
  static const String _baseUrl = 'https://www.themealdb.com/api/json/v1/1';
  static const String _spoonacularBaseUrl = 'https://api.spoonacular.com/recipes';
  static const String _spoonacularApiKey = 'YOUR_API_KEY_HERE'; // Daftar di spoonacular.com untuk API key gratis

  // Get meals by category
  static Future<List<Meal>> getMealsByCategory(String category) async {
    try {
      final response = await http.get(Uri.parse('$_baseUrl/filter.php?c=$category'));
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final meals = data['meals'] as List;
        
        // Get details for each meal
        List<Meal> detailedMeals = [];
        for (var meal in meals) {
          final details = await getMealDetails(meal['idMeal']);
          detailedMeals.add(details);
        }
        
        return detailedMeals;
      }
      return [];
    } catch (e) {
      print('Error fetching meals: $e');
      return [];
    }
  }

  // Get meal details by ID
  static Future<Meal> getMealDetails(String id) async {
    try {
      final response = await http.get(Uri.parse('$_baseUrl/lookup.php?i=$id'));
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final mealData = data['meals'][0];
        return Meal.fromJson(mealData);
      }
      throw Exception('Failed to load meal details');
    } catch (e) {
      print('Error fetching meal details: $e');
      rethrow;
    }
  }

  // Search meals
  static Future<List<Meal>> searchMeals(String query) async {
    try {
      final response = await http.get(Uri.parse('$_baseUrl/search.php?s=$query'));
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['meals'] == null) return [];
        
        final meals = data['meals'] as List;
        return meals.map((meal) => Meal.fromJson(meal)).toList();
      }
      return [];
    } catch (e) {
      print('Error searching meals: $e');
      return [];
    }
  }

  // Get categories
  static Future<List<MealCategory>> getCategories() async {
    try {
      final response = await http.get(Uri.parse('$_baseUrl/categories.php'));
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final categories = data['categories'] as List;
        return categories.map((cat) => MealCategory.fromJson(cat)).toList();
      }
      return [];
    } catch (e) {
      print('Error fetching categories: $e');
      return [];
    }
  }

  // Get random meal
  static Future<Meal> getRandomMeal() async {
    try {
      final response = await http.get(Uri.parse('$_baseUrl/random.php'));
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final mealData = data['meals'][0];
        return Meal.fromJson(mealData);
      }
      throw Exception('Failed to load random meal');
    } catch (e) {
      print('Error fetching random meal: $e');
      rethrow;
    }
  }

  // Search by ingredient (using Spoonacular API)
  static Future<List<Meal>> searchByIngredient(String ingredient) async {
    try {
      final response = await http.get(
        Uri.parse('$_spoonacularBaseUrl/findByIngredients?ingredients=$ingredient&apiKey=$_spoonacularApiKey')
      );
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body) as List;
        // Convert Spoonacular format to our Meal format
        return data.map((item) {
          return Meal(
            id: item['id'].toString(),
            name: item['title'] ?? '',
            category: '',
            area: '',
            instructions: '',
            imageUrl: item['image'] ?? '',
            ingredients: [],
            measures: [],
            tags: [],
          );
        }).toList();
      }
      return [];
    } catch (e) {
      print('Error searching by ingredient: $e');
      return [];
    }
  }
}