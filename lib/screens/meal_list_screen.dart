import 'package:flutter/material.dart';
import '../models/recipe_model.dart';
import '../services/local_recipe_service.dart';
import '../widgets/recipe_card.dart';

class MealListScreen extends StatefulWidget {
  const MealListScreen({super.key});

  @override
  State<MealListScreen> createState() => _MealListScreenState();
}

class _MealListScreenState extends State<MealListScreen> {
  List<Recipe> localRecipes = [];

  void loadLocalRecipes() async {
    localRecipes = await LocalRecipeService.getRecipes();
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    loadLocalRecipes();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Resep Lokal')),
      body: localRecipes.isEmpty
          ? const Center(child: Text('Belum ada resep lokal'))
          : ListView.builder(
              itemCount: localRecipes.length,
              itemBuilder: (context, index) => RecipeCard(recipe: localRecipes[index]),
            ),
    );
  }
}
