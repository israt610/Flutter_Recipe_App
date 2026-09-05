import 'package:flutter/material.dart';
import '../repositories/recipe_repository.dart';

class FavoriteProvider extends ChangeNotifier {
  final RecipeRepository _recipeRepository;
  final Set<String> _favoriteIds = {};

  FavoriteProvider({RecipeRepository? recipeRepository})
      : _recipeRepository = recipeRepository ?? RecipeRepository();

  Set<String> get favoriteIds => _favoriteIds;

  bool isFavorite(String recipeId) {
    return _favoriteIds.contains(recipeId);
  }

  void initializeFavorites(List<String> userFavorites) {
    _favoriteIds.clear();
    _favoriteIds.addAll(userFavorites);
    notifyListeners();
  }

  Future<void> toggleFavorite(String uid, String recipeId) async {
    final bool currentlyFav = _favoriteIds.contains(recipeId);
    if (currentlyFav) {
      _favoriteIds.remove(recipeId);
    } else {
      _favoriteIds.add(recipeId);
    }
    notifyListeners();

    try {
      if (uid.isNotEmpty) {
        await _recipeRepository.toggleFavorite(uid, recipeId, !currentlyFav);
      }
    } catch (_) {
      // Rollback on failure if needed
    }
  }
}
