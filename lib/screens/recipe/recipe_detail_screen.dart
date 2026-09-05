import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/recipe_model.dart';
import '../../providers/favorite_provider.dart';
import '../../providers/auth_provider.dart';
import '../../utils/constants.dart';

class RecipeDetailScreen extends StatefulWidget {
  final Recipe? recipe;

  const RecipeDetailScreen({super.key, this.recipe});

  @override
  State<RecipeDetailScreen> createState() => _RecipeDetailScreenState();
}

class _RecipeDetailScreenState extends State<RecipeDetailScreen> {
  int _servings = 2;
  int _selectedRating = 5;
  final TextEditingController _reviewController = TextEditingController();

  @override
  void initState() {
    super.initState();
    final Recipe item = widget.recipe ?? Recipe(
      id: '0',
      title: 'Mexican Pizza',
      description: 'Crispy tortilla pizza topped with seasoned beans.',
      imageUrl: '',
      category: 'Dinner',
      ingredients: [],
      instructions: [],
      cookingTime: 25,
      calories: 140,
      servings: 2,
      difficulty: 'Easy',
      createdBy: 'Chef',
    );
    _servings = item.servings > 0 ? item.servings : 2;
  }

  @override
  void dispose() {
    _reviewController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Recipe item = widget.recipe ??
        ModalRoute.of(context)?.settings.arguments as Recipe? ??
        Recipe(
          id: '0',
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
        );

    final authProvider = Provider.of<AuthProvider>(context);
    final favoriteProvider = Provider.of<FavoriteProvider>(context);
    final bool isFav = favoriteProvider.isFavorite(item.id);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          // Top Food Hero Image
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: MediaQuery.of(context).size.height * 0.42,
            child: Image.network(
              item.imageUrl,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => Container(
                color: AppColors.primaryLight,
                child: const Icon(Icons.restaurant, size: 80, color: Colors.white),
              ),
            ),
          ),

