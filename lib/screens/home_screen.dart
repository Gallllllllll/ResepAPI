import 'package:flutter/material.dart';
import '../models/recipe_model.dart';
import '../services/api_service.dart';
import '../services/local_recipe_service.dart';
import '../widgets/recipe_card.dart';
import 'form_recipe_screen.dart';
import 'meal_list_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Recipe> apiRecipes = [];
  List<Recipe> localRecipes = [];
  bool loading = false;

  void loadApiRecipes(String query) async {
    setState(() => loading = true);
    apiRecipes = await ApiService.searchRecipes(query);
    setState(() => loading = false);
  }

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
      appBar: AppBar(
        title: const Text('Yummy Recipes'),
        actions: [
          IconButton(
            icon: const Icon(Icons.list),
            onPressed: () async {
              await Navigator.push(
                  context, MaterialPageRoute(builder: (_) => const MealListScreen()));
              loadLocalRecipes();
            },
          )
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              onSubmitted: loadApiRecipes,
              decoration: const InputDecoration(
                labelText: 'Cari resep...',
                border: OutlineInputBorder(),
                suffixIcon: Icon(Icons.search),
              ),
            ),
          ),
          if (loading)
            const Center(child: CircularProgressIndicator())
          else
            Expanded(
              child: ListView(
                children: [
                  ...localRecipes.map((r) => RecipeCard(recipe: r)),
                  ...apiRecipes.map((r) => RecipeCard(recipe: r)),
                ],
              ),
            ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          bool? result = await Navigator.push(
              context, MaterialPageRoute(builder: (_) => const FormRecipeScreen()));
          if (result == true) loadLocalRecipes();
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
