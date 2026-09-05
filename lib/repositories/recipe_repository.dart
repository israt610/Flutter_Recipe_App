import '../services/firestore_service.dart';
import '../models/recipe_model.dart';

class RecipeRepository {
  final FirestoreService _firestoreService;

  RecipeRepository({FirestoreService? firestoreService})
      : _firestoreService = firestoreService ?? FirestoreService();

  Future<List<Recipe>> fetchRecipes() async {
    try {
      return await _firestoreService.getRecipes();
    } catch (_) {
      // Fallback sample recipes if Firestore has no data yet
      return getSampleRecipes();
    }
  }

  Future<void> toggleFavorite(String uid, String recipeId, bool isFavorite) async {
    await _firestoreService.toggleFavorite(uid, recipeId, isFavorite);
  }

  List<Recipe> getSampleRecipes() {
    return [
      Recipe(
        id: 'sample_1',
        title: 'Creamy Garlic Tuscan Chicken',
        description: 'Tender chicken breasts in a rich garlic, sun-dried tomato, and spinach cream sauce.',
        imageUrl: 'https://images.unsplash.com/photo-1604908176997-125f25cc6f3d?auto=format&fit=crop&w=800&q=80',
        category: 'Dinner',
        ingredients: [
          '2 large chicken breasts, halved horizontally',
          '1 tbsp olive oil',
          '1 cup heavy cream',
          '1/2 cup chicken broth',
          '1 tsp garlic powder',
          '1 cup spinach',
          '1/2 cup sun-dried tomatoes',
        ],
        instructions: [
          'Season chicken breasts with salt, pepper, and garlic powder.',
          'Heat olive oil in a skillet and sear chicken for 5 minutes each side until golden.',
          'Remove chicken and set aside. Add garlic, chicken broth, and heavy cream to skillet.',
          'Bring to a gentle simmer, then stir in sun-dried tomatoes and fresh spinach.',
          'Return chicken to skillet and simmer for 3-5 minutes until sauce thickens.'
        ],
        cookingTime: 25,
        servings: 4,
        difficulty: 'Medium',
        rating: 4.8,
        createdBy: 'Chef Mario',
      ),
      Recipe(
        id: 'sample_2',
        title: 'Classic Avocado Toast',
        description: 'Crispy sourdough topped with mashed avocado, poached egg, and red pepper flakes.',
        imageUrl: 'https://images.unsplash.com/photo-1525351484163-7529414344d8?auto=format&fit=crop&w=800&q=80',
        category: 'Breakfast',
        ingredients: [
          '2 slices sourdough bread',
          '1 ripe avocado',
          '1 tbsp lemon juice',
          '2 eggs',
          'Red pepper flakes, salt, and pepper',
        ],
        instructions: [
          'Toast the sourdough bread until crispy and golden.',
          'Mash avocado with lemon juice, salt, and pepper in a small bowl.',
          'Poach or fry eggs to desired crispness.',
          'Spread mashed avocado over toast and top with warm eggs and red pepper flakes.'
        ],
        cookingTime: 10,
        servings: 2,
        difficulty: 'Easy',
        rating: 4.6,
        createdBy: 'Emily Green',
      ),
      Recipe(
        id: 'sample_3',
        title: 'Berry Acai Smoothie Bowl',
        description: 'Refreshing blended berry smoothie bowl topped with fresh fruit, chia, and granola.',
        imageUrl: 'https://images.unsplash.com/photo-1590301157890-4810ed352733?auto=format&fit=crop&w=800&q=80',
        category: 'Breakfast',
        ingredients: [
          '1 frozen acai packet',
          '1 cup frozen mixed berries',
          '1/2 cup almond milk',
          '1 banana',
          'Granola, chia seeds, sliced strawberries for topping',
        ],
        instructions: [
          'Blend acai, frozen berries, banana, and almond milk until thick and smooth.',
          'Pour into a chilled bowl.',
          'Top with granola, chia seeds, and fresh sliced fruit.'
        ],
        cookingTime: 8,
        servings: 1,
        difficulty: 'Easy',
        rating: 4.9,
        createdBy: 'Fitness Bite',
      ),
      Recipe(
        id: 'sample_4',
        title: 'Double Chocolate Fudge Brownies',
        description: 'Rich, fudgy chocolate brownies with a crinkly top and gooey chocolate chips.',
        imageUrl: 'https://images.unsplash.com/photo-1606313564200-e75d5e30476c?auto=format&fit=crop&w=800&q=80',
        category: 'Dessert',
        ingredients: [
          '1 cup unsalted butter, melted',
          '2 cups granulated sugar',
          '4 large eggs',
          '1 cup all-purpose flour',
          '1 cup cocoa powder',
          '1 cup dark chocolate chips',
        ],
        instructions: [
          'Preheat oven to 350°F (175°C) and line an 8x8 baking pan.',
          'Whisk melted butter, sugar, and eggs until pale and fluffy.',
          'Fold in flour and cocoa powder until just combined, then stir in chocolate chips.',
          'Bake for 25-30 minutes until edges are set.'
        ],
        cookingTime: 35,
        servings: 9,
        difficulty: 'Medium',
        rating: 4.9,
        createdBy: 'Sweet Tooth',
      ),
    ];
  }
}
