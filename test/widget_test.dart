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
        'ingredients': ['Flour', 'Milk', 'Eggs'],
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
      expect(recipe.ingredients.length, 3);
      expect(recipe.cookingTime, 15);
      expect(recipe.servings, 2);
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
