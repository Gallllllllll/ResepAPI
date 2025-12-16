import 'package:flutter/material.dart';
import '../models/recipe_model.dart';
import '../services/bookmark_service.dart';
import '../widgets/recipe_card.dart';
import 'meal_detail_screen.dart';
import 'home_screen.dart';
import 'meal_list_screen.dart';
import 'form_recipe_screen.dart';

class BookmarkScreen extends StatefulWidget {
  const BookmarkScreen({super.key});

  @override
  State<BookmarkScreen> createState() => _BookmarkScreenState();
}

class _BookmarkScreenState extends State<BookmarkScreen> {
  List<Recipe> bookmarks = [];
  bool loading = true;
  int currentIndex = 3; // tab Bookmark aktif

  @override
  void initState() {
    super.initState();
    _loadBookmarks();
  }

  void _loadBookmarks() async {
    bookmarks = await BookmarkService.getBookmarks();
    setState(() => loading = false);
  }

  void _onBottomNavTap(int index) async {
    setState(() => currentIndex = index);
    switch (index) {
      case 0: // Home
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (_) => const HomeScreen()));
        break;
      case 1: // Tambah
        final result = await Navigator.push(context,
            MaterialPageRoute(builder: (_) => const FormRecipeScreen()));
        if (result == true) _loadBookmarks();
        break;
      case 2: // Resepku
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (_) => const MealListScreen()));
        break;
      case 3: // Bookmark
        // sudah di sini
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Bookmark',
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
        child: loading
            ? const Center(
                child: CircularProgressIndicator(color: Colors.orange))
            : bookmarks.isEmpty
                ? const Center(
                    child: Text(
                      'Belum ada resep yang di-bookmark',
                      style: TextStyle(fontSize: 16),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: bookmarks.length,
                    itemBuilder: (context, index) {
                      final recipe = bookmarks[index];
                      return GestureDetector(
                        onTap: () async {
                          await Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) =>
                                    MealDetailScreen(recipe: recipe)),
                          );
                          _loadBookmarks(); // refresh jika ada perubahan
                        },
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            color: Colors.white,
                            border: Border.all(
                                color: Colors.orange.withOpacity(0.1),
                                width: 1.2),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.orange.withOpacity(0.05),
                                blurRadius: 10,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                          child: RecipeCard(recipe: recipe),
                        ),
                      );
                    },
                  ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: currentIndex,
        onTap: _onBottomNavTap,
        selectedItemColor: Colors.orange[700],
        unselectedItemColor: Colors.grey,
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
