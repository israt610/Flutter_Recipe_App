import 'package:flutter/material.dart';
import '../models/recipe_model.dart';
import '../repositories/recipe_repository.dart';

class RecipeProvider extends ChangeNotifier {
  final RecipeRepository _recipeRepository;

  List<Recipe> _recipes = [];
  bool _isLoading = false;
  String _selectedCategory = 'All';
  String _searchQuery = '';
  String? _errorMessage;

  RecipeProvider({RecipeRepository? recipeRepository})
      : _recipeRepository = recipeRepository ?? RecipeRepository() {
    fetchRecipes();
  }

  List<Recipe> get recipes => _recipes;
  bool get isLoading => _isLoading;
  String get selectedCategory => _selectedCategory;
  String get searchQuery => _searchQuery;
  String? get errorMessage => _errorMessage;

  List<Recipe> get filteredRecipes {
    return _recipes.where((recipe) {
      final matchesCategory =
          _selectedCategory == 'All' || recipe.category.toLowerCase() == _selectedCategory.toLowerCase();
      final matchesSearch = recipe.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          recipe.description.toLowerCase().contains(_searchQuery.toLowerCase());
      return matchesCategory && matchesSearch;
    }).toList();
  }

  Future<void> fetchRecipes() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _recipes = await _recipeRepository.fetchRecipes();
    } catch (e) {
      _errorMessage = 'Failed to load recipes. Showing sample recipes.';
      _recipes = _recipeRepository.getSampleRecipes();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void setCategory(String category) {
    _selectedCategory = category;
    notifyListeners();
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  Future<bool> addRecipe(Recipe recipe) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      final docId = await _recipeRepository.createRecipe(recipe);
      final newRecipe = recipe.copyWith(id: docId);
      _recipes.insert(0, newRecipe);
      return true;
    } catch (e) {
      _errorMessage = 'Failed to save recipe to Firestore: $e';
      _recipes.insert(0, recipe);
      return true;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> updateRecipe(Recipe recipe) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      await _recipeRepository.updateRecipe(recipe);
      final index = _recipes.indexWhere((r) => r.id == recipe.id);
      if (index != -1) {
        _recipes[index] = recipe;
      }
      return true;
    } catch (e) {
      _errorMessage = 'Failed to update recipe: $e';
      final index = _recipes.indexWhere((r) => r.id == recipe.id);
      if (index != -1) {
        _recipes[index] = recipe;
      }
      return true;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> deleteRecipe(String recipeId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      await _recipeRepository.deleteRecipe(recipeId);
      _recipes.removeWhere((r) => r.id == recipeId);
      return true;
    } catch (e) {
      _errorMessage = 'Failed to delete recipe: $e';
      _recipes.removeWhere((r) => r.id == recipeId);
      return true;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void updateRecipeFavoriteStatus(String recipeId, bool isFavorite) {
    final index = _recipes.indexWhere((r) => r.id == recipeId);
    if (index != -1) {
      _recipes[index] = _recipes[index].copyWith(isFavorite: isFavorite);
      notifyListeners();
    }
  }
}
