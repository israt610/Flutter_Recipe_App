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
  final int servings;
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
    return Recipe(
      id: docId,
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      imageUrl: map['imageUrl'] ?? '',
      category: map['category'] ?? 'All',
      ingredients: List<String>.from(map['ingredients'] ?? []),
      instructions: List<String>.from(map['instructions'] ?? []),
      cookingTime: (map['cookingTime'] as num?)?.toInt() ?? 0,
      calories: (map['calories'] as num?)?.toInt() ?? 140,
      servings: (map['servings'] as num?)?.toInt() ?? 1,
      difficulty: map['difficulty'] ?? 'Easy',
      rating: (map['rating'] as num?)?.toDouble() ?? 4.5,
      reviewCount: (map['reviewCount'] as num?)?.toInt() ?? 20,
      createdBy: map['createdBy'] ?? '',
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
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
