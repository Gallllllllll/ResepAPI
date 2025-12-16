import 'package:flutter/foundation.dart';
import '../models/meal.dart';
import '../models/category.dart';
import '../services/api_service.dart';

class MealProvider with ChangeNotifier {
  List<Meal> _meals = [];
  List<Meal> _favorites = [];
  List<MealCategory> _categories = [];
  bool _isLoading = false;
  String _searchQuery = '';

  List<Meal> get meals => _meals;
  List<Meal> get favorites => _favorites;
  List<MealCategory> get categories => _categories;
  bool get isLoading => _isLoading;
  String get searchQuery => _searchQuery;

  // TAMBAHKAN METHOD INI
  Future<Meal?> loadRandomMeal() async {
    try {
      return await ApiService.getRandomMeal();
    } catch (e) {
      print('Error loading random meal: $e');
      return null;
    }
  }

  Future<void> loadCategories() async {
    _isLoading = true;
    notifyListeners();
    
    try {
      _categories = await ApiService.getCategories();
    } catch (e) {
      print('Error loading categories: $e');
    }
    
    _isLoading = false;
    notifyListeners();
  }

  Future<void> loadMealsByCategory(String category) async {
    _isLoading = true;
    notifyListeners();
    
    try {
      _meals = await ApiService.getMealsByCategory(category);
    } catch (e) {
      print('Error loading meals: $e');
    }
    
    _isLoading = false;
    notifyListeners();
  }

  Future<void> searchMeals(String query) async {
    _searchQuery = query;
    _isLoading = true;
    notifyListeners();
    
    try {
      _meals = await ApiService.searchMeals(query);
    } catch (e) {
      print('Error searching meals: $e');
    }
    
    _isLoading = false;
    notifyListeners();
  }

  void toggleFavorite(Meal meal) {
    final index = _favorites.indexWhere((m) => m.id == meal.id);
    
    if (index >= 0) {
      _favorites.removeAt(index);
    } else {
      _favorites.add(meal);
    }
    
    notifyListeners();
  }

  bool isFavorite(String mealId) {
    return _favorites.any((meal) => meal.id == mealId);
  }

  void clearSearch() {
    _searchQuery = '';
    _meals = [];
    notifyListeners();
  }
}