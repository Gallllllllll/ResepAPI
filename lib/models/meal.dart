class Meal {
  final String id;
  final String name;
  final String category;
  final String area;
  final String instructions;
  final String image;
  final List<String> tags; // tambahkan field ini

  Meal({
    required this.id,
    required this.name,
    required this.category,
    required this.area,
    required this.instructions,
    required this.image,
    this.tags = const [], // default kosong
  });

  factory Meal.fromMap(Map<String, dynamic> map) {
    return Meal(
      id: map['idMeal'] ?? '',
      name: map['strMeal'] ?? '',
      category: map['strCategory'] ?? '',
      area: map['strArea'] ?? '',
      instructions: map['strInstructions'] ?? '',
      image: map['strMealThumb'] ?? '',
      tags: map['strTags'] != null
          ? (map['strTags'] as String).split(',').map((e) => e.trim()).toList()
          : [],
    );
  }
}
