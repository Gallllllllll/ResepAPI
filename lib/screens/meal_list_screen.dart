import 'package:flutter/material.dart';
import '../models/recipe_model.dart';
import '../services/local_recipe_service.dart';
import '../widgets/recipe_card.dart';
import 'home_screen.dart';
import 'bookmark_screen.dart';
import 'form_recipe_screen.dart';

class MealListScreen extends StatefulWidget {
  const MealListScreen({super.key});

  @override
  State<MealListScreen> createState() => _MealListScreenState();
}

/// Halaman untuk menampilkan daftar resep yang disimpan secara lokal
class _MealListScreenState extends State<MealListScreen> {
  List<Recipe> localRecipes = [];
  int currentIndex = 2; // Resepku aktif

  void loadLocalRecipes() async {
    localRecipes = await LocalRecipeService.getRecipes();
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    loadLocalRecipes();
  }
  
  /// Navigasi bottom navigation bar
  void _onBottomNavTap(int index) async {
    setState(() => currentIndex = index);
    switch (index) {
      case 0:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const HomeScreen()),
        );
        break;
      case 1:
        final result = await Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const FormRecipeScreen()),
        );
        if (result == true) loadLocalRecipes();
        break;
      case 2:
        // sudah di halaman ini
        break;
      case 3:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const BookmarkScreen()),
        );
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Resepku',
          style: TextStyle(fontWeight: FontWeight.w700, letterSpacing: 0.3),
        ),
        backgroundColor: Colors.orange[700],
        centerTitle: true,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.orange[50]!,
              Colors.orange[100]!.withOpacity(0.3),
              Colors.white,
            ],
            stops: const [0.0, 0.3, 0.6],
          ),
        ),
        child: localRecipes.isEmpty
            ? const Center(
                child: Text(
                  'Belum ada resep yang ditambahkan',
                  style: TextStyle(fontSize: 16),
                ),
              )
            : ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: localRecipes.length,
                itemBuilder: (context, index) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: RecipeCard(recipe: localRecipes[index]),
                ),
              ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: currentIndex,
        onTap: _onBottomNavTap,
        selectedItemColor: Colors.orange[700],
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.add), label: 'Tambah'),
          BottomNavigationBarItem(icon: Icon(Icons.list_alt), label: 'Resepku'),
          BottomNavigationBarItem(
              icon: Icon(Icons.bookmark), label: 'Bookmark'),
        ],
      ),
    );
  }
}
