import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';
import '../models/recipe_model.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // User collection
  CollectionReference get _usersRef => _db.collection('users');
  CollectionReference get _recipesRef => _db.collection('recipes');

  Future<void> createUserProfile(UserModel user) async {
    await _usersRef.doc(user.uid).set(user.toMap(), SetOptions(merge: true));
  }

  Future<UserModel?> getUserProfile(String uid) async {
    final doc = await _usersRef.doc(uid).get();
    if (doc.exists && doc.data() != null) {
      return UserModel.fromMap(doc.data() as Map<String, dynamic>, doc.id);
    }
    return null;
  }

  Future<List<Recipe>> getRecipes() async {
    final snapshot = await _recipesRef.orderBy('createdAt', descending: true).get();
    return snapshot.docs.map((doc) {
      return Recipe.fromMap(doc.data() as Map<String, dynamic>, doc.id);
    }).toList();
  }

  Future<void> toggleFavorite(String uid, String recipeId, bool isFavorite) async {
    final userRef = _usersRef.doc(uid);
    if (isFavorite) {
      await userRef.update({
        'favorites': FieldValue.arrayUnion([recipeId]),
      });
    } else {
      await userRef.update({
        'favorites': FieldValue.arrayRemove([recipeId]),
      });
    }
  }

  Future<String> createRecipe(Recipe recipe) async {
    final docRef = recipe.id.isNotEmpty && !recipe.id.startsWith('custom_') && !recipe.id.startsWith('sample_')
        ? _recipesRef.doc(recipe.id)
        : _recipesRef.doc();
    final map = recipe.toMap();
    map['createdAt'] = FieldValue.serverTimestamp();
    await docRef.set(map);
    return docRef.id;
  }

  Future<void> updateRecipe(Recipe recipe) async {
    final map = recipe.toMap();
    map.remove('createdAt');
    await _recipesRef.doc(recipe.id).update(map);
  }

  Future<void> deleteRecipe(String recipeId) async {
    await _recipesRef.doc(recipeId).delete();
  }
}
