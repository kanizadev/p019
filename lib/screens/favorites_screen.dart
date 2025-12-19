import 'dart:io';
import 'dart:ui';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/recipe.dart';
import '../services/recipe_api_service.dart';
import 'recipe_detail_screen.dart';

class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({super.key});

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen>
    with SingleTickerProviderStateMixin {
  final RecipeApiService _apiService = RecipeApiService();
  List<Recipe> _recipes = [];
  final List<Recipe> _customRecipes = [];
  bool _isLoading = true;
  bool _isRefreshing = false;
  String? _errorMessage;
  late AnimationController _refreshAnimationController;

  @override
  void initState() {
    super.initState();
    _refreshAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat();
    _loadRecipes();
  }

  @override
  void dispose() {
    _refreshAnimationController.dispose();
    super.dispose();
  }

  Future<void> _loadRecipes() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final apiRecipes = await _apiService.getRandomRecipes(count: 10);
      setState(() {
        _recipes = [..._customRecipes, ...apiRecipes];
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage =
            'Failed to load recipes. Please check your internet connection.';
        _recipes = List.from(_customRecipes);
        _isLoading = false;
      });
    }
  }

  Future<void> _refreshRecipes() async {
    setState(() {
      _isRefreshing = true;
    });
    _refreshAnimationController.reset();
    _refreshAnimationController.forward();

    try {
      final apiRecipes = await _apiService.getRandomRecipes(count: 10);
      await Future.delayed(
        const Duration(milliseconds: 500),
      ); // Smooth transition
      if (mounted) {
        setState(() {
          _recipes = [..._customRecipes, ...apiRecipes];
          _isRefreshing = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Failed to refresh recipes.';
          _isRefreshing = false;
        });
      }
    }
  }

  List<Recipe> get _filteredRecipes {
    return _recipes.where((recipe) => recipe.isFavorite).toList()
      ..sort((a, b) => a.title.compareTo(b.title));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      extendBodyBehindAppBar: true,
      body: CustomScrollView(
        slivers: [
          // Advanced App Bar with Glassmorphism
          SliverAppBar(
            floating: false,
            pinned: true,
            elevation: 0,
            backgroundColor: Colors.transparent,
            title: Text(
              'Favorite Recipes',
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.bold,
                color: Colors.white,
                fontSize: 22,
                letterSpacing: -0.5,
                shadows: [
                  Shadow(
                    offset: const Offset(0, 2),
                    blurRadius: 8,
                    color: Colors.black.withValues(alpha: 0.3),
                  ),
                ],
              ),
            ),
            flexibleSpace: ClipRRect(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    border: Border(
                      bottom: BorderSide(
                        color: Colors.white.withValues(alpha: 0.3),
                        width: 1,
                      ),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.1),
                        blurRadius: 20,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            actions: [
              if (!_isLoading)
                Container(
                  margin: const EdgeInsets.only(right: 12),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.white.withValues(alpha: 0.2),
                        Colors.white.withValues(alpha: 0.1),
                      ],
                    ),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.3),
                      width: 1.5,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.1),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: AnimatedBuilder(
                    animation: _refreshAnimationController,
                    builder: (context, child) {
                      return Transform.rotate(
                        angle: _isRefreshing
                            ? _refreshAnimationController.value * 2 * 3.14159
                            : 0,
                        child: IconButton(
                          icon: Icon(
                            Icons.refresh_outlined,
                            color: Colors.white,
                            size: 22,
                          ),
                          onPressed: _isRefreshing ? null : _refreshRecipes,
                          tooltip: 'Refresh',
                        ),
                      );
                    },
                  ),
                ),
            ],
          ),
          // Recipe List with Skeleton Loaders
          _isLoading
              ? SliverPadding(
                  padding: const EdgeInsets.all(16),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) => _SkeletonRecipeCard(),
                      childCount: 5,
                    ),
                  ),
                )
              : _errorMessage != null && _recipes.isEmpty
              ? SliverFillRemaining(
                  hasScrollBody: false,
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.error_outline,
                            size: 80,
                            color: const Color(0xFF87A96B),
                          ),
                          const SizedBox(height: 24),
                          Text(
                            _errorMessage!,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: Colors.grey[700],
                            ),
                          ),
                          const SizedBox(height: 24),
                          ElevatedButton.icon(
                            onPressed: _loadRecipes,
                            icon: const Icon(Icons.refresh_outlined),
                            label: const Text('Retry'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(
                                0xFF87A96B,
                              ), // Sage green
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 24,
                                vertical: 12,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                )
              : _filteredRecipes.isEmpty
              ? SliverFillRemaining(
                  hasScrollBody: false,
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.favorite_border,
                          size: 80,
                          color: Colors.grey[300],
                        ),
                        const SizedBox(height: 24),
                        Text(
                          'No favorite recipes yet',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Tap the heart icon to favorite recipes!',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              : SliverPadding(
                  padding: const EdgeInsets.all(16),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate((context, index) {
                      final recipe = _filteredRecipes[index];
                      return TweenAnimationBuilder<double>(
                        tween: Tween(begin: 0.0, end: 1.0),
                        duration: Duration(milliseconds: 300 + (index * 50)),
                        builder: (context, value, child) {
                          return Opacity(
                            opacity: value,
                            child: Transform.translate(
                              offset: Offset(0, 20 * (1 - value)),
                              child: child,
                            ),
                          );
                        },
                        child: _RecipeCard(
                          recipe: recipe,
                          index: index,
                          onTap: () async {
                            final updatedRecipe = await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    RecipeDetailScreen(recipe: recipe),
                              ),
                            );
                            if (updatedRecipe != null &&
                                updatedRecipe is Recipe) {
                              final recipeIndex = _recipes.indexWhere(
                                (r) => r.id == recipe.id,
                              );
                              if (recipeIndex != -1) {
                                setState(() {
                                  _recipes[recipeIndex] = updatedRecipe;
                                });
                              }
                            }
                          },
                          onDelete: () {
                            // Only allow deletion of custom recipes
                            final isCustomRecipe = _customRecipes.any(
                              (r) => r.id == recipe.id,
                            );
                            if (isCustomRecipe) {
                              setState(() {
                                _customRecipes.removeWhere(
                                  (r) => r.id == recipe.id,
                                );
                                _recipes.removeWhere((r) => r.id == recipe.id);
                              });
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: ClipRRect(
                                    borderRadius: BorderRadius.circular(10),
                                    child: BackdropFilter(
                                      filter: ImageFilter.blur(
                                        sigmaX: 10,
                                        sigmaY: 10,
                                      ),
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 16,
                                          vertical: 12,
                                        ),
                                        decoration: BoxDecoration(
                                          color: const Color(
                                            0xFF87A96B,
                                          ).withValues(alpha: 0.9),
                                          borderRadius: BorderRadius.circular(
                                            10,
                                          ),
                                          border: Border.all(
                                            color: Colors.white.withValues(
                                              alpha: 0.3,
                                            ),
                                            width: 1.5,
                                          ),
                                        ),
                                        child: Row(
                                          children: [
                                            const Icon(
                                              Icons.check_circle_outline,
                                              color: Colors.white,
                                            ),
                                            const SizedBox(width: 8),
                                            Text('${recipe.title} deleted'),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                  backgroundColor: Colors.transparent,
                                  behavior: SnackBarBehavior.floating,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  margin: const EdgeInsets.all(16),
                                  elevation: 0,
                                ),
                              );
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: ClipRRect(
                                    borderRadius: BorderRadius.circular(10),
                                    child: BackdropFilter(
                                      filter: ImageFilter.blur(
                                        sigmaX: 10,
                                        sigmaY: 10,
                                      ),
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 16,
                                          vertical: 12,
                                        ),
                                        decoration: BoxDecoration(
                                          gradient: LinearGradient(
                                            colors: [
                                              const Color(0xFF87A96B).withValues(alpha: 0.8),
                                              const Color(0xFF6B8E5A).withValues(alpha: 0.75),
                                            ],
                                          ),
                                          borderRadius: BorderRadius.circular(
                                            10,
                                          ),
                                          border: Border.all(
                                            color: Colors.white.withValues(
                                              alpha: 0.4,
                                            ),
                                            width: 1.5,
                                          ),
                                        ),
                                        child: const Row(
                                          children: [
                                            Icon(
                                              Icons.info_outline,
                                              color: Colors.white,
                                            ),
                                            SizedBox(width: 8),
                                            Text('Cannot delete API recipes'),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                  backgroundColor: Colors.transparent,
                                  behavior: SnackBarBehavior.floating,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  margin: const EdgeInsets.all(16),
                                  elevation: 0,
                                ),
                              );
                            }
                          },
                          onFavoriteToggle: () {
                            final updatedRecipe = recipe.copyWith(
                              isFavorite: !recipe.isFavorite,
                            );
                            final index = _recipes.indexWhere(
                              (r) => r.id == recipe.id,
                            );
                            if (index != -1) {
                              setState(() {
                                _recipes[index] = updatedRecipe;
                              });
                            }
                          },
                        ),
                      );
                    }, childCount: _filteredRecipes.length),
                  ),
                ),
        ],
      ),
    );
  }
}

