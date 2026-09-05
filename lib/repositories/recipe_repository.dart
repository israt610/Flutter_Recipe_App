import '../services/firestore_service.dart';
import '../models/recipe_model.dart';

class RecipeRepository {
  final FirestoreService _firestoreService;

  RecipeRepository({FirestoreService? firestoreService})
      : _firestoreService = firestoreService ?? FirestoreService();

  Future<List<Recipe>> fetchRecipes() async {
    try {
      final recipes = await _firestoreService.getRecipes();
      if (recipes.isEmpty) {
        return getSampleRecipes();
      }
      return recipes;
    } catch (_) {
      return getSampleRecipes();
    }
  }

  Future<void> toggleFavorite(String uid, String recipeId, bool isFavorite) async {
    await _firestoreService.toggleFavorite(uid, recipeId, isFavorite);
  }

  List<Recipe> getSampleRecipes() {
    return [
      Recipe(
        id: 'sample_pizza',
        title: 'Mexican Pizza',
        description: 'Crispy tortilla pizza topped with seasoned beans, melted cheese, black olives, green onions, sour cream, and fresh diced tomatoes.',
        imageUrl: 'https://images.unsplash.com/photo-1565299624946-b28f40a0ae38?auto=format&fit=crop&w=800&q=80',
        category: 'Dinner',
        ingredients: [
          'Tortilla Shells 2pcs',
          'Refried Beans 150gm',
          'Shredded Cheese 100gm',
          'Diced Tomatoes 50gm',
          'Sour Cream 2tbsp',
        ],
        instructions: [
          'Crisp tortilla shells in oven at 200°C for 5 minutes.',
          'Spread refried beans and shredded cheese over tortillas.',
          'Bake until cheese is melted and bubbling.',
          'Top with diced tomatoes, black olives, green onions, and sour cream.'
        ],
        cookingTime: 25,
        calories: 140,
        servings: 2,
        difficulty: 'Easy',
        rating: 0.0,
        reviewCount: 0,
        createdBy: 'Chef Mario',
      ),
      Recipe(
        id: 'sample_french_toast',
        title: 'French Toast',
        description: 'Golden brioche bread soaked in rich cinnamon egg batter, served with fresh berries and syrup.',
        imageUrl: 'https://images.unsplash.com/photo-1484723091739-30a097e8f929?auto=format&fit=crop&w=800&q=80',
        category: 'Breakfast',
        ingredients: [
          'Brioche Bread 4 slices',
          'Whole Milk 100ml',
          'Eggs 2pcs',
          'Fresh Berries 50gm',
          'Maple Syrup 3tbsp',
        ],
        instructions: [
          'Whisk eggs, milk, and cinnamon in a shallow bowl.',
          'Dip bread slices in mixture until coated.',
          'Cook on a buttered pan over medium heat until golden.',
          'Serve warm topped with berries and maple syrup.'
        ],
        cookingTime: 15,
        calories: 110,
        servings: 2,
        difficulty: 'Easy',
        rating: 4.7,
        reviewCount: 18,
        createdBy: 'Emily Green',
      ),
      Recipe(
        id: 'sample_steak',
        title: 'Beef Steak',
        description: 'Pan-seared juicy ribeye steak basted with garlic butter and fresh herbs, served with mashed potatoes.',
        imageUrl: 'https://images.unsplash.com/photo-1544025162-d76694265947?auto=format&fit=crop&w=800&q=80',
        category: 'Dinner',
        ingredients: [
          'Beef 400.0gm',
          'Vegetables 100.0gm',
          'Butter 30gm',
          'Garlic 3cloves',
        ],
        instructions: [
          'Season steak generously with salt and pepper.',
          'Sear in hot skillet for 3 minutes each side.',
          'Baste with garlic butter and rosemary.',
          'Rest 5 minutes before serving with steamed vegetables.'
        ],
        cookingTime: 25,
        calories: 140,
        servings: 1,
        difficulty: 'Medium',
        rating: 4.5,
        reviewCount: 20,
        createdBy: 'Gordon Ramsey',
      ),
    ];
  }
}
