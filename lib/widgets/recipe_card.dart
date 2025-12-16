import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/recipe_model.dart';
import '../screens/meal_detail_screen.dart';

class RecipeCard extends StatelessWidget {
  final Recipe recipe;

  const RecipeCard({required this.recipe, super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: CachedNetworkImage(
          imageUrl: recipe.image,
          width: 60,
          height: 60,
          fit: BoxFit.cover,
          placeholder: (context, url) => const CircularProgressIndicator(),
          errorWidget: (context, url, error) => const Icon(Icons.error),
        ),
        title: Text(recipe.title),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => MealDetailScreen(recipe: recipe)),
          );
        },
      ),
    );
  }
}