          // Top Header Back Button (Matching Reference Image 3)
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Row(
                children: [
                  Container(
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.arrow_back_ios_new, size: 18, color: AppColors.textPrimary),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Bottom Sheet Content Container (Matching Reference Images 1 & 3)
          Positioned.fill(
            top: MediaQuery.of(context).size.height * 0.36,
            child: Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
              ),
              child: Column(
                children: [
                  // Drag handle pill
                  const SizedBox(height: 12),
                  Container(
                    width: 40,
                    height: 5,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Scrollable Detail Body
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(horizontal: 24.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Title & Category Badge Pill Row (Matching Reference Image 3)
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Expanded(
                                child: Text(
                                  item.title,
                                  style: const TextStyle(
                                    fontSize: 22,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                                decoration: BoxDecoration(
                                  color: AppColors.badgeBackground,
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                child: Text(
                                  item.category,
                                  style: const TextStyle(
                                    color: AppColors.primary,
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),

                          // Description Text (Matching Reference Image 3)
                          Text(
                            item.description,
                            style: const TextStyle(
                              fontSize: 13,
                              color: AppColors.textSecondary,
                              height: 1.45,
                            ),
                          ),
                          const SizedBox(height: 12),

                          // Calorie & Cooking Time Row
                          Row(
                            children: [
                              const Icon(Icons.bolt_rounded, size: 16, color: AppColors.textSecondary),
                              const SizedBox(width: 4),
                              Text(
                                '${item.calories} Cal',
                                style: const TextStyle(
                                  fontSize: 13,
                                  color: AppColors.textSecondary,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(width: 8),
                              const Text('•', style: TextStyle(color: AppColors.textSecondary)),
                              const SizedBox(width: 8),
                              const Icon(Icons.access_time_rounded, size: 15, color: AppColors.textSecondary),
                              const SizedBox(width: 4),
                              Text(
                                '${item.cookingTime} Min',
                                style: const TextStyle(
                                  fontSize: 13,
                                  color: AppColors.textSecondary,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),

                          // Ratings & Reviews Line
                          Row(
                            children: [
                              const Icon(Icons.star_rounded, size: 18, color: AppColors.starRating),
                              const SizedBox(width: 4),
                              Text(
                                item.rating > 0 ? '${item.rating.toStringAsFixed(1)}/5' : 'No ratings yet',
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                item.reviewCount > 0 ? '(${item.reviewCount} Reviews)' : '(No reviews yet)',
                                style: const TextStyle(
                                  fontSize: 13,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 24),

                          // Ingredients Header & Serving Counter (Matching Reference Image 3)
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Ingredients',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.textPrimary,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    'How many servings?',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: AppColors.textSecondary.withValues(alpha: 0.8),
                                    ),
                                  ),
                                ],
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(24),
                                  border: Border.all(color: AppColors.border),
                                ),
                                child: Row(
                                  children: [
                                    GestureDetector(
                                      onTap: () {
                                        if (_servings > 1) {
                                          setState(() => _servings--);
                                        }
                                      },
                                      child: const Icon(Icons.remove, size: 18, color: AppColors.textPrimary),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(horizontal: 16),
                                      child: Text(
                                        '$_servings',
                                        style: const TextStyle(
                                          fontSize: 15,
                                          fontWeight: FontWeight.bold,
                                          color: AppColors.textPrimary,
                                        ),
                                      ),
                                    ),
                                    GestureDetector(
                                      onTap: () {
                                        setState(() => _servings++);
                                      },
                                      child: const Icon(Icons.add, size: 18, color: AppColors.textPrimary),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),

                          // Ingredient List Items (Matching Reference Image 3)
                          if (item.ingredients.isEmpty)
                            const Text('No ingredients listed.', style: TextStyle(color: AppColors.textSecondary))
                          else
                            ...item.ingredients.map((ing) {
                              final parts = ing.split(' ');
                              final name = parts.length > 1 ? parts.sublist(0, parts.length - 1).join(' ') : ing;
                              final weight = parts.length > 1 ? parts.last : '';

                              return Padding(
                                padding: const EdgeInsets.symmetric(vertical: 8.0),
                                child: Row(
                                  children: [
                                    Container(
                                      width: 36,
                                      height: 36,
                                      decoration: BoxDecoration(
                                        color: AppColors.badgeBackground.withValues(alpha: 0.6),
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Icon(Icons.restaurant, color: AppColors.textSecondary, size: 18),
                                    ),
                                    const SizedBox(width: 14),
                                    Expanded(
                                      child: Text(
                                        name.isNotEmpty ? name : ing,
                                        style: const TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w500,
                                          color: AppColors.textPrimary,
                                        ),
                                      ),
                                    ),
                                    Text(
                                      weight,
                                      style: const TextStyle(
                                        fontSize: 14,
                                        color: AppColors.textSecondary,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }),
                          const SizedBox(height: 28),

                          // Instructions Section Header (Matching Reference Image 1)
                          const Text(
                            'Instructions',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 14),

                          // Numbered Instructions List
                          ...item.instructions.asMap().entries.map(
                                (entry) => Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                                  child: Row(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Container(
                                        width: 24,
                                        height: 24,
                                        decoration: BoxDecoration(
                                          color: AppColors.badgeBackground,
                                          shape: BoxShape.circle,
                                        ),
                                        child: Center(
                                          child: Text(
                                            '${entry.key + 1}',
                                            style: const TextStyle(
                                              fontSize: 12,
                                              fontWeight: FontWeight.bold,
                                              color: AppColors.primary,
                                            ),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Text(
                                          entry.value,
                                          style: const TextStyle(
                                            fontSize: 14,
                                            color: AppColors.textPrimary,
                                            height: 1.45,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                          const SizedBox(height: 28),

                          // Reviews & Ratings Section Header (Matching Reference Image 1)
                          const Text(
                            'Reviews & Ratings',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 12),

                          // Empty Reviews State Box
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                            decoration: BoxDecoration(
                              color: AppColors.background,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: const Text(
                              'No reviews yet. Be the first to review this recipe!',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 13,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),

                          // Leave a Review Card (Matching Reference Image 1)
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: AppColors.border),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Leave a Review',
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                                const SizedBox(height: 12),
                                Row(
                                  children: [
                                    const Text(
                                      'Your Rating: ',
                                      style: TextStyle(fontSize: 13, color: AppColors.textPrimary),
                                    ),
                                    const SizedBox(width: 8),
                                    Row(
                                      children: List.generate(5, (index) {
                                        return GestureDetector(
                                          onTap: () {
                                            setState(() => _selectedRating = index + 1);
                                          },
                                          child: Icon(
                                            Icons.star_rounded,
                                            size: 22,
                                            color: index < _selectedRating ? AppColors.starRating : Colors.grey.shade300,
                                          ),
                                        );
                                      }),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 14),
                                TextField(
                                  controller: _reviewController,
                                  maxLines: 3,
                                  style: const TextStyle(fontSize: 14),
                                  decoration: InputDecoration(
                                    hintText: 'Share your thoughts on this recipe...',
                                    hintStyle: const TextStyle(color: AppColors.textMuted, fontSize: 13),
                                    fillColor: Colors.white,
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(14),
                                      borderSide: const BorderSide(color: AppColors.border),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 16),
                                SizedBox(
                                  width: double.infinity,
                                  child: ElevatedButton(
                                    onPressed: () {
                                      _reviewController.clear();
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(content: Text('Thank you for your review!')),
                                      );
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: AppColors.primary,
                                      foregroundColor: Colors.white,
                                      elevation: 0,
                                      padding: const EdgeInsets.symmetric(vertical: 12),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                    ),
                                    child: const Text(
                                      'Submit Review',
                                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 36),
                        ],
                      ),
                    ),
                  ),

                  // Fixed Bottom Action Bar: Start Cooking & Red Heart Button (Matching Reference Images 1 & 3)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.06),
                          blurRadius: 10,
                          offset: const Offset(0, -4),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () {},
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              foregroundColor: Colors.white,
                              elevation: 0,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(25),
                              ),
                            ),
                            child: const Text(
                              'Start Cooking',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 14),
                        Container(
                          width: 50,
                          height: 50,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: AppColors.border),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.04),
                                blurRadius: 6,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: IconButton(
                            icon: Icon(
                              isFav ? Icons.favorite : Icons.favorite_border,
                              color: AppColors.error,
                              size: 22,
                            ),
                            onPressed: () {
                              final uid = authProvider.userModel?.uid ?? '';
                              favoriteProvider.toggleFavorite(uid, item.id);
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
