import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/recipe_model.dart';
import '../../providers/favorite_provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/recipe_provider.dart';
import '../../app/routes.dart';
import '../../utils/constants.dart';

class RecipeDetailScreen extends StatefulWidget {
  final Recipe? recipe;

  const RecipeDetailScreen({super.key, this.recipe});

  @override
  State<RecipeDetailScreen> createState() => _RecipeDetailScreenState();
}

class _RecipeDetailScreenState extends State<RecipeDetailScreen> {
  bool _isInitialized = false;
  late Recipe _item;
  late int _servings;
  int _selectedRating = 5;
  double _currentRating = 0.0;
  int _currentReviewCount = 0;
  final TextEditingController _reviewController = TextEditingController();
  final List<Map<String, dynamic>> _userReviews = [];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isInitialized) {
      final Object? args = ModalRoute.of(context)?.settings.arguments;
      Recipe? recipeFromArgs;
      if (widget.recipe != null) {
        recipeFromArgs = widget.recipe;
      } else if (args is Recipe) {
        recipeFromArgs = args;
      } else if (args is Map<String, dynamic>) {
        try {
          recipeFromArgs = Recipe.fromMap(args, args['id']?.toString() ?? 'recipe_id');
        } catch (e) {
          debugPrint('[RECIPE DETAIL DEBUG] Exception parsing Map arguments: $e');
        }
      }

      _item = recipeFromArgs ?? Recipe(
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
      );

      _servings = _item.servings > 0 ? _item.servings : 1;
      _currentRating = _item.rating;
      _currentReviewCount = _item.reviewCount;
      _isInitialized = true;

      debugPrint('=== RECIPE DETAIL DEBUG ===');
      debugPrint('id: ${_item.id}');
      debugPrint('title: ${_item.title}');
      debugPrint('category: ${_item.category}');
      debugPrint('imageUrl: ${_item.imageUrl}');
      debugPrint('description: ${_item.description}');
      debugPrint('servings: ${_item.servings}');
      debugPrint('ingredients count: ${_item.ingredients.length}');
      debugPrint('instructions count: ${_item.instructions.length}');
      debugPrint('rating: ${_item.rating}');
      debugPrint('===========================');
    }
  }

  @override
  void dispose() {
    _reviewController.dispose();
    super.dispose();
  }

  void _submitReview() {
    final text = _reviewController.text.trim();
    if (text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please write your review thoughts before submitting.')),
      );
      return;
    }

    setState(() {
      _userReviews.insert(0, {
        'userName': 'You',
        'rating': _selectedRating,
        'comment': text,
        'date': 'Just now',
      });
      _currentReviewCount++;
      _currentRating = ((_currentRating * (_currentReviewCount - 1)) + _selectedRating) / _currentReviewCount;
      _reviewController.clear();
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Thank you! Your review has been published.')),
    );
  }

  void _startCookingWalkthrough(Recipe item) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        int currentStep = 0;
        return StatefulBuilder(
          builder: (context, setModalState) {
            final steps = item.instructions.isNotEmpty
                ? item.instructions
                : ['Prepare all fresh ingredients.', 'Follow cooking steps.', 'Enjoy your meal!'];

            return Container(
              height: MediaQuery.of(context).size.height * 0.65,
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
              ),
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 5,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Cooking: ${item.title}',
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                      ),
                      Text(
                        'Step ${currentStep + 1} of ${steps.length}',
                        style: const TextStyle(fontSize: 13, color: AppColors.primary, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Expanded(
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: AppColors.background,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CircleAvatar(
                            radius: 28,
                            backgroundColor: AppColors.primary,
                            child: Text(
                              '${currentStep + 1}',
                              style: const TextStyle(fontSize: 22, color: Colors.white, fontWeight: FontWeight.bold),
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            steps[currentStep],
                            textAlign: TextAlign.center,
                            style: const TextStyle(fontSize: 16, color: AppColors.textPrimary, height: 1.5),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      if (currentStep > 0)
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () {
                              setModalState(() => currentStep--);
                            },
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                            ),
                            child: const Text('Previous Step'),
                          ),
                        ),
                      if (currentStep > 0) const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            if (currentStep < steps.length - 1) {
                              setModalState(() => currentStep++);
                            } else {
                              Navigator.pop(context);
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('🎉 Bon Appétit! You completed cooking this recipe!')),
                              );
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                          ),
                          child: Text(currentStep < steps.length - 1 ? 'Next Step' : 'Finish Cooking'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final favoriteProvider = Provider.of<FavoriteProvider>(context);
    final bool isFav = favoriteProvider.isFavorite(_item.id);

    // Calculate scaled ingredients using model helper
    final List<String> scaledIngredients = _item.getScaledIngredients(_servings);

    final currentUid = authProvider.currentUserId;
    final isOwner = currentUid != null &&
        currentUid.isNotEmpty &&
        (currentUid == _item.createdBy || _item.createdBy == 'You' || _item.createdBy.isEmpty);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          // Top Food Hero Image with Loading/Error Handling
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: 280,
            child: _item.imageUrl.trim().isEmpty
                ? Container(
                    color: AppColors.primaryLight,
                    child: const Icon(Icons.restaurant, size: 80, color: Colors.white),
                  )
                : Image.network(
                    _item.imageUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      color: AppColors.primaryLight,
                      child: const Icon(Icons.restaurant, size: 80, color: Colors.white),
                    ),
                  ),
          ),

          // Top Header Back Button & Owner Action Buttons
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                  if (isOwner)
                    Row(
                      children: [
                        Container(
                          margin: const EdgeInsets.only(right: 8),
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                          ),
                          child: IconButton(
                            icon: const Icon(Icons.edit_outlined, size: 18, color: AppColors.primary),
                            onPressed: () async {
                              final updated = await Navigator.pushNamed(
                                context,
                                AppRoutes.addEditRecipe,
                                arguments: _item,
                              );
                              if (updated is Recipe) {
                                setState(() {
                                  _item = updated;
                                });
                              }
                            },
                          ),
                        ),
                        Container(
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                          ),
                          child: IconButton(
                            icon: const Icon(Icons.delete_outline, size: 18, color: AppColors.error),
                            onPressed: () {
                              showDialog(
                                context: context,
                                builder: (ctx) => AlertDialog(
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                                  title: const Text('Delete Recipe?'),
                                  content: Text('Are you sure you want to delete "${_item.title}"?'),
                                  actions: [
                                    TextButton(
                                      onPressed: () => Navigator.pop(ctx),
                                      child: const Text('Cancel'),
                                    ),
                                    ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: AppColors.error,
                                        foregroundColor: Colors.white,
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                      ),
                                      onPressed: () async {
                                        final nav = Navigator.of(context);
                                        final messenger = ScaffoldMessenger.of(context);
                                        final recipeProvider = Provider.of<RecipeProvider>(context, listen: false);
                                        final title = _item.title;

                                        Navigator.pop(ctx);
                                        await recipeProvider.deleteRecipe(_item.id);
                                        messenger.showSnackBar(
                                          SnackBar(content: Text('Deleted "$title"')),
                                        );
                                        nav.pop();
                                      },
                                      child: const Text('Delete'),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                ],
              ),
            ),
          ),

          // Bottom Sheet Content Container
          Positioned.fill(
            top: 250,
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
                          // Title & Category Badge Pill Row
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Expanded(
                                child: Text(
                                  _item.title,
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
                                  _item.category,
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

                          // Description Text
                          Text(
                            _item.description,
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
                                '${_item.calories} Cal',
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
                                '${_item.cookingTime} Min',
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
                                _currentRating > 0 ? '${_currentRating.toStringAsFixed(1)}/5' : 'No ratings yet',
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                _currentReviewCount > 0 ? '($_currentReviewCount Reviews)' : '(No reviews yet)',
                                style: const TextStyle(
                                  fontSize: 13,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 24),

                          // Ingredients Header & Interactive Serving Counter (Prevent Servings < 1)
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

                          // Dynamically Scaled Ingredient List Items using getScaledIngredients()
                          if (scaledIngredients.isEmpty)
                            const Text('No ingredients listed.', style: TextStyle(color: AppColors.textSecondary))
                          else
                            ...scaledIngredients.map((ing) {
                              String name = ing.trim();
                              String qty = '';
                              if (ing.contains(':')) {
                                final parts = ing.split(':');
                                name = parts[0].trim();
                                qty = parts.sublist(1).join(':').trim();
                              } else {
                                final RegExp matchRegex = RegExp(r'^(.*?)\s+([\d\.]+\s*[A-Za-z%]+)$');
                                final match = matchRegex.firstMatch(ing.trim());
                                if (match != null) {
                                  final g1 = match.group(1);
                                  final g2 = match.group(2);
                                  if (g1 != null && g1.trim().isNotEmpty) {
                                    name = g1.trim();
                                    qty = g2?.trim() ?? '';
                                  }
                                }
                              }

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
                                        name,
                                        style: const TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w500,
                                          color: AppColors.textPrimary,
                                        ),
                                      ),
                                    ),
                                    Text(
                                      qty,
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

                          // Instructions Section Header
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
                          ..._item.instructions.asMap().entries.map(
                                (entry) => Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                                  child: Row(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Container(
                                        width: 24,
                                        height: 24,
                                        decoration: const BoxDecoration(
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

                          // Reviews & Ratings Section Header
                          const Text(
                            'Reviews & Ratings',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 12),

                          // User Submitted Reviews List or Empty State Box
                          if (_userReviews.isEmpty)
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
                            )
                          else
                            ..._userReviews.map((rev) => Container(
                                  margin: const EdgeInsets.only(bottom: 10),
                                  padding: const EdgeInsets.all(14),
                                  decoration: BoxDecoration(
                                    color: AppColors.background,
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(rev['userName'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                                          Row(
                                            children: List.generate(
                                              rev['rating'],
                                              (_) => const Icon(Icons.star_rounded, size: 14, color: AppColors.starRating),
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 4),
                                      Text(rev['comment'], style: const TextStyle(fontSize: 13, color: AppColors.textPrimary)),
                                    ],
                                  ),
                                )),
                          const SizedBox(height: 20),

                          // Leave a Review Card
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
                                    onPressed: _submitReview,
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

                  // Fixed Bottom Action Bar: Start Cooking & Red Heart Button
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
                            onPressed: () => _startCookingWalkthrough(_item),
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
                              favoriteProvider.toggleFavorite(uid, _item.id);
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
