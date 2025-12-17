import 'package:flutter/material.dart';
import '../models/recipe_model.dart';
import '../services/local_recipe_service.dart';
import '../services/bookmark_service.dart';
import 'form_recipe_screen.dart';
import 'home_screen.dart';
import 'meal_list_screen.dart';
import 'bookmark_screen.dart';

class MealDetailScreen extends StatefulWidget {
  final Recipe recipe;
  const MealDetailScreen({required this.recipe, super.key});

  @override
  State<MealDetailScreen> createState() => _MealDetailScreenState();
}

class _MealDetailScreenState extends State<MealDetailScreen> {
  bool isLocal = true;
  bool isBookmarked = false;
  int currentIndex = 0; // bottom nav index

  @override
  void initState() {
    super.initState();
    _checkBookmark();
  }

  /// Cek apakah resep sudah di-bookmark
  void _checkBookmark() async {
    bool bookmarked = await BookmarkService.isBookmarked(widget.recipe.id);
    setState(() => isBookmarked = bookmarked);
  }

  /// Toggle status bookmark
  void _toggleBookmark() async {
    if (isBookmarked) {
      await BookmarkService.removeBookmark(widget.recipe.id);
    } else {
      await BookmarkService.addBookmark(widget.recipe);
    }
    _checkBookmark();
  }

