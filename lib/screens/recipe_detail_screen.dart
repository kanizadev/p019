import 'dart:io';
import 'dart:ui';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/recipe.dart';
import '../widgets/glass_widget.dart';
import 'add_edit_recipe_screen.dart';

class RecipeDetailScreen extends StatelessWidget {
  final Recipe recipe;

  const RecipeDetailScreen({super.key, required this.recipe});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      extendBodyBehindAppBar: true,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              const Color(0xFF9CAF88), // Sage green light
              const Color(0xFF87A96B), // Sage green
              const Color(0xFF6B8E5A), // Dark sage green
              const Color(0xFF5A7A4A), // Deeper sage
            ],
            stops: const [0.0, 0.4, 0.7, 1.0],
          ),
        ),
        child: CustomScrollView(
          slivers: [
          // Minimal App Bar
          SliverAppBar(
            expandedHeight: 120,
            pinned: true,
            floating: false,
            backgroundColor: Colors.transparent,
            flexibleSpace: FlexibleSpaceBar(
              titlePadding: const EdgeInsets.only(left: 16, bottom: 12),
              centerTitle: false,
              title: Text(
                recipe.title,
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                  letterSpacing: -0.5,
                  shadows: [
                    Shadow(
                      offset: const Offset(0, 2),
                      blurRadius: 8,
                      color: Colors.black.withValues(alpha: 0.3),
                    ),
                  ],
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              background: Stack(
                children: [
                  if (recipe.imageUrl != null &&
                      recipe.imageUrl!.isNotEmpty)
                    Positioned.fill(
                      child: _buildRecipeImage(recipe.imageUrl!),
                    ),
                  ClipRRect(
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
                  icon: const Icon(Icons.edit_outlined, color: Colors.white),
                  onPressed: () async {
                    final updatedRecipe = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => AddEditRecipeScreen(recipe: recipe),
                      ),
                    );
                    if (!context.mounted) return;
                    if (updatedRecipe != null && updatedRecipe is Recipe) {
                      Navigator.pop(context, updatedRecipe);
                    }
                  },
                  tooltip: 'Edit Recipe',
                ),
              ),
            ],
          ),
          // Content
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Description with Glassmorphism
                  GlassWidget(
                    padding: const EdgeInsets.all(24),
                    opacity: 0.4,
                    color: const Color(0xFF9CAF88),
                    child: Text(
                      recipe.description,
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.white.withValues(alpha: 0.9),
                        height: 1.7,
                        fontWeight: FontWeight.w400,
                        letterSpacing: 0.2,
                        shadows: const [
                          Shadow(
                            offset: Offset(0, 1),
                            blurRadius: 4,
                            color: Colors.black26,
                          ),
                        ],
                      ),
                      softWrap: true,
                    ),
                  ),
                  const SizedBox(height: 28),
                  // Enhanced Stats Row with Advanced Design
                  GlassWidget(
                    padding: const EdgeInsets.symmetric(
                      vertical: 24,
                      horizontal: 16,
                    ),
                    opacity: 0.4,
                    color: const Color(0xFF9CAF88),
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        final isSmallScreen = constraints.maxWidth < 400;
                        return isSmallScreen
                            ? Wrap(
                                alignment: WrapAlignment.center,
                                spacing: 16,
                                runSpacing: 16,
                                children: [
                                  _StatItem(
                                    icon: Icons.access_time,
                                    label: 'Prep',
                                    value: '${recipe.prepTime} min',
                                  ),
                                  _StatItem(
                                    icon: Icons.timer,
                                    label: 'Cook',
                                    value: '${recipe.cookTime} min',
                                  ),
                                  _StatItem(
                                    icon: Icons.schedule,
                                    label: 'Total',
                                    value: '${recipe.totalTime} min',
                                  ),
                                  _StatItem(
                                    icon: Icons.people,
                                    label: 'Serves',
                                    value: '${recipe.servings}',
                                  ),
                                ],
                              )
                            : Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceAround,
                                children: [
                                  Expanded(
                                    child: _StatItem(
                                      icon: Icons.access_time,
                                      label: 'Prep',
                                      value: '${recipe.prepTime} min',
                                    ),
                                  ),
                                  Expanded(
                                    child: _StatItem(
                                      icon: Icons.timer,
                                      label: 'Cook',
                                      value: '${recipe.cookTime} min',
                                    ),
                                  ),
                                  Expanded(
                                    child: _StatItem(
                                      icon: Icons.schedule,
                                      label: 'Total',
                                      value: '${recipe.totalTime} min',
                                    ),
                                  ),
                                  Expanded(
                                    child: _StatItem(
                                      icon: Icons.people,
                                      label: 'Serves',
                                      value: '${recipe.servings}',
                                    ),
                                  ),
                                ],
                              );
                      },
                    ),
                  ),
                  const SizedBox(height: 20),
                  // Category Badge with Advanced Design
                  Center(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(30),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 12,
                          ),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                const Color(0xFF87A96B).withValues(alpha: 0.7),
                                const Color(0xFF6B8E5A).withValues(alpha: 0.65),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(30),
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.4),
                              width: 1.5,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF87A96B).withValues(alpha: 0.3),
                                blurRadius: 15,
                                offset: const Offset(0, 6),
                                spreadRadius: -2,
                              ),
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.1),
                                blurRadius: 8,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(4),
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.2),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.category_outlined,
                                  color: Colors.white,
                                  size: 16,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Flexible(
                                child: Text(
                                  recipe.category,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                    color: Colors.white,
                                    letterSpacing: 0.8,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 36),
                  // Enhanced Ingredients Section with Icon
                  Row(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  const Color(
                                    0xFF87A96B,
                                  ).withValues(alpha: 0.9),
                                  const Color(
                                    0xFF6B8E5A,
                                  ).withValues(alpha: 0.85),
                                ],
                              ),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: Colors.white.withValues(alpha: 0.3),
                                width: 1.5,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Color(
                                    0xFF87A96B,
                                  ).withValues(alpha: 0.3),
                                  blurRadius: 8,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: const Icon(
                              Icons.shopping_basket_outlined,
                              color: Colors.white,
                              size: 24,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      const Text(
                        'Ingredients',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          letterSpacing: -0.8,
                          color: Colors.white,
                          shadows: [
                            Shadow(
                              offset: Offset(0, 2),
                              blurRadius: 8,
                              color: Colors.black26,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  GlassWidget(
                    padding: const EdgeInsets.all(20),
                    opacity: 0.4,
                    color: const Color(0xFF9CAF88),
                    child: Column(
                      children: recipe.ingredients.asMap().entries.map((
                        entry,
                      ) {
                        final index = entry.key;
                        final ingredient = entry.value;
                        return TweenAnimationBuilder<double>(
                          tween: Tween(begin: 0.0, end: 1.0),
                          duration: Duration(
                            milliseconds: 200 + (index * 50),
                          ),
                          builder: (context, value, child) {
                            return Opacity(
                              opacity: value,
                              child: Transform.translate(
                                offset: Offset(20 * (1 - value), 0),
                                child: child,
                              ),
                            );
                          },
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(6),
                                  decoration: BoxDecoration(
                                    color: const Color(
                                      0xFF87A96B,
                                    ), // Sage green
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.check,
                                    size: 14,
                                    color: Colors.white,
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Text(
                                    ingredient,
                                    style: const TextStyle(
                                      fontSize: 16,
                                      height: 1.6,
                                      fontWeight: FontWeight.w500,
                                      color: Color(0xFF2C3E2D),
                                    ),
                                    maxLines: 3,
                                    overflow: TextOverflow.ellipsis,
                                    softWrap: true,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                  const SizedBox(height: 36),
                  // Enhanced Instructions Section with Icon
                  Row(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  const Color(
                                    0xFF6B8E5A,
                                  ).withValues(alpha: 0.9),
                                  const Color(
                                    0xFF95B77A,
                                  ).withValues(alpha: 0.85),
                                ],
                              ),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: Colors.white.withValues(alpha: 0.3),
                                width: 1.5,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Color(
                                    0xFF6B8E5A,
                                  ).withValues(alpha: 0.3),
                                  blurRadius: 8,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: const Icon(
                              Icons.list_outlined,
                              color: Colors.white,
                              size: 24,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      const Text(
                        'Instructions',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          letterSpacing: -0.8,
                          color: Colors.white,
                          shadows: [
                            Shadow(
                              offset: Offset(0, 2),
                              blurRadius: 8,
                              color: Colors.black26,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  ...recipe.instructions.asMap().entries.map((entry) {
                    final index = entry.key;
                    final instruction = entry.value;
                    return TweenAnimationBuilder<double>(
                      tween: Tween(begin: 0.0, end: 1.0),
                      duration: Duration(milliseconds: 200 + (index * 50)),
                      builder: (context, value, child) {
                        return Opacity(
                          opacity: value,
                          child: Transform.translate(
                            offset: Offset(20 * (1 - value), 0),
                            child: child,
                          ),
                        );
                      },
                      child: GlassWidget(
                        margin: const EdgeInsets.only(bottom: 20),
                        padding: const EdgeInsets.all(22),
                        opacity: 0.4,
                        color: const Color(0xFF9CAF88),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: 44,
                              height: 44,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [
                                    const Color(0xFF87A96B),
                                    const Color(0xFF6B8E5A),
                                  ],
                                ),
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: Color(
                                      0xFF87A96B,
                                    ).withValues(alpha: 0.4),
                                    blurRadius: 12,
                                    offset: const Offset(0, 4),
                                    spreadRadius: -2,
                                  ),
                                ],
                              ),
                              child: Center(
                                child: Text(
                                  '${index + 1}',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 20),
                            Expanded(
                              child: Text(
                                instruction,
                                style: const TextStyle(
                                  fontSize: 16,
                                  height: 1.8,
                                  color: Color(0xFF2C3E2D),
                                  fontWeight: FontWeight.w400,
                                  letterSpacing: 0.1,
                                ),
                                softWrap: true,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ],
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
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return Container();
        },
      );
    } else {
      // Local file image - not supported on web
      if (kIsWeb) {
        // Show placeholder on web
        return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                const Color(0xFF9CAF88).withValues(alpha: 0.3),
                const Color(0xFF87A96B).withValues(alpha: 0.25),
              ],
            ),
          ),
          child: const Center(
            child: Icon(
              Icons.restaurant_outlined,
              size: 50,
              color: Colors.grey,
            ),
          ),
        );
      }
      return Image.file(
        File(imageUrl),
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return Container();
        },
      );
    }
  }
}

class _StatItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _StatItem({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(50),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.3),
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.5),
                  width: 2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Color(0xFF87A96B).withValues(alpha: 0.2),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                    spreadRadius: -2,
                  ),
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.08),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Icon(icon, color: Colors.white, size: 26),
            ),
          ),
        ),
        const SizedBox(height: 10),
        Text(
          value,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
            letterSpacing: -0.3,
            shadows: [
              Shadow(
                offset: Offset(0, 2),
                blurRadius: 8,
                color: Colors.black26,
              ),
            ],
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: TextStyle(
            fontSize: 13,
            color: Colors.white.withValues(alpha: 0.9),
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
            shadows: const [
              Shadow(
                offset: Offset(0, 1),
                blurRadius: 4,
                color: Colors.black26,
              ),
            ],
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }
}
