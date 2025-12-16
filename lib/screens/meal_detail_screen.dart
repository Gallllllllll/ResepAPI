import 'package:flutter/material.dart';
import '../models/recipe_model.dart';
import '../services/local_recipe_service.dart';
import 'form_recipe_screen.dart';

class MealDetailScreen extends StatelessWidget {
  final Recipe recipe;
  const MealDetailScreen({required this.recipe, super.key});

  @override
  Widget build(BuildContext context) {
    bool isLocal = true; // kamu bisa tambahkan logika untuk membedakan API & lokal

    return Scaffold(
      appBar: AppBar(title: Text(recipe.title)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Image.network(recipe.image, fit: BoxFit.cover),
            const SizedBox(height: 12),
            const Text('Ingredients', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ...recipe.ingredients.map((e) => Text('- $e')).toList(),
            const SizedBox(height: 12),
            const Text('Steps', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ...recipe.steps.map((e) => Text('- $e')).toList(),
            if (isLocal) ...[
              const SizedBox(height: 12),
              Row(
                children: [
                  ElevatedButton(
                    onPressed: () async {
                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => FormRecipeScreen(recipe: recipe),
                        ),
                      );
                      Navigator.pop(context, true);
                    },
                    child: const Text('Edit'),
                  ),
                  const SizedBox(width: 10),
                  ElevatedButton(
                    onPressed: () async {
                      await LocalRecipeService.deleteRecipe(recipe.id);
                      Navigator.pop(context, true);
                    },
                    child: const Text('Hapus'),
                  ),
                ],
              ),
            ]
          ],
        ),
      ),
    );
  }
}
