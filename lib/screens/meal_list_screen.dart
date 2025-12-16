import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/meal_provider.dart';
import '../widgets/meal_card.dart';
import '../widgets/loading_shimmer.dart';
import 'meal_detail_screen.dart';

class MealListScreen extends StatelessWidget {
  final String category;

  const MealListScreen({Key? key, required this.category}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final mealProvider = Provider.of<MealProvider>(context);

    // Load meals when screen is built
    WidgetsBinding.instance!.addPostFrameCallback((_) {
      if (mealProvider.meals.isEmpty || mealProvider.searchQuery != category) {
        mealProvider.loadMealsByCategory(category);
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: Text(category),
      ),
      body: Consumer<MealProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading && provider.meals.isEmpty) {
            return _buildLoadingGrid();
          }

          if (provider.meals.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.fastfood, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text(
                    'Tidak ada resep untuk kategori ini',
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                ],
              ),
            );
          }

          return GridView.builder(
            padding: EdgeInsets.all(16),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 0.8,
            ),
            itemCount: provider.meals.length,
            itemBuilder: (context, index) {
              final meal = provider.meals[index];
              return MealCard(
                meal: meal,
                isFavorite: provider.isFavorite(meal.id),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => MealDetailScreen(meal: meal),
                    ),
                  );
                },
                onToggleFavorite: () {
                  provider.toggleFavorite(meal);
                },
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildLoadingGrid() {
    return GridView.builder(
      padding: EdgeInsets.all(16),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 0.8,
      ),
      itemCount: 6,
      itemBuilder: (context, index) => MealCardShimmer(),
    );
  }
}