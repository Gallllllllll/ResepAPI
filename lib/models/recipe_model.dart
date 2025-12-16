class Recipe {
  final int id;
  final String title;
  final String image;
  final List<String> ingredients;
  final List<String> steps;

  Recipe({
    required this.id,
    required this.title,
    required this.image,
    required this.ingredients,
    required this.steps,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'image': image,
      'ingredients': ingredients,
      'steps': steps,
    };
  }

  factory Recipe.fromMap(Map<String, dynamic> map) {
    return Recipe(
      id: map['id'],
      title: map['title'],
      image: map['image'],
      ingredients: List<String>.from(map['ingredients']),
      steps: List<String>.from(map['steps']),
    );
  }
}
