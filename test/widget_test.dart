import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_recipe/models/recipe_model.dart';
import 'package:flutter_recipe/models/user_model.dart';

void main() {
  group('Recipe Model Tests', () {
    test('Recipe.fromMap creates valid Recipe instance', () {
      final map = {
        'title': 'Test Pancake',
        'description': 'Fluffy pancakes',
        'imageUrl': 'https://example.com/pancake.jpg',
        'category': 'Breakfast',
        'ingredients': ['Flour: 200 g', 'Milk: 100 ml'],
        'instructions': ['Mix ingredients', 'Cook on skillet'],
        'cookingTime': 15,
        'servings': 2,
        'difficulty': 'Easy',
        'rating': 4.5,
        'createdBy': 'Chef Test',
      };

      final recipe = Recipe.fromMap(map, 'test_id_1');

      expect(recipe.id, 'test_id_1');
      expect(recipe.title, 'Test Pancake');
      expect(recipe.category, 'Breakfast');
      expect(recipe.ingredients.length, 2);
      expect(recipe.cookingTime, 15);
      expect(recipe.servings, 2);
    });

    test('Recipe.getScaledIngredients scales ingredient quantities correctly', () {
      final recipe = Recipe(
        id: 'paneer_1',
        title: 'Butter Paneer',
        description: 'Test description',
        imageUrl: '',
        category: 'Dinner',
        ingredients: ['Paneer: 400 g', 'Butter: 100 g'],
        instructions: ['Cook'],
        cookingTime: 25,
        servings: 1,
        difficulty: 'Easy',
        createdBy: 'Chef',
      );

      final scaledFor2 = recipe.getScaledIngredients(2);
      expect(scaledFor2[0], 'Paneer: 800 g');
      expect(scaledFor2[1], 'Butter: 200 g');

      final scaledFor3 = recipe.getScaledIngredients(3);
      expect(scaledFor3[0], 'Paneer: 1200 g');
      expect(scaledFor3[1], 'Butter: 300 g');
    });

    test('UserModel.fromMap creates valid UserModel instance', () {
      final map = {
        'email': 'test@example.com',
        'displayName': 'Test User',
        'favorites': ['recipe_1', 'recipe_2'],
      };

      final user = UserModel.fromMap(map, 'user_id_1');

      expect(user.uid, 'user_id_1');
      expect(user.email, 'test@example.com');
      expect(user.displayName, 'Test User');
      expect(user.favorites.length, 2);
    });
  });
}