  /// Navigasi bottom navigation bar
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
        if (result == true && context.mounted) Navigator.pop(context, true);
        break;
      case 2: // Resepku
        Navigator.push(
            context, MaterialPageRoute(builder: (_) => const MealListScreen()));
        break;
      case 3: // Bookmark
        Navigator.push(
            context, MaterialPageRoute(builder: (_) => const BookmarkScreen()));
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Detail Resep',
          style: TextStyle(
              fontWeight: FontWeight.w700, fontSize: 18, letterSpacing: 0.5),
        ),
        backgroundColor: Colors.orange[700],
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(isBookmarked ? Icons.bookmark : Icons.bookmark_border),
            onPressed: _toggleBookmark,
          ),
        ],
        elevation: 4,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Colors.orange[50]!,
              Colors.orange[100]!.withOpacity(0.3),
              Colors.white,
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            stops: const [0.0, 0.3, 0.6],
          ),
        ),
        child: Column(
          children: [
            // Header Image
            Expanded(
              flex: 3,
              child: Stack(
                children: [
                  Positioned.fill(
                    child: ClipRRect(
                      borderRadius: const BorderRadius.only(
                          bottomLeft: Radius.circular(30),
                          bottomRight: Radius.circular(30)),
                      child: widget.recipe.image.isNotEmpty
                          ? Image.network(
                              widget.recipe.image,
                              fit: BoxFit.cover,
                              errorBuilder: (c, e, s) =>
                                  _buildPlaceholderImage(),
                              loadingBuilder: (c, child, progress) {
                                if (progress == null) return child;
                                return const Center(
                                    child: CircularProgressIndicator());
                              },
                            )
                          : _buildPlaceholderImage(),
                    ),
                  ),
                  Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: const BorderRadius.only(
                            bottomLeft: Radius.circular(30),
                            bottomRight: Radius.circular(30)),
                        gradient: LinearGradient(
                          colors: [
                            Colors.black.withOpacity(0.7),
                            Colors.transparent,
                            Colors.transparent
                          ],
                          begin: Alignment.bottomCenter,
                          end: Alignment.topCenter,
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    left: 20,
                    right: 20,
                    bottom: 30,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(
                              color: Colors.orange[700]!.withOpacity(0.9),
                              borderRadius: BorderRadius.circular(12)),
                          child: Text(widget.recipe.title,
                              style: const TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.w800,
                                  color: Colors.white,
                                  letterSpacing: 0.5),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                  color: Colors.white.withOpacity(0.3))),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.restaurant_menu,
                                  size: 14, color: Colors.white),
                              const SizedBox(width: 6),
                              Text('${widget.recipe.ingredients.length} Bahan',
                                  style: const TextStyle(
                                      fontSize: 14,
                                      color: Colors.white,
                                      fontWeight: FontWeight.w500)),
                              const SizedBox(width: 12),
                              Icon(Icons.format_list_numbered,
                                  size: 14, color: Colors.white),
                              const SizedBox(width: 6),
                              Text('${widget.recipe.steps.length} Langkah',
                                  style: const TextStyle(
                                      fontSize: 14,
                                      color: Colors.white,
                                      fontWeight: FontWeight.w500)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            // Detail content
            Expanded(
              flex: 4,
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildSectionCard(
                        title: 'Bahan-bahan',
                        icon: Icons.shopping_basket_rounded,
                        color: Colors.orange[700]!,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: widget.recipe.ingredients
                              .asMap()
                              .entries
                              .map((entry) {
                            final index = entry.key + 1;
                            final ingredient = entry.value;
                            return Padding(
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    width: 28,
                                    height: 28,
                                    decoration: BoxDecoration(
                                        color: Colors.orange[100],
                                        borderRadius: BorderRadius.circular(8)),
                                    child: Center(
                                        child: Text('$index',
                                            style: TextStyle(
                                                fontSize: 14,
                                                fontWeight: FontWeight.w700,
                                                color: Colors.orange[700]))),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                      child: Text(ingredient,
                                          style: TextStyle(
                                              fontSize: 16,
                                              color: Colors.grey[800],
                                              height: 1.5))),
                                ],
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                      const SizedBox(height: 20),
                      _buildSectionCard(
                        title: 'Langkah-langkah',
                        icon: Icons.list_alt_rounded,
                        color: Colors.deepOrange[400]!,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children:
                              widget.recipe.steps.asMap().entries.map((entry) {
                            final index = entry.key + 1;
                            final step = entry.value;
                            return Padding(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    width: 32,
                                    height: 32,
                                    decoration: BoxDecoration(
                                        color: Colors.deepOrange[100],
                                        borderRadius:
                                            BorderRadius.circular(10)),
                                    child: Center(
                                        child: Text('$index',
                                            style: TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.w800,
                                                color:
                                                    Colors.deepOrange[400]))),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                      child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                        Text('Langkah $index',
                                            style: TextStyle(
                                                fontSize: 14,
                                                fontWeight: FontWeight.w600,
                                                color: Colors.deepOrange[400])),
                                        const SizedBox(height: 4),
                                        Text(step,
                                            style: TextStyle(
                                                fontSize: 15,
                                                color: Colors.grey[800],
                                                height: 1.5))
                                      ]))
                                ],
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                      if (isLocal) ...[
                        const SizedBox(height: 25),
                        _buildActionButtons(context),
                      ],
                      const SizedBox(height: 30),
                    ],
                  ),
                ),
              ),
            ),
          ],
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

  /// Placeholder gambar jika gagal memuat
  Widget _buildPlaceholderImage() {
    return Container(
        color: Colors.grey[200],
        child: const Center(
            child: Icon(Icons.restaurant_menu_rounded,
                size: 60, color: Colors.grey)));
  }

  /// Membuat card untuk setiap section (bahan/langkah)
  Widget _buildSectionCard(
      {required String title,
      required IconData icon,
      required Color color,
      required Widget child}) {
    return Container(
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
                color: color.withOpacity(0.1),
                blurRadius: 20,
                spreadRadius: 2,
                offset: const Offset(0, 4))
          ],
          border: Border.all(color: color.withOpacity(0.2), width: 1.5)),
      child: Padding(padding: const EdgeInsets.all(20), child: child),
    );
  }

  /// Membuat tombol aksi untuk resep lokal (edit/hapus)
  Widget _buildActionButtons(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton(
            onPressed: () async {
              final result = await Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => FormRecipeScreen(recipe: widget.recipe)));
              if (result != null) Navigator.pop(context, true);
            },
            style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange[700],
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15)),
                elevation: 4),
            child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.edit_rounded, size: 20),
                  SizedBox(width: 10),
                  Text('Edit Resep',
                      style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.3))
                ]),
          ),
        ),
        const SizedBox(width: 15),
        Expanded(
          child: ElevatedButton(
            onPressed: () async {
              bool confirmDelete = await showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                        title: const Text('Hapus Resep'),
                        content: const Text(
                            'Apakah Anda yakin ingin menghapus resep ini?'),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15)),
                        actions: [
                          TextButton(
                              onPressed: () => Navigator.pop(context, false),
                              child: const Text('Batal')),
                          ElevatedButton(
                              onPressed: () => Navigator.pop(context, true),
                              style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.red,
                                  foregroundColor: Colors.white),
                              child: const Text('Hapus'))
                        ],
                      ));
              if (confirmDelete == true) {
                await LocalRecipeService.deleteRecipe(widget.recipe.id);
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      content: const Text('Resep berhasil dihapus'),
                      backgroundColor: Colors.green,
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10))));
                  Navigator.pop(context, true);
                }
              }
            },
            style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red[400],
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15)),
                elevation: 4),
            child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.delete_rounded, size: 20),
                  SizedBox(width: 10),
                  Text('Hapus',
                      style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.3))
                ]),
          ),
        ),
      ],
    );
  }
}