import 'package:flutter/material.dart';
import '../models/recipe_model.dart';
import '../services/local_recipe_service.dart';

class FormRecipeScreen extends StatefulWidget {
  final Recipe? recipe;
  const FormRecipeScreen({this.recipe, super.key});

  @override
  State<FormRecipeScreen> createState() => _FormRecipeScreenState();
}

class _FormRecipeScreenState extends State<FormRecipeScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _imageController;
  late TextEditingController _ingredientsController;
  late TextEditingController _stepsController;
  bool _isLoading = false;
  bool _isNavigating = false; // Flag untuk mencegah navigasi ganda

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.recipe?.title ?? '');
    _imageController = TextEditingController(text: widget.recipe?.image ?? '');
    _ingredientsController = TextEditingController(
      text: (widget.recipe?.ingredients ?? []).join('\n')
    );
    _stepsController = TextEditingController(
      text: (widget.recipe?.steps ?? []).join('\n')
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _imageController.dispose();
    _ingredientsController.dispose();
    _stepsController.dispose();
    super.dispose();
  }

  Future<void> _saveRecipe() async {
    // Cegah multiple calls
    if (_isLoading || _isNavigating) return;
    
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _isNavigating = false;
    });

    try {
      final recipe = Recipe(
        id: widget.recipe?.id ?? DateTime.now().millisecondsSinceEpoch,
        title: _titleController.text.trim(),
        image: _imageController.text.trim(),
        ingredients: _ingredientsController.text
            .split('\n')
            .where((line) => line.trim().isNotEmpty)
            .map((line) => line.trim())
            .toList(),
        steps: _stepsController.text
            .split('\n')
            .where((line) => line.trim().isNotEmpty)
            .map((line) => line.trim())
            .toList(),
      );

      print('DEBUG: Saving recipe - ID: ${recipe.id}');
      print('DEBUG: Title: ${recipe.title}');
      print('DEBUG: Ingredients: ${recipe.ingredients.length}');
      print('DEBUG: Steps: ${recipe.steps.length}');

      if (widget.recipe == null) {
        await LocalRecipeService.createRecipe(recipe);
      } else {
        await LocalRecipeService.updateRecipe(recipe);
      }

      // Set flag dan navigasi dengan delay kecil
      if (mounted) {
        _isNavigating = true;
        await Future.delayed(const Duration(milliseconds: 100));
        Navigator.of(context).pop(recipe);
      }

    } catch (e, stackTrace) {
      print('ERROR: $e');
      print('STACK TRACE: $stackTrace');
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
      }
    } finally {
      if (mounted && !_isNavigating) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditMode = widget.recipe != null;

    return WillPopScope(
      onWillPop: () async {
        // Cegah navigasi saat loading
        if (_isLoading) return false;
        return true;
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            isEditMode ? 'Edit Resep' : 'Tambah Resep Baru',
            style: const TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 18,
              letterSpacing: 0.5,
            ),
          ),
          backgroundColor: Colors.orange[700],
          centerTitle: true,
          iconTheme: const IconThemeData(color: Colors.white),
          elevation: 3,
        ),
        body: SafeArea(
          child: Container(
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
            child: GestureDetector(
              onTap: () => FocusScope.of(context).unfocus(),
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      // Header
                      Container(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        child: Column(
                          children: [
                            Icon(
                              isEditMode ? Icons.edit_note_rounded : Icons.add_circle_rounded,
                              size: 50,
                              color: Colors.orange[700],
                            ),
                            const SizedBox(height: 10),
                            Text(
                              isEditMode ? 'Perbarui Resep' : 'Buat Resep Baru',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w700,
                                color: Colors.orange[800],
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Form Container
                      Expanded(
                        child: SingleChildScrollView(
                          physics: const BouncingScrollPhysics(),
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(15),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.grey.withOpacity(0.1),
                                  blurRadius: 10,
                                  spreadRadius: 2,
                                ),
                              ],
                            ),
                            padding: const EdgeInsets.all(20),
                            child: Column(
                              children: [
                                // Judul Resep
                                _buildTextField(
                                  controller: _titleController,
                                  label: 'Judul Resep',
                                  hintText: 'Masukkan judul resep',
                                  icon: Icons.title,
                                  isRequired: true,
                                ),
                                const SizedBox(height: 20),

                                // URL Gambar
                                _buildTextField(
                                  controller: _imageController,
                                  label: 'URL Gambar (Opsional)',
                                  hintText: 'https://example.com/gambar.jpg',
                                  icon: Icons.image,
                                ),
                                const SizedBox(height: 20),

                                // Bahan-bahan
                                _buildTextField(
                                  controller: _ingredientsController,
                                  label: 'Bahan-bahan',
                                  hintText: 'Masukkan setiap bahan dalam baris baru\nContoh:\n• 2 butir telur\n• 100g tepung\n• 1 sdt garam',
                                  icon: Icons.shopping_basket,
                                  isRequired: true,
                                  maxLines: 5,
                                ),
                                const SizedBox(height: 20),

                                // Langkah-langkah
                                _buildTextField(
                                  controller: _stepsController,
                                  label: 'Langkah-langkah',
                                  hintText: 'Masukkan setiap langkah dalam baris baru\nContoh:\n1. Campur bahan kering\n2. Tambahkan bahan basah\n3. Panggang selama 30 menit',
                                  icon: Icons.list_alt,
                                  isRequired: true,
                                  maxLines: 6,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 20),

                      // Tombol Simpan
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: _isLoading || _isNavigating ? null : _saveRecipe,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.orange[700],
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: _isLoading
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : Text(
                                  isEditMode ? 'Perbarui Resep' : 'Simpan Resep',
                                  style: const TextStyle(
                                    fontSize: 16,
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                        ),
                      ),

                      const SizedBox(height: 10),

                      // Tombol Batal
                      TextButton(
                        onPressed: _isLoading ? null : () {
                          if (mounted) {
                            Navigator.of(context).pop();
                          }
                        },
                        child: Text(
                          'Batal',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey[600],
                          ),
                        ),
                      ),

                      // Info
                      Container(
                        margin: const EdgeInsets.only(top: 15),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.orange[50],
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: Colors.orange[200]!),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.info_outline,
                              size: 20,
                              color: Colors.orange[700],
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                'Tips: Gunakan baris baru untuk setiap bahan atau langkah',
                                style: TextStyle(
                                  color: Colors.orange[800],
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hintText,
    required IconData icon,
    bool isRequired = false,
    int maxLines = 1,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 20, color: Colors.orange[700]),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: Colors.orange[800],
              ),
            ),
            if (isRequired)
              Text(
                ' *',
                style: TextStyle(
                  color: Colors.red[400],
                  fontWeight: FontWeight.bold,
                ),
              ),
          ],
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          maxLines: maxLines,
          decoration: InputDecoration(
            hintText: hintText,
            hintStyle: const TextStyle(color: Colors.grey),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: Colors.orange[700]!, width: 2),
            ),
            filled: true,
            fillColor: Colors.grey[50],
            contentPadding: const EdgeInsets.all(12),
          ),
          validator: isRequired
              ? (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Field ini harus diisi';
                  }
                  return null;
                }
              : null,
        ),
      ],
    );
  }
}