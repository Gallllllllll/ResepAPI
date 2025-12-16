import 'package:flutter/material.dart';
import '../models/recipe_model.dart';
import '../services/local_recipe_service.dart';

class FormRecipeScreen extends StatefulWidget {
  final Recipe? recipe; // null kalau tambah baru
  const FormRecipeScreen({this.recipe, super.key});

  @override
  State<FormRecipeScreen> createState() => _FormRecipeScreenState();
}

class _FormRecipeScreenState extends State<FormRecipeScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController titleController;
  late TextEditingController imageController;
  late TextEditingController ingredientsController;
  late TextEditingController stepsController;

  @override
  void initState() {
    super.initState();
    titleController = TextEditingController(text: widget.recipe?.title ?? '');
    imageController = TextEditingController(text: widget.recipe?.image ?? '');
    ingredientsController = TextEditingController(text: widget.recipe?.ingredients.join('\n') ?? '');
    stepsController = TextEditingController(text: widget.recipe?.steps.join('\n') ?? '');
  }

  void saveRecipe() async {
    if (!_formKey.currentState!.validate()) return;

    final newRecipe = Recipe(
      id: widget.recipe?.id ?? DateTime.now().millisecondsSinceEpoch,
      title: titleController.text,
      image: imageController.text,
      ingredients: ingredientsController.text.split('\n'),
      steps: stepsController.text.split('\n'),
    );

    if (widget.recipe == null) {
      await LocalRecipeService.createRecipe(newRecipe);
    } else {
      await LocalRecipeService.updateRecipe(newRecipe);
    }

    Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.recipe == null ? 'Tambah Resep' : 'Edit Resep')),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: titleController,
                decoration: const InputDecoration(labelText: 'Judul Resep'),
                validator: (value) => value!.isEmpty ? 'Harus diisi' : null,
              ),
              TextFormField(
                controller: imageController,
                decoration: const InputDecoration(labelText: 'URL Gambar'),
              ),
              TextFormField(
                controller: ingredientsController,
                decoration: const InputDecoration(labelText: 'Bahan (pisahkan baris)'),
                maxLines: 4,
              ),
              TextFormField(
                controller: stepsController,
                decoration: const InputDecoration(labelText: 'Langkah (pisahkan baris)'),
                maxLines: 6,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: saveRecipe,
                child: const Text('Simpan'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