// Skeleton Loader for Recipe Cards
class _SkeletonRecipeCard extends StatefulWidget {
  @override
  State<_SkeletonRecipeCard> createState() => _SkeletonRecipeCardState();
}

class _SkeletonRecipeCardState extends State<_SkeletonRecipeCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _shimmerController;

  @override
  void initState() {
    super.initState();
    _shimmerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat();
  }

  @override
  void dispose() {
    _shimmerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          margin: const EdgeInsets.only(bottom: 24),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                const Color(0xFF9CAF88).withValues(alpha: 0.4),
                const Color(0xFF87A96B).withValues(alpha: 0.35),
              ],
            ),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.3),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF87A96B).withValues(alpha: 0.2),
                blurRadius: 20,
                offset: const Offset(0, 8),
                spreadRadius: 0,
              ),
            ],
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Skeleton Image
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      const Color(0xFF9CAF88).withValues(alpha: 0.3),
                      const Color(0xFF87A96B).withValues(alpha: 0.25),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.2),
                    width: 1,
                  ),
                ),
                child: AnimatedBuilder(
                  animation: _shimmerController,
                  builder: (context, child) {
                    return Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        gradient: LinearGradient(
                          begin: Alignment(
                            -1.0 - _shimmerController.value * 2,
                            0,
                          ),
                          end: Alignment(1.0 - _shimmerController.value * 2, 0),
                          colors: [
                            const Color(0xFF9CAF88).withValues(alpha: 0.3),
                            const Color(0xFF87A96B).withValues(alpha: 0.2),
                            const Color(0xFF9CAF88).withValues(alpha: 0.3),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(width: 20),
              // Skeleton Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AnimatedBuilder(
                      animation: _shimmerController,
                      builder: (context, child) {
                        return Container(
                          height: 20,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            gradient: LinearGradient(
                              begin: Alignment(
                                -1.0 - _shimmerController.value * 2,
                                0,
                              ),
                              end: Alignment(
                                1.0 - _shimmerController.value * 2,
                                0,
                              ),
                              colors: [
                                Colors.grey[300]!,
                                Colors.grey[200]!,
                                Colors.grey[300]!,
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 12),
                    AnimatedBuilder(
                      animation: _shimmerController,
                      builder: (context, child) {
                        return Container(
                          height: 16,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            gradient: LinearGradient(
                              begin: Alignment(
                                -1.0 - _shimmerController.value * 2,
                                0,
                              ),
                              end: Alignment(
                                1.0 - _shimmerController.value * 2,
                                0,
                              ),
                              colors: [
                                Colors.grey[300]!,
                                Colors.grey[200]!,
                                Colors.grey[300]!,
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 8),
                    AnimatedBuilder(
                      animation: _shimmerController,
                      builder: (context, child) {
                        return Container(
                          height: 16,
                          width: 150,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            gradient: LinearGradient(
                              begin: Alignment(
                                -1.0 - _shimmerController.value * 2,
                                0,
                              ),
                              end: Alignment(
                                1.0 - _shimmerController.value * 2,
                                0,
                              ),
                              colors: [
                                Colors.grey[300]!,
                                Colors.grey[200]!,
                                Colors.grey[300]!,
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 14),
                    Row(
                      children: [
                        AnimatedBuilder(
                          animation: _shimmerController,
                          builder: (context, child) {
                            return Container(
                              height: 28,
                              width: 80,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(8),
                                gradient: LinearGradient(
                                  begin: Alignment(
                                    -1.0 - _shimmerController.value * 2,
                                    0,
                                  ),
                                  end: Alignment(
                                    1.0 - _shimmerController.value * 2,
                                    0,
                                  ),
                                  colors: [
                                    Colors.grey[300]!,
                                    Colors.grey[200]!,
                                    Colors.grey[300]!,
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                        const SizedBox(width: 10),
                        AnimatedBuilder(
                          animation: _shimmerController,
                          builder: (context, child) {
                            return Container(
                              height: 28,
                              width: 60,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(8),
                                gradient: LinearGradient(
                                  begin: Alignment(
                                    -1.0 - _shimmerController.value * 2,
                                    0,
                                  ),
                                  end: Alignment(
                                    1.0 - _shimmerController.value * 2,
                                    0,
                                  ),
                                  colors: [
                                    Colors.grey[300]!,
                                    Colors.grey[200]!,
                                    Colors.grey[300]!,
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RecipeCard extends StatelessWidget {
  final Recipe recipe;
  final VoidCallback onTap;
  final VoidCallback onDelete;
  final VoidCallback onFavoriteToggle;
  final int index;

  const _RecipeCard({
    required this.recipe,
    required this.onTap,
    required this.onDelete,
    required this.onFavoriteToggle,
    required this.index,
  });

  @override
  Widget build(BuildContext context) {
    return Hero(
      tag: 'recipe_${recipe.id}',
      child: Material(
        color: Colors.transparent,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(
              margin: const EdgeInsets.only(bottom: 24),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    const Color(0xFF9CAF88).withValues(alpha: 0.4),
                    const Color(0xFF87A96B).withValues(alpha: 0.35),
                  ],
                ),
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.3),
                  width: 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF87A96B).withValues(alpha: 0.2),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                    spreadRadius: 0,
                  ),
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                    spreadRadius: -2,
                  ),
                ],
              ),
              child: Material(
                color: Colors.transparent,
                child: _AnimatedCard(
                  onTap: onTap,
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Enhanced Recipe Image with Glassmorphism
                        Container(
                          width: 120,
                          height: 120,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: Color(
                                  0xFF87A96B,
                                ).withValues(alpha: 0.25),
                                blurRadius: 15,
                                offset: const Offset(0, 6),
                                spreadRadius: -2,
                              ),
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.1),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(20),
                            child: Container(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [
                                    const Color(0xFFA8C48A),
                                    const Color(0xFF6B8E5A),
                                  ],
                                ),
                              ),
                              child: Stack(
                                children: [
                                  if (recipe.imageUrl != null &&
                                      recipe.imageUrl!.isNotEmpty)
                                    _buildRecipeImage(recipe.imageUrl!)
                                  else
                                    const Icon(
                                      Icons.restaurant_outlined,
                                      size: 50,
                                      color: Colors.white,
                                    ),
                                  // Subtle overlay for depth
                                  Positioned.fill(
                                    child: Container(
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(20),
                                        gradient: LinearGradient(
                                          begin: Alignment.topCenter,
                                          end: Alignment.bottomCenter,
                                          colors: [
                                            Colors.white.withValues(alpha: 0.1),
                                            Colors.transparent,
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                  // Favorite icon
                                  Positioned(
                                    top: 8,
                                    right: 8,
                                    child: IconButton(
                                      icon: Icon(
                                        recipe.isFavorite
                                            ? Icons.favorite
                                            : Icons.favorite_border,
                                        color: recipe.isFavorite
                                            ? Colors.red
                                            : Colors.white,
                                        size: 24,
                                      ),
                                      onPressed: onFavoriteToggle,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 18),
                        // Recipe Info
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                recipe.title,
                                style: GoogleFonts.poppins(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: -0.5,
                                  color: const Color(0xFF2C3E2D),
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 6),
                              Text(
                                recipe.description,
                                style: GoogleFonts.poppins(
                                  fontSize: 14,
                                  color: const Color(0xFF2C3E2D).withValues(alpha: 0.7),
                                  height: 1.4,
                                  fontWeight: FontWeight.w400,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 12),
                              Wrap(
                                spacing: 8,
                                runSpacing: 8,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 10,
                                      vertical: 6,
                                    ),
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        colors: [
                                          const Color(0xFF87A96B).withValues(alpha: 0.5),
                                          const Color(0xFF6B8E5A).withValues(alpha: 0.4),
                                        ],
                                      ),
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(
                                        color: Colors.white.withValues(alpha: 0.4),
                                        width: 1.5,
                                      ),
                                      boxShadow: [
                                        BoxShadow(
                                          color: const Color(0xFF87A96B).withValues(alpha: 0.2),
                                          blurRadius: 8,
                                          offset: const Offset(0, 2),
                                        ),
                                      ],
                                    ),
                                    child: Text(
                                      recipe.category,
                                      style: const TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.white,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        Icons.access_time,
                                        size: 14,
                                        color: const Color(0xFF6B8E5A).withValues(alpha: 0.8),
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        '${recipe.totalTime}m',
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w500,
                                          color: const Color(0xFF2C3E2D).withValues(alpha: 0.7),
                                        ),
                                      ),
                                    ],
                                  ),
                                  Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        Icons.people,
                                        size: 14,
                                        color: const Color(0xFF6B8E5A).withValues(alpha: 0.8),
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        '${recipe.servings}',
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w500,
                                          color: const Color(0xFF2C3E2D).withValues(alpha: 0.7),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: List.generate(5, (index) {
                                  return Icon(
                                    index < recipe.rating.round()
                                        ? Icons.star
                                        : Icons.star_border,
                                    color: Colors.amber,
                                    size: 16,
                                  );
                                }),
                              ),
                            ],
                          ),
                        ),
                        // Delete Button
                        IconButton(
                          icon: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.red[50],
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.delete_outline,
                              color: Colors.red[400],
                              size: 20,
                            ),
                          ),
                          onPressed: () {
                            showDialog(
                              context: context,
                              builder: (context) => ClipRRect(
                                borderRadius: BorderRadius.circular(20),
                                child: BackdropFilter(
                                  filter: ImageFilter.blur(
                                    sigmaX: 10,
                                    sigmaY: 10,
                                  ),
                                  child: AlertDialog(
                                    backgroundColor: const Color(0xFF9CAF88).withValues(
                                      alpha: 0.4,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(20),
                                      side: BorderSide(
                                        color: Colors.white.withValues(
                                          alpha: 0.4,
                                        ),
                                        width: 1.5,
                                      ),
                                    ),
                                    title: const Text(
                                      'Delete Recipe',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                    content: Text(
                                      'Are you sure you want to delete "${recipe.title}"?',
                                      style: TextStyle(
                                        color: Colors.white.withValues(
                                          alpha: 0.9,
                                        ),
                                      ),
                                    ),
                                    actions: [
                                      TextButton(
                                        onPressed: () => Navigator.pop(context),
                                        child: Text(
                                          'Cancel',
                                          style: TextStyle(
                                            color: Colors.white.withValues(
                                              alpha: 0.9,
                                            ),
                                          ),
                                        ),
                                      ),
                                      ElevatedButton(
                                        onPressed: () {
                                          Navigator.pop(context);
                                          onDelete();
                                        },
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: const Color(0xFF87A96B).withValues(alpha: 0.8),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              10,
                                            ),
                                          ),
                                        ),
                                        child: const Text(
                                          'Delete',
                                          style: TextStyle(color: Colors.white),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRecipeImage(String imageUrl) {
    // Check if it's a local file path or network URL
    if (imageUrl.startsWith('http://') || imageUrl.startsWith('https://')) {
      // Network image
      return Image.network(
        imageUrl,
        width: 120,
        height: 120,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [const Color(0xFFA8C48A), const Color(0xFF6B8E5A)],
              ),
            ),
            child: const Icon(
              Icons.restaurant_outlined,
              size: 50,
              color: Colors.white,
            ),
          );
        },
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [const Color(0xFFA8C48A), const Color(0xFF6B8E5A)],
              ),
            ),
            child: Center(
              child: CircularProgressIndicator(
                value: loadingProgress.expectedTotalBytes != null
                    ? loadingProgress.cumulativeBytesLoaded /
                          loadingProgress.expectedTotalBytes!
                    : null,
                valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                strokeWidth: 2.5,
              ),
            ),
          );
        },
      );
    } else {
      // Local file image - not supported on web
      if (kIsWeb) {
        // Show placeholder on web
        return Container(
          width: 120,
          height: 120,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [const Color(0xFFA8C48A), const Color(0xFF6B8E5A)],
            ),
          ),
          child: const Icon(Icons.restaurant, size: 50, color: Colors.white),
        );
      }
      return Image.file(
        File(imageUrl),
        width: 120,
        height: 120,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [const Color(0xFFA8C48A), const Color(0xFF6B8E5A)],
              ),
            ),
            child: const Icon(
              Icons.restaurant_outlined,
              size: 50,
              color: Colors.white,
            ),
          );
        },
      );
    }
  }
}

// Animated Card with Scale Effect
class _AnimatedCard extends StatefulWidget {
  final VoidCallback onTap;
  final Widget child;

  const _AnimatedCard({required this.onTap, required this.child});

  @override
  State<_AnimatedCard> createState() => _AnimatedCardState();
}

class _AnimatedCardState extends State<_AnimatedCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.97,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _controller.forward(),
      onTapUp: (_) {
        _controller.reverse();
        widget.onTap();
      },
      onTapCancel: () => _controller.reverse(),
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: InkWell(
          onTap: widget.onTap,
          borderRadius: BorderRadius.circular(24),
          splashColor: Color(0xFF87A96B).withValues(alpha: 0.1),
          highlightColor: Color(0xFF87A96B).withValues(alpha: 0.05),
          child: widget.child,
        ),
      ),
    );
  }
}
