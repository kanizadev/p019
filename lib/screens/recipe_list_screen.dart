import 'dart:io';
import 'dart:ui';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/recipe.dart';
import '../services/recipe_api_service.dart';
import '../widgets/glass_widget.dart';
import 'recipe_detail_screen.dart';

class RecipeListScreen extends StatefulWidget {
  const RecipeListScreen({super.key});

  @override
  State<RecipeListScreen> createState() => _RecipeListScreenState();
}

class _RecipeListScreenState extends State<RecipeListScreen>
    with SingleTickerProviderStateMixin {
  final RecipeApiService _apiService = RecipeApiService();
  List<Recipe> _recipes = [];
  final List<Recipe> _customRecipes = [];
  bool _isLoading = true;
  String? _errorMessage;
  String _searchQuery = '';
  String _selectedCategory = 'All';
  bool _isSearchExpanded = false;
  final String _sortBy = 'name';
  late TextEditingController _searchController;
  late AnimationController _refreshAnimationController;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    _refreshAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat();
    _loadRecipes();
  }

  @override
  void dispose() {
    _searchController.dispose();
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

  Future<void> _searchRecipes(String query) async {
    if (query.trim().isEmpty) {
      await _loadRecipes();
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final searchResults = await _apiService.searchRecipes(query);
      setState(() {
        _recipes = [..._customRecipes, ...searchResults];
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to search recipes.';
        _isLoading = false;
      });
    }
  }

  List<Recipe> get _filteredRecipes {
    var filtered = _recipes.where((recipe) {
      final matchesSearch =
          recipe.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          recipe.description.toLowerCase().contains(_searchQuery.toLowerCase());
      final matchesCategory =
          _selectedCategory == 'All' ||
          (_selectedCategory == 'Favorites'
              ? recipe.isFavorite
              : recipe.category == _selectedCategory);
      return matchesSearch && matchesCategory;
    }).toList();
    // Sort
    filtered.sort((a, b) {
      switch (_sortBy) {
        case 'name':
          return a.title.compareTo(b.title);
        default:
          return 0;
      }
    });
    return filtered;
  }

  List<String> get _categories {
    final categories = _recipes.map((r) => r.category).toSet().toList();
    categories.sort();
    final result = ['All', ...categories];
    if (_recipes.any((r) => r.isFavorite)) {
      result.add('Favorites');
    }
    return result;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
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
        title: Text(
          'Recipes',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.bold,
            fontSize: 22,
            letterSpacing: -0.5,
            color: Colors.white,
            shadows: [
              Shadow(
                offset: const Offset(0, 2),
                blurRadius: 8,
                color: Colors.black.withValues(alpha: 0.3),
              ),
            ],
          ),
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 8),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [
                  Colors.white.withValues(alpha: 0.3),
                  Colors.white.withValues(alpha: 0.2),
                ],
              ),
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
            child: IconButton(
              icon: Icon(
                _isSearchExpanded
                    ? Icons.close_outlined
                    : Icons.search_outlined,
                color: Colors.white,
              ),
              onPressed: () {
                setState(() {
                  _isSearchExpanded = !_isSearchExpanded;
                  if (!_isSearchExpanded) {
                    _searchQuery = '';
                    _searchController.clear();
                    _loadRecipes();
                  }
                });
              },
            ),
          ),
        ],
      ),
      body: CustomScrollView(
        slivers: [
          // Search Bar
          SliverToBoxAdapter(
            child: _isSearchExpanded
                ? Padding(
                    padding: const EdgeInsets.fromLTRB(16, 100, 16, 16),
                    child: GlassWidget(
                      padding: EdgeInsets.zero,
                      opacity: 0.4,
                      color: const Color(0xFF9CAF88),
                      child: TextField(
                        controller: _searchController,
                        autofocus: true,
                        style: const TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          hintText: 'Search recipes...',
                          hintStyle: TextStyle(
                            color: Colors.white.withValues(alpha: 0.7),
                          ),
                          prefixIcon: Icon(
                            Icons.search_outlined,
                            color: Colors.white.withValues(alpha: 0.9),
                          ),
                          suffixIcon: _searchQuery.isNotEmpty
                              ? IconButton(
                                  icon: Icon(
                                    Icons.close_outlined,
                                    color: Colors.white.withValues(alpha: 0.9),
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      _searchQuery = '';
                                      _searchController.clear();
                                    });
                                    _loadRecipes();
                                  },
                                )
                              : null,
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.all(16),
                        ),
                        onChanged: (value) {
                          setState(() {
                            _searchQuery = value;
                          });
                        },
                        onSubmitted: (value) {
                          if (value.trim().isNotEmpty) {
                            _searchRecipes(value.trim());
                          }
                        },
                      ),
                    ),
                  )
                : const SizedBox(height: 100),
          ),
          // Category Filter Chips
          SliverToBoxAdapter(
            child: Container(
              height: 60,
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: _categories.length,
                itemBuilder: (context, index) {
                  final category = _categories[index];
                  final isSelected = _selectedCategory == category;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: isSelected
                                ? LinearGradient(
                                    colors: [
                                      const Color(0xFF87A96B).withValues(alpha: 0.8),
                                      const Color(0xFF6B8E5A).withValues(alpha: 0.75),
                                    ],
                                  )
                                : null,
                            color: isSelected
                                ? null
                                : const Color(0xFF9CAF88).withValues(alpha: 0.3),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.4),
                              width: 1.5,
                            ),
                            boxShadow: isSelected
                                ? [
                                    BoxShadow(
                                      color: const Color(0xFF87A96B).withValues(alpha: 0.3),
                                      blurRadius: 12,
                                      offset: const Offset(0, 4),
                                    ),
                                  ]
                                : null,
                          ),
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              onTap: () {
                                setState(() {
                                  _selectedCategory = category;
                                });
                              },
                              borderRadius: BorderRadius.circular(20),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 8,
                                ),
                                child: Center(
                                  child: Text(
                                    category,
                                    style: TextStyle(
                                      color: isSelected
                                          ? Colors.white
                                          : Colors.white.withValues(alpha: 0.9),
                                      fontSize: 14,
                                      fontWeight: isSelected
                                          ? FontWeight.w600
                                          : FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
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
                          Icons.restaurant_menu_outlined,
                          size: 80,
                          color: const Color(0xFF87A96B),
                        ),
                        const SizedBox(height: 24),
                        Text(
                          _searchQuery.isNotEmpty || _selectedCategory != 'All'
                              ? 'No recipes found'
                              : 'No recipes yet',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey[600],
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Tap + to add your first recipe!',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey[500],
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
                      return _RecipeCard(
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
                                        borderRadius: BorderRadius.circular(10),
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
                                        borderRadius: BorderRadius.circular(10),
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
    return GlassWidget(
      margin: const EdgeInsets.only(bottom: 24),
      padding: const EdgeInsets.all(20),
      opacity: 0.4,
      color: const Color(0xFF9CAF88),
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
                      begin: Alignment(-1.0 - _shimmerController.value * 2, 0),
                      end: Alignment(1.0 - _shimmerController.value * 2, 0),
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
                                const Color(0xFF9CAF88).withValues(alpha: 0.3),
                                const Color(0xFF87A96B).withValues(alpha: 0.2),
                                const Color(0xFF9CAF88).withValues(alpha: 0.3),
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
                                const Color(0xFF9CAF88).withValues(alpha: 0.3),
                                const Color(0xFF87A96B).withValues(alpha: 0.2),
                                const Color(0xFF9CAF88).withValues(alpha: 0.3),
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
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
        child: Container(
          margin: const EdgeInsets.only(bottom: 16),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                const Color(0xFF9CAF88).withValues(alpha: 0.4),
                const Color(0xFF87A96B).withValues(alpha: 0.35),
              ],
            ),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.3),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF87A96B).withValues(alpha: 0.2),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: onTap,
              borderRadius: BorderRadius.circular(20),
              child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Recipe Image
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.3),
                  width: 1.5,
                ),
              ),
              child: recipe.imageUrl != null && recipe.imageUrl!.isNotEmpty
                  ? _buildRecipeImage(recipe.imageUrl!)
                  : const Icon(
                      Icons.restaurant_outlined,
                      size: 40,
                      color: Color(0xFF87A96B),
                    ),
            ),
          ),
          const SizedBox(width: 16),
          // Recipe Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  recipe.title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF2C3E2D),
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  recipe.description,
                  style: TextStyle(
                    fontSize: 14,
                    color: const Color(0xFF2C3E2D).withValues(alpha: 0.7),
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                const Color(0xFF87A96B).withValues(alpha: 0.5),
                                const Color(0xFF6B8E5A).withValues(alpha: 0.4),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(16),
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
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '${recipe.servings} servings',
                      style: TextStyle(
                        fontSize: 12,
                        color: const Color(0xFF2C3E2D).withValues(alpha: 0.6),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // Action Buttons
          Column(
            children: [
              IconButton(
                icon: Icon(
                  recipe.isFavorite ? Icons.favorite : Icons.favorite_border,
                  color: const Color(0xFF87A96B),
                ),
                onPressed: onFavoriteToggle,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
              IconButton(
                icon: const Icon(
                  Icons.delete_outline,
                  color: Color(0xFF87A96B),
                ),
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (context) => ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                        child: AlertDialog(
                          backgroundColor: const Color(0xFF9CAF88).withValues(alpha: 0.4),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                            side: BorderSide(
                              color: Colors.white.withValues(alpha: 0.4),
                              width: 1.5,
                            ),
                          ),
                          title: const Text(
                            'Delete Recipe',
                            style: TextStyle(color: Colors.white),
                          ),
                          content: Text(
                            'Are you sure you want to delete "${recipe.title}"?',
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.9),
                            ),
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: Text(
                                'Cancel',
                                style: TextStyle(
                                  color: Colors.white.withValues(alpha: 0.9),
                                ),
                              ),
                            ),
                            TextButton(
                              onPressed: () {
                                Navigator.pop(context);
                                onDelete();
                              },
                              child: const Text(
                                'Delete',
                                style: TextStyle(color: Colors.red),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ],
          ),
        ],
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
          child: const Icon(
            Icons.restaurant_outlined,
            size: 50,
            color: Colors.white,
          ),
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
