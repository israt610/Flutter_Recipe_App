import 'package:cloud_firestore/cloud_firestore.dart';

class Recipe {
  final String id;
  final String title;
  final String description;
  final String imageUrl;
  final String category;
  final List<String> ingredients;
  final List<String> instructions;
  final int cookingTime; // in minutes
  final int calories; // e.g. 140 Cal
  final int servings; // base servings
  final String difficulty; // Easy, Medium, Hard
  final double rating;
  final int reviewCount;
  final String createdBy;
  final DateTime createdAt;
  final bool isFavorite;

  Recipe({
    required this.id,
    required this.title,
    required this.description,
    required this.imageUrl,
    required this.category,
    required this.ingredients,
    required this.instructions,
    required this.cookingTime,
    this.calories = 140,
    required this.servings,
    required this.difficulty,
    this.rating = 4.5,
    this.reviewCount = 20,
    required this.createdBy,
    DateTime? createdAt,
    this.isFavorite = false,
  }) : createdAt = createdAt ?? DateTime.now();

  factory Recipe.fromMap(Map<String, dynamic> map, String docId, {bool isFav = false}) {
    num? parseNum(dynamic val) {
      if (val == null) return null;
      if (val is num) return val;
      if (val is String) return num.tryParse(val);
      return null;
    }

    List<String> parseStringList(dynamic val) {
      if (val == null) return [];
      if (val is List) {
        return val.map((e) => e.toString()).where((e) => e.trim().isNotEmpty).toList();
      }
      if (val is String && val.trim().isNotEmpty) {
        if (val.contains('\n')) {
          return val.split('\n').map((e) => e.trim()).where((e) => e.isNotEmpty).toList();
        }
        if (val.contains(',')) {
          return val.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList();
        }
        return [val.trim()];
      }
      return [];
    }

    DateTime parseDateTime(dynamic val) {
      if (val == null) return DateTime.now();
      if (val is Timestamp) return val.toDate();
      if (val is DateTime) return val;
      if (val is int) return DateTime.fromMillisecondsSinceEpoch(val);
      if (val is String) return DateTime.tryParse(val) ?? DateTime.now();
      return DateTime.now();
    }

    return Recipe(
      id: docId,
      title: map['title']?.toString() ?? '',
      description: map['description']?.toString() ?? '',
      imageUrl: map['imageUrl']?.toString() ?? '',
      category: map['category']?.toString() ?? 'All',
      ingredients: parseStringList(map['ingredients']),
      instructions: parseStringList(map['instructions']),
      cookingTime: parseNum(map['cookingTime'])?.toInt() ?? 0,
      calories: parseNum(map['calories'])?.toInt() ?? 140,
      servings: parseNum(map['servings'])?.toInt() ?? 1,
      difficulty: map['difficulty']?.toString() ?? 'Easy',
      rating: parseNum(map['rating'])?.toDouble() ?? 4.5,
      reviewCount: parseNum(map['reviewCount'])?.toInt() ?? 20,
      createdBy: map['createdBy']?.toString() ?? '',
      createdAt: parseDateTime(map['createdAt']),
      isFavorite: isFav,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'imageUrl': imageUrl,
      'category': category,
      'ingredients': ingredients,
      'instructions': instructions,
      'cookingTime': cookingTime,
      'calories': calories,
      'servings': servings,
      'difficulty': difficulty,
      'rating': rating,
      'reviewCount': reviewCount,
      'createdBy': createdBy,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  /// Calculates displayed ingredient amounts locally for dynamic targetServings
  /// without modifying original Firestore ingredient list.
  List<String> getScaledIngredients(int targetServings) {
    if (targetServings < 1) targetServings = 1;
    final int baseServings = servings > 0 ? servings : 1;
    final double ratio = targetServings / baseServings;

    return ingredients.map((ing) {
      // Matches pattern: "Ingredient Name 400 g" or "Paneer: 400 g" or "400 g Paneer"
      final RegExp numRegExp = RegExp(r'(\d+(?:\.\d+)?)');
      final match = numRegExp.firstMatch(ing);

      if (match == null) return ing;

      final String? numStr = match.group(1);
      if (numStr == null) return ing;
      final double? baseVal = double.tryParse(numStr);
      if (baseVal == null) return ing;

      final double scaledVal = baseVal * ratio;
      // Format to avoid floating point precision artifacts like 400.00000001
      final String formattedVal = scaledVal % 1 == 0
          ? scaledVal.toInt().toString()
          : (scaledVal * 100).roundToDouble() / 100 == (scaledVal * 10).roundToDouble() / 10
              ? scaledVal.toStringAsFixed(1)
              : scaledVal.toStringAsFixed(2);

      return ing.replaceRange(match.start, match.end, formattedVal);
    }).toList();
  }

  Recipe copyWith({
    String? id,
    String? title,
    String? description,
    String? imageUrl,
    String? category,
    List<String>? ingredients,
    List<String>? instructions,
    int? cookingTime,
    int? calories,
    int? servings,
    String? difficulty,
    double? rating,
    int? reviewCount,
    String? createdBy,
    DateTime? createdAt,
    bool? isFavorite,
  }) {
    return Recipe(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      imageUrl: imageUrl ?? this.imageUrl,
      category: category ?? this.category,
      ingredients: ingredients ?? this.ingredients,
      instructions: instructions ?? this.instructions,
      cookingTime: cookingTime ?? this.cookingTime,
      calories: calories ?? this.calories,
      servings: servings ?? this.servings,
      difficulty: difficulty ?? this.difficulty,
      rating: rating ?? this.rating,
      reviewCount: reviewCount ?? this.reviewCount,
      createdBy: createdBy ?? this.createdBy,
      createdAt: createdAt ?? this.createdAt,
      isFavorite: isFavorite ?? this.isFavorite,
    );
  }
}
