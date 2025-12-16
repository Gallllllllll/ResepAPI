class MealCategory {
  final String id;
  final String name;
  final String description;
  final String image;

  MealCategory({
    required this.id,
    required this.name,
    required this.description,
    required this.image,
  });

  factory MealCategory.fromMap(Map<String, dynamic> map) {
    return MealCategory(
      id: map['idCategory'] ?? '',
      name: map['strCategory'] ?? '',
      description: map['strCategoryDescription'] ?? '',
      image: map['strCategoryThumb'] ?? '',
    );
  }
}
