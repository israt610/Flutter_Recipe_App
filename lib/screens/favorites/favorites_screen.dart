import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/recipe_provider.dart';
import '../../providers/favorite_provider.dart';
import '../../widgets/recipe_card.dart';
import '../../utils/constants.dart';
import '../../app/routes.dart';

class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final recipeProvider = Provider.of<RecipeProvider>(context);
    final favoriteProvider = Provider.of<FavoriteProvider>(context);

    final favRecipes = recipeProvider.recipes
        .where((r) => favoriteProvider.isFavorite(r.id))
        .toList();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('My Favorites'),
      ),
      body: favRecipes.isEmpty
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.favorite_border, size: 64, color: AppColors.textMuted),
                  SizedBox(height: 16),
                  Text(
                    'No Favorite Recipes Yet',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Tap the heart icon on any recipe to save it here.',
                    style: TextStyle(color: AppColors.textSecondary),
                  ),
                ],
              ),
            )
          : GridView.builder(
              padding: const EdgeInsets.all(20),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.72,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
              ),
              itemCount: favRecipes.length,
              itemBuilder: (context, index) {
                final recipe = favRecipes[index].copyWith(isFavorite: true);
                return RecipeCard(
                  recipe: recipe,
                  onTap: () {
                    Navigator.pushNamed(
                      context,
                      AppRoutes.recipeDetail,
                      arguments: recipe,
                    );
                  },
                  onFavoriteTap: () {
                    final uid = authProvider.userModel?.uid ?? '';
                    favoriteProvider.toggleFavorite(uid, recipe.id);
                  },
                );
              },
            ),
    );
  }
}
