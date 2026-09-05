import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/recipe_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/recipe_provider.dart';
import '../../utils/constants.dart';

class IngredientInputRow {
  final TextEditingController nameController;
  final TextEditingController amountController;
  String unit;

  IngredientInputRow({
    required this.nameController,
    required this.amountController,
    this.unit = 'g',
  });

  void dispose() {
    nameController.dispose();
    amountController.dispose();
  }
}

class AddEditRecipeScreen extends StatefulWidget {
  final Recipe? recipe;

  const AddEditRecipeScreen({super.key, this.recipe});

  @override
  State<AddEditRecipeScreen> createState() => _AddEditRecipeScreenState();
}

class _AddEditRecipeScreenState extends State<AddEditRecipeScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isInitialized = false;
  bool _isSubmitting = false;

  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  late TextEditingController _imageUrlController;
  late TextEditingController _cookingTimeController;
  late TextEditingController _servingsController;
  late TextEditingController _caloriesController;

  String _selectedCategory = 'Dinner';
  String _selectedDifficulty = 'Easy';

  final List<IngredientInputRow> _ingredientRows = [];
  final List<TextEditingController> _instructionControllers = [];

  final List<String> _categories = [
    'Dinner',
    'Lunch',
    'Breakfast',
    'Dessert',
    'Snack',
    'Drink',
    'Vegetarian',
  ];

  final List<String> _units = [
    'g',
    'kg',
    'ml',
    'L',
    'cup',
    'tbsp',
    'tsp',
    'pcs',
    'to taste',
  ];

  final List<String> _difficulties = ['Easy', 'Medium', 'Hard'];

  Recipe? _editingRecipe;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isInitialized) {
      final Object? args = ModalRoute.of(context)?.settings.arguments;
      _editingRecipe = widget.recipe ?? (args is Recipe ? args : null);

      if (_editingRecipe != null) {
        _titleController = TextEditingController(text: _editingRecipe!.title);
        _descriptionController = TextEditingController(text: _editingRecipe!.description);
        _imageUrlController = TextEditingController(text: _editingRecipe!.imageUrl);
        _cookingTimeController = TextEditingController(text: _editingRecipe!.cookingTime.toString());
        _servingsController = TextEditingController(text: _editingRecipe!.servings.toString());
        _caloriesController = TextEditingController(text: _editingRecipe!.calories.toString());

        if (_categories.contains(_editingRecipe!.category)) {
          _selectedCategory = _editingRecipe!.category;
        }
        if (_difficulties.contains(_editingRecipe!.difficulty)) {
          _selectedDifficulty = _editingRecipe!.difficulty;
        }

        // Parse existing ingredients into rows
        if (_editingRecipe!.ingredients.isNotEmpty) {
          for (final ing in _editingRecipe!.ingredients) {
            String name = ing.trim();
            String amount = '100';
            String unit = 'g';

            if (ing.contains(':')) {
              final parts = ing.split(':');
              name = parts[0].trim();
              final remainder = parts.sublist(1).join(':').trim();
              final RegExp amtReg = RegExp(r'^([\d\.]+)\s*(.*)$');
              final match = amtReg.firstMatch(remainder);
              if (match != null) {
                amount = match.group(1) ?? '100';
                final u = match.group(2)?.trim() ?? 'g';
                if (_units.contains(u)) unit = u;
              } else {
                amount = remainder;
              }
            } else {
              final RegExp regex = RegExp(r'^(.*?)\s+([\d\.]+)\s*([A-Za-z%]+)?$');
              final match = regex.firstMatch(ing.trim());
              if (match != null) {
                name = match.group(1)?.trim() ?? ing;
                amount = match.group(2) ?? '1';
                final u = match.group(3)?.trim() ?? 'g';
                if (_units.contains(u)) unit = u;
              }
            }

            _ingredientRows.add(
              IngredientInputRow(
                nameController: TextEditingController(text: name),
                amountController: TextEditingController(text: amount),
                unit: unit,
              ),
            );
          }
        }

        // Parse instructions
        if (_editingRecipe!.instructions.isNotEmpty) {
          for (final inst in _editingRecipe!.instructions) {
            _instructionControllers.add(TextEditingController(text: inst));
          }
        }
      } else {
        _titleController = TextEditingController();
        _descriptionController = TextEditingController();
        _imageUrlController = TextEditingController();
        _cookingTimeController = TextEditingController(text: '25');
        _servingsController = TextEditingController(text: '2');
        _caloriesController = TextEditingController(text: '300');
      }

      if (_ingredientRows.isEmpty) {
        _addIngredientRow();
      }
      if (_instructionControllers.isEmpty) {
        _addInstructionRow();
      }

      _isInitialized = true;
    }
  }

  void _addIngredientRow() {
    setState(() {
      _ingredientRows.add(
        IngredientInputRow(
          nameController: TextEditingController(),
          amountController: TextEditingController(),
          unit: 'g',
        ),
      );
    });
  }

  void _removeIngredientRow(int index) {
    if (_ingredientRows.length > 1) {
      setState(() {
        final removed = _ingredientRows.removeAt(index);
        removed.dispose();
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('At least one ingredient is required.')),
      );
    }
  }

  void _addInstructionRow() {
    setState(() {
      _instructionControllers.add(TextEditingController());
    });
  }

  void _removeInstructionRow(int index) {
    if (_instructionControllers.length > 1) {
      setState(() {
        final removed = _instructionControllers.removeAt(index);
        removed.dispose();
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('At least one instruction step is required.')),
      );
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _imageUrlController.dispose();
    _cookingTimeController.dispose();
    _servingsController.dispose();
    _caloriesController.dispose();
    for (final row in _ingredientRows) {
      row.dispose();
    }
    for (final ctrl in _instructionControllers) {
      ctrl.dispose();
    }
    super.dispose();
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    // Validate ingredient rows
    final List<String> formattedIngredients = [];
    for (final row in _ingredientRows) {
      final name = row.nameController.text.trim();
      final amount = row.amountController.text.trim();
      if (name.isEmpty || amount.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please fill out all ingredient names and amounts.')),
        );
        return;
      }
      formattedIngredients.add('$name: $amount ${row.unit}'.trim());
    }

    // Validate instruction steps
    final List<String> formattedInstructions = [];
    for (final ctrl in _instructionControllers) {
      final text = ctrl.text.trim();
      if (text.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Instruction steps cannot be empty.')),
        );
        return;
      }
      formattedInstructions.add(text);
    }

    setState(() => _isSubmitting = true);

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final recipeProvider = Provider.of<RecipeProvider>(context, listen: false);
    final currentUid = authProvider.currentUserId ?? 'user_guest';

    final String finalImageUrl = _imageUrlController.text.trim().isNotEmpty
        ? _imageUrlController.text.trim()
        : 'https://images.unsplash.com/photo-1631452180519-c014fe946bc7?auto=format&fit=crop&w=800&q=80';

    final bool isEdit = _editingRecipe != null;

    final recipeToSave = Recipe(
      id: isEdit ? _editingRecipe!.id : 'recipe_${DateTime.now().millisecondsSinceEpoch}',
      title: _titleController.text.trim(),
      description: _descriptionController.text.trim(),
      imageUrl: finalImageUrl,
      category: _selectedCategory,
      ingredients: formattedIngredients,
      instructions: formattedInstructions,
      cookingTime: int.tryParse(_cookingTimeController.text.trim()) ?? 25,
      servings: int.tryParse(_servingsController.text.trim()) ?? 2,
      calories: int.tryParse(_caloriesController.text.trim()) ?? 300,
      difficulty: _selectedDifficulty,
      rating: isEdit ? _editingRecipe!.rating : 5.0,
      reviewCount: isEdit ? _editingRecipe!.reviewCount : 1,
      createdBy: isEdit ? _editingRecipe!.createdBy : currentUid,
      createdAt: isEdit ? _editingRecipe!.createdAt : DateTime.now(),
      isFavorite: isEdit ? _editingRecipe!.isFavorite : false,
    );

    if (isEdit) {
      await recipeProvider.updateRecipe(recipeToSave);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Recipe "${recipeToSave.title}" updated successfully!')),
        );
        Navigator.pop(context, recipeToSave);
      }
    } else {
      await recipeProvider.addRecipe(recipeToSave);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Recipe "${recipeToSave.title}" added successfully!')),
        );
        Navigator.pop(context);
      }
    }

    if (mounted) setState(() => _isSubmitting = false);
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = _editingRecipe != null;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(isEdit ? 'Edit Recipe' : 'Add New Recipe'),
        backgroundColor: Colors.white,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'General Details',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
              ),
              const SizedBox(height: 14),

              // Title Field
              TextFormField(
                controller: _titleController,
                style: const TextStyle(fontSize: 14),
                decoration: InputDecoration(
                  labelText: 'Recipe Title *',
                  hintText: 'e.g. Creamy Butter Paneer',
                  fillColor: Colors.white,
                  filled: true,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                ),
                validator: (val) {
                  if (val == null || val.trim().isEmpty) return 'Recipe title is required';
                  return null;
                },
              ),
              const SizedBox(height: 14),

              // Description Field
              TextFormField(
                controller: _descriptionController,
                maxLines: 3,
                style: const TextStyle(fontSize: 14),
                decoration: InputDecoration(
                  labelText: 'Description *',
                  hintText: 'Describe taste, origin, or key features...',
                  fillColor: Colors.white,
                  filled: true,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                ),
                validator: (val) {
                  if (val == null || val.trim().isEmpty) return 'Description is required';
                  return null;
                },
              ),
              const SizedBox(height: 14),

              // Category & Difficulty Row
              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      initialValue: _selectedCategory,
                      decoration: InputDecoration(
                        labelText: 'Category *',
                        fillColor: Colors.white,
                        filled: true,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                      ),
                      items: _categories
                          .map((cat) => DropdownMenuItem(value: cat, child: Text(cat, style: const TextStyle(fontSize: 13))))
                          .toList(),
                      onChanged: (val) {
                        if (val != null) setState(() => _selectedCategory = val);
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      initialValue: _selectedDifficulty,
                      decoration: InputDecoration(
                        labelText: 'Difficulty',
                        fillColor: Colors.white,
                        filled: true,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                      ),
                      items: _difficulties
                          .map((diff) => DropdownMenuItem(value: diff, child: Text(diff, style: const TextStyle(fontSize: 13))))
                          .toList(),
                      onChanged: (val) {
                        if (val != null) setState(() => _selectedDifficulty = val);
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),

              // Image URL Field
              TextFormField(
                controller: _imageUrlController,
                style: const TextStyle(fontSize: 14),
                decoration: InputDecoration(
                  labelText: 'Image URL (Optional)',
                  hintText: 'https://example.com/food.jpg',
                  fillColor: Colors.white,
                  filled: true,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                ),
              ),
              const SizedBox(height: 14),

              // Cooking Time, Servings, Calories Row
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _cookingTimeController,
                      keyboardType: TextInputType.number,
                      style: const TextStyle(fontSize: 14),
                      decoration: InputDecoration(
                        labelText: 'Time (Mins) *',
                        fillColor: Colors.white,
                        filled: true,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                      ),
                      validator: (val) {
                        if (val == null || val.trim().isEmpty) return 'Required';
                        final n = int.tryParse(val.trim());
                        if (n == null || n <= 0) return 'Must be > 0';
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: TextFormField(
                      controller: _servingsController,
                      keyboardType: TextInputType.number,
                      style: const TextStyle(fontSize: 14),
                      decoration: InputDecoration(
                        labelText: 'Servings *',
                        fillColor: Colors.white,
                        filled: true,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                      ),
                      validator: (val) {
                        if (val == null || val.trim().isEmpty) return 'Required';
                        final n = int.tryParse(val.trim());
                        if (n == null || n <= 0) return 'Must be > 0';
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: TextFormField(
                      controller: _caloriesController,
                      keyboardType: TextInputType.number,
                      style: const TextStyle(fontSize: 14),
                      decoration: InputDecoration(
                        labelText: 'Calories',
                        fillColor: Colors.white,
                        filled: true,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 28),

              // Dynamic Ingredients Section Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Ingredients *',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                  ),
                  TextButton.icon(
                    onPressed: _addIngredientRow,
                    icon: const Icon(Icons.add, size: 18, color: AppColors.primary),
                    label: const Text('Add Item', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              // Ingredients Rows List
              ..._ingredientRows.asMap().entries.map((entry) {
                final idx = entry.key;
                final row = entry.value;

                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        flex: 3,
                        child: TextFormField(
                          controller: row.nameController,
                          style: const TextStyle(fontSize: 13),
                          decoration: InputDecoration(
                            hintText: 'Item name (e.g. Paneer)',
                            isDense: true,
                            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        flex: 2,
                        child: TextFormField(
                          controller: row.amountController,
                          style: const TextStyle(fontSize: 13),
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            hintText: 'Qty (400)',
                            isDense: true,
                            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      DropdownButton<String>(
                        value: row.unit,
                        style: const TextStyle(fontSize: 13, color: AppColors.textPrimary),
                        underline: const SizedBox(),
                        items: _units.map((u) => DropdownMenuItem(value: u, child: Text(u))).toList(),
                        onChanged: (val) {
                          if (val != null) setState(() => row.unit = val);
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.remove_circle_outline, color: AppColors.error, size: 20),
                        onPressed: () => _removeIngredientRow(idx),
                      ),
                    ],
                  ),
                );
              }),
              const SizedBox(height: 20),

              // Dynamic Instructions Section Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Instructions *',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                  ),
                  TextButton.icon(
                    onPressed: _addInstructionRow,
                    icon: const Icon(Icons.add, size: 18, color: AppColors.primary),
                    label: const Text('Add Step', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              // Instructions Rows List
              ..._instructionControllers.asMap().entries.map((entry) {
                final idx = entry.key;
                final ctrl = entry.value;

                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CircleAvatar(
                        radius: 12,
                        backgroundColor: AppColors.badgeBackground,
                        child: Text(
                          '${idx + 1}',
                          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.primary),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: TextFormField(
                          controller: ctrl,
                          maxLines: 2,
                          style: const TextStyle(fontSize: 13),
                          decoration: InputDecoration(
                            hintText: 'Describe this cooking step...',
                            isDense: true,
                            contentPadding: const EdgeInsets.all(10),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.remove_circle_outline, color: AppColors.error, size: 20),
                        onPressed: () => _removeInstructionRow(idx),
                      ),
                    ],
                  ),
                );
              }),
              const SizedBox(height: 28),

              // Submit Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isSubmitting ? null : _submitForm,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  ),
                  child: _isSubmitting
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                        )
                      : Text(
                          isEdit ? 'Update Recipe' : 'Save & Publish Recipe',
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                ),
              ),
              const SizedBox(height: 36),
            ],
          ),
        ),
      ),
    );
  }
}
