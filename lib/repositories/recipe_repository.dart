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

  Future<String> createRecipe(Recipe recipe) async {
    return await _firestoreService.createRecipe(recipe);
  }

  Future<void> updateRecipe(Recipe recipe) async {
    await _firestoreService.updateRecipe(recipe);
  }

  Future<void> deleteRecipe(String recipeId) async {
    await _firestoreService.deleteRecipe(recipeId);
  }

  List<Recipe> getSampleRecipes() {
    return [
      Recipe(
        id: 'sample_paneer_butter',
        title: 'Butter Paneer',
        description: 'Rich and creamy cottage cheese cubes simmered in a velvety tomato, butter, and cashew gravy.',
        imageUrl: 'https://images.unsplash.com/photo-1631452180519-c014fe946bc7?auto=format&fit=crop&w=800&q=80',
        category: 'Dinner',
        ingredients: [
          'Paneer: 400 g',
          'Butter: 100 g',
          'Heavy Cream: 50 ml',
          'Tomato Puree: 200 g',
          'Garam Masala: 1 tsp',
        ],
        instructions: [
          'Cut paneer into bite-sized cubes.',
          'Melt butter in a pan and saute tomato puree with spices until fragrant.',
          'Add cream and cashew paste, gently simmer for 5 minutes.',
          'Stir in paneer cubes and cook for 3 minutes before serving with naan.'
        ],
        cookingTime: 25,
        calories: 320,
        servings: 1,
        difficulty: 'Easy',
        rating: 4.8,
        reviewCount: 32,
        createdBy: 'Chef Raj',
      ),
      Recipe(
        id: 'sample_paneer_tikka',
        title: 'Paneer Tikka',
        description: 'Tandoori marinated paneer cubes and bell peppers grilled to smoky perfection.',
        imageUrl: 'https://images.unsplash.com/photo-1567188040759-fb8a883dc6d8?auto=format&fit=crop&w=800&q=80',
        category: 'Snack',
        ingredients: [
          'Paneer: 300 g',
          'Yogurt: 100 g',
          'Bell Peppers: 150 g',
          'Tikka Masala: 2 tbsp',
        ],
        instructions: [
          'Marinate paneer and veggies in spiced yogurt for 30 minutes.',
          'Thread onto skewers alternating paneer and bell peppers.',
          'Grill or bake at 400°F (200°C) for 15 minutes until charred at edges.'
        ],
        cookingTime: 20,
        calories: 220,
        servings: 1,
        difficulty: 'Easy',
        rating: 4.9,
        reviewCount: 28,
        createdBy: 'Chef Raj',
      ),
      Recipe(
        id: 'sample_paneer_curry',
        title: 'Paneer Curry',
        description: 'Homestyle paneer curry cooked with onions, tomatoes, and aromatic spices.',
        imageUrl: 'https://images.unsplash.com/photo-1546833999-b9f581a1996d?auto=format&fit=crop&w=800&q=80',
        category: 'Dinner',
        ingredients: [
          'Paneer: 350 g',
          'Onions: 200 g',
          'Tomatoes: 150 g',
          'Spices: 2 tbsp',
        ],
        instructions: [
          'Saute chopped onions and tomatoes until soft.',
          'Blend into a smooth paste and return to skillet with spices.',
          'Add water and paneer cubes, simmer for 8 minutes.'
        ],
        cookingTime: 30,
        calories: 280,
        servings: 1,
        difficulty: 'Medium',
        rating: 4.6,
        reviewCount: 19,
        createdBy: 'Chef Raj',
      ),
      Recipe(
        id: 'sample_pizza',
        title: 'Mexican Pizza',
        description: 'Crispy tortilla pizza topped with seasoned beans, melted cheese, black olives, green onions, sour cream, and fresh diced tomatoes.',
        imageUrl: 'https://images.unsplash.com/photo-1565299624946-b28f40a0ae38?auto=format&fit=crop&w=800&q=80',
        category: 'Dinner',
        ingredients: [
          'Tortilla Shells: 2 pcs',
          'Refried Beans: 150 g',
          'Shredded Cheese: 100 g',
          'Diced Tomatoes: 50 g',
          'Sour Cream: 2 tbsp',
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
    ];
  }
}
