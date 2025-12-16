class Meal {
  final String id;
  final String name;
  final String category;
  final String area;
  final String instructions;
  final String imageUrl;
  final String? youtubeUrl;
  final List<String> ingredients;
  final List<String> measures;
  final List<String> tags;
  final bool isFavorite;

  Meal({
    required this.id,
    required this.name,
    required this.category,
    required this.area,
    required this.instructions,
    required this.imageUrl,
    this.youtubeUrl,
    required this.ingredients,
    required this.measures,
    required this.tags,
    this.isFavorite = false,
  });

  factory Meal.fromJson(Map<String, dynamic> json) {
    List<String> ingredients = [];
    List<String> measures = [];
    List<String> tags = [];

    // Extract ingredients and measures
    for (int i = 1; i <= 20; i++) {
      String ingredient = json['strIngredient$i']?.toString() ?? '';
      String measure = json['strMeasure$i']?.toString() ?? '';
      
      if (ingredient.trim().isNotEmpty) {
        ingredients.add(ingredient);
        measures.add(measure);
      }
    }

    // Extract tags
    if (json['strTags'] != null) {
      tags = (json['strTags'] as String).split(',').map((e) => e.trim()).toList();
    }

    return Meal(
      id: json['idMeal'] ?? '',
      name: json['strMeal'] ?? '',
      category: json['strCategory'] ?? '',
      area: json['strArea'] ?? '',
      instructions: json['strInstructions'] ?? '',
      imageUrl: json['strMealThumb'] ?? '',
      youtubeUrl: json['strYoutube'],
      ingredients: ingredients,
      measures: measures,
      tags: tags,
    );
  }
}