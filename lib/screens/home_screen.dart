import 'dart:math';
import 'package:flutter/material.dart';
import 'package:resep_masakan_app/screens/bookmark_screen.dart';
import 'package:shimmer/shimmer.dart';
import '../models/recipe_model.dart';
import '../services/api_service.dart';
import '../services/local_recipe_service.dart';
import '../widgets/recipe_card.dart';
import '../widgets/section_title.dart';
import 'form_recipe_screen.dart';
import 'meal_list_screen.dart';
import 'meal_detail_screen.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

/// State untuk HomeScreen
class _HomeScreenState extends State<HomeScreen> {
  List<Recipe> apiRecipes = [];
  List<Recipe> localRecipes = [];
  List<Recipe> popularRecipes = [];
  bool loading = false;
  int currentIndex = 0;
  TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    loadLocalRecipes();
    _loadPopularRecipes();
  }

  /// Memuat resep dari API berdasarkan query pencarian
  void loadApiRecipes(String query) async {
    if (query.isEmpty) return;
    setState(() => loading = true);
    apiRecipes = await ApiService.searchRecipes(query);
    setState(() => loading = false);
  }

  /// Memuat resep lokal yang disimpan di perangkat
  void loadLocalRecipes() async {
    localRecipes = await LocalRecipeService.getRecipes();
    setState(() {});
  }

  /// Memuat resep populer secara acak dari API
  void _loadPopularRecipes() async {
    List<Recipe> list = await ApiService.searchRecipes("");
    list.shuffle(Random());
    popularRecipes = list.take(4).toList();
    setState(() {});
  }

  /// Menangani navigasi pada BottomNavigationBar
  void onBottomNavTap(int index) async {
    setState(() => currentIndex = index);
    switch (index) {
      case 0: // Home
        break;
      case 1: // Tambah Resep
        bool? result = await Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const FormRecipeScreen()),
        );
        if (result == true) loadLocalRecipes();
        break;
      case 2: // Resepku
        await Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const MealListScreen()),
        );
        loadLocalRecipes();
        break;
      case 3: // Bookmark
        await Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const BookmarkScreen()),
        );
        break;
    }
  }

  /// Membuat badge informasi untuk jumlah bahan atau langkah
  Widget _infoBadge({
    required IconData icon,
    required String label,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.orange.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 14,
            color: Colors.orange[700],
          ),
          const SizedBox(width: 4),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            softWrap: false,
            style: TextStyle(
              fontSize: 11.5,
              fontWeight: FontWeight.w600,
              color: Colors.orange[700],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Yummy Recipes',
          style: TextStyle(
            fontWeight: FontWeight.w700,
            letterSpacing: 0.5,
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.orange[700],
        centerTitle: true,
        elevation: 4,
        shadowColor: Colors.orange[700]!.withOpacity(0.3),
      ),

      /// Body utama HomeScreen
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
          ),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),

          /// Kolom utama berisi search bar dan daftar resep hasil pencarian
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Halo! Mau masak apa hari ini?",
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: searchController,
                onSubmitted: loadApiRecipes,
                decoration: InputDecoration(
                  labelText: 'Cari resep...',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.search),
                    onPressed: () => loadApiRecipes(searchController.text),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Hasil pencarian langsung di bawah search bar
              // Hanya tampilkan jika ada query
              if (searchController.text.isNotEmpty) ...[
                sectionTitle(
                  icon: Icons.search,
                  title: "Hasil Pencarian",
                ),
                const SizedBox(height: 8),
                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.35,
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                          color: Colors.orange.withOpacity(0.2), width: 1.2),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.orange.withOpacity(0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: loading
                        ? const Center(
                            child: SpinKitFadingCircle(
                              color: Colors.orange,
                              size: 50.0,
                            ),
                          )
                        : apiRecipes.isEmpty
                            ? const Center(
                                child: Text(
                                  "Resep tidak ditemukan",
                                  style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600),
                                ),
                              )
                            : ListView.separated(
                                itemCount: apiRecipes.length,
                                separatorBuilder: (_, __) =>
                                    const SizedBox(height: 8),
                                itemBuilder: (context, index) {
                                  final recipe = apiRecipes[index];
                                  return Container(
                                    margin: const EdgeInsets.symmetric(
                                        horizontal: 4),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(16),
                                      border: Border.all(
                                        color: Colors.orange.withOpacity(0.1),
                                        width: 1.0,
                                      ),
                                    ),
                                    child: RecipeCard(recipe: recipe),
                                  );
                                },
                              ),
                  ),
                ),
                const SizedBox(height: 16),
              ],

              /// Rekomendasi populer
              sectionTitle(
                icon: Icons.star_rounded,
                title: "Rekomendasi Untukmu",
              ),
              const SizedBox(height: 12),
              popularRecipes.isEmpty
                  ? _buildShimmerGrid()
                  : GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: popularRecipes.length,
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        mainAxisSpacing: 12,
                        crossAxisSpacing: 12,
                        childAspectRatio: 0.8,
                      ),
                      itemBuilder: (context, index) {
                        final recipe = popularRecipes[index];
                        return GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (_) =>
                                      MealDetailScreen(recipe: recipe)),
                            );
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(22),
                              color: Colors.white,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.orange.withOpacity(0.08),
                                  blurRadius: 14,
                                  offset: const Offset(0, 6),
                                ),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // IMAGE + GRADIENT OVERLAY
                                Expanded(
                                  child: Stack(
                                    children: [
                                      ClipRRect(
                                        borderRadius: const BorderRadius.only(
                                          topLeft: Radius.circular(22),
                                          topRight: Radius.circular(22),
                                        ),
                                        child: recipe.image.isNotEmpty
                                            ? Image.network(
                                                recipe.image,
                                                width: double.infinity,
                                                fit: BoxFit.cover,
                                              )
                                            : Container(
                                                color: Colors.grey[200],
                                                child: const Icon(
                                                  Icons.restaurant_menu,
                                                  size: 50,
                                                  color: Colors.grey,
                                                ),
                                              ),
                                      ),
                                      Positioned.fill(
                                        child: DecoratedBox(
                                          decoration: BoxDecoration(
                                            borderRadius:
                                                const BorderRadius.only(
                                              topLeft: Radius.circular(22),
                                              topRight: Radius.circular(22),
                                            ),
                                            gradient: LinearGradient(
                                              begin: Alignment.bottomCenter,
                                              end: Alignment.topCenter,
                                              colors: [
                                                Colors.black.withOpacity(0.55),
                                                Colors.transparent,
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                      Positioned(
                                        left: 10,
                                        right: 10,
                                        bottom: 10,
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 12, vertical: 8),
                                          decoration: BoxDecoration(
                                            color:
                                                Colors.white.withOpacity(0.2),
                                            borderRadius:
                                                BorderRadius.circular(20),
                                            border: Border.all(
                                              color:
                                                  Colors.white.withOpacity(0.3),
                                            ),
                                          ),
                                          child: Center(
                                            child: Text(
                                              recipe.title,
                                              maxLines: 2,
                                              overflow: TextOverflow.ellipsis,
                                              style: const TextStyle(
                                                color: Colors.white,
                                                fontSize: 20,
                                                fontWeight: FontWeight.w700,
                                                height: 1.3,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),

                                // INFO SECTION
                                Padding(
                                  padding:
                                      const EdgeInsets.fromLTRB(12, 10, 12, 12),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      _infoBadge(
                                        icon: Icons.restaurant_menu,
                                        label:
                                            '${recipe.ingredients.length} Bahan',
                                      ),
                                      const SizedBox(height: 6),
                                      _infoBadge(
                                        icon: Icons.format_list_numbered,
                                        label: '${recipe.steps.length} Langkah',
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
              const SizedBox(height: 24),

              /// Resepku dari lokal
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  sectionTitle(
                    icon: Icons.book_rounded,
                    title: "Resepku",
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => const MealListScreen()),
                      );
                    },
                    child: const Text("Lihat lainnya"),
                  )
                ],
              ),
              const SizedBox(height: 12),
              ...localRecipes.take(2).map((r) => Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.orange.withOpacity(0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 3),
                        ),
                      ],
                      color: Colors.white,
                      border: Border.all(
                        color: Colors.orange.withOpacity(0.1),
                        width: 1.2,
                      ),
                    ),
                    child: RecipeCard(recipe: r),
                  )),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: currentIndex,
        onTap: onBottomNavTap,
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

  /// Membuat grid shimmer sebagai placeholder saat memuat data
  Widget _buildShimmerGrid() {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: 4,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 0.8,
      ),
      itemBuilder: (_, __) => Shimmer.fromColors(
        baseColor: Colors.grey[300]!,
        highlightColor: Colors.grey[100]!,
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
          ),
        ),
      ),
    );
  }
}
