import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/recipe.dart';

class RecipeApiService {
  static const String baseUrl = 'https://www.themealdb.com/api/json/v1/1';

  // Fetch random recipes
  Future<List<Recipe>> getRandomRecipes({int count = 10}) async {
    try {
      final List<Recipe> recipes = [];

      // Fetch multiple random meals
      for (int i = 0; i < count; i++) {
        final response = await http.get(Uri.parse('$baseUrl/random.php'));

        if (response.statusCode == 200) {
          final data = json.decode(response.body);
          if (data['meals'] != null && data['meals'].isNotEmpty) {
            final meal = data['meals'][0];
            recipes.add(_mealToRecipe(meal));
          }
        }
      }

      return recipes;
    } catch (e) {
      throw Exception('Failed to fetch recipes: $e');
    }
  }

  // Search recipes by name
  Future<List<Recipe>> searchRecipes(String query) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/search.php?s=${Uri.encodeComponent(query)}'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['meals'] != null && data['meals'] is List) {
          return (data['meals'] as List)
              .map((meal) => _mealToRecipe(meal))
              .toList();
        }
      }

      return [];
    } catch (e) {
      throw Exception('Failed to search recipes: $e');
    }
  }

  // Get recipes by category
  Future<List<Recipe>> getRecipesByCategory(String category) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/filter.php?c=${Uri.encodeComponent(category.replaceAll(' ', '_'))}'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['meals'] != null && data['meals'] is List) {
          // Fetch full details for each meal
          final List<Recipe> recipes = [];
          for (var meal in data['meals'] as List) {
            try {
              final mealId = meal['idMeal']?.toString() ?? '';
              if (mealId.isEmpty) continue;
              final detailResponse = await http.get(
                Uri.parse('$baseUrl/lookup.php?i=${Uri.encodeComponent(mealId)}'),
              );
              if (detailResponse.statusCode == 200) {
                final detailData = json.decode(detailResponse.body);
                if (detailData['meals'] != null &&
                    detailData['meals'].isNotEmpty) {
                  recipes.add(_mealToRecipe(detailData['meals'][0]));
                }
              }
            } catch (e) {
              // Skip if detail fetch fails
              continue;
            }
          }
          return recipes;
        }
      }

      return [];
    } catch (e) {
      throw Exception('Failed to fetch recipes by category: $e');
    }
  }

  // Get popular recipes (by category)
  Future<List<Recipe>> getPopularRecipes() async {
    try {
      final List<Recipe> recipes = [];
      final popularCategories = ['Dessert', 'Chicken', 'Beef', 'Seafood'];

      for (var category in popularCategories) {
        final categoryRecipes = await getRecipesByCategory(category);
        recipes.addAll(categoryRecipes.take(3)); // Take 3 from each category
      }

      return recipes;
    } catch (e) {
      throw Exception('Failed to fetch popular recipes: $e');
    }
  }

  // Convert API meal data to Recipe model
  Recipe _mealToRecipe(Map<String, dynamic> meal) {
    // Extract ingredients
    final List<String> ingredients = [];
    for (int i = 1; i <= 20; i++) {
      final ingredient = meal['strIngredient$i'];
      final measure = meal['strMeasure$i'];
      if (ingredient != null && ingredient.toString().trim().isNotEmpty) {
        final measureStr =
            measure != null && measure.toString().trim().isNotEmpty
            ? measure.toString().trim()
            : '';
        ingredients.add(
          '${measureStr.isNotEmpty ? "$measureStr " : ""}$ingredient',
        );
      }
    }

    // Extract instructions
    final String instructionsStr = meal['strInstructions'] ?? '';
    final List<String> instructions = instructionsStr
        .split('\n')
        .where((step) => step.trim().isNotEmpty)
        .map((step) => step.trim())
        .toList();

    // Estimate prep and cook time (API doesn't provide this)
    final int prepTime = 15;
    final int cookTime = 30;

    // Get category
    final String category = meal['strCategory'] ?? 'Unknown';

    return Recipe(
      id: meal['idMeal'] ?? DateTime.now().millisecondsSinceEpoch.toString(),
      title: meal['strMeal'] ?? 'Unknown Recipe',
      description: () {
        final instructions = meal['strInstructions'] as String?;
        if (instructions != null && instructions.isNotEmpty) {
          return instructions.length > 150
              ? instructions.substring(0, 150)
              : instructions;
        }
        return 'A delicious recipe';
      }(),
      ingredients: ingredients,
      instructions: instructions.isNotEmpty
          ? instructions
          : ['Follow the instructions provided.'],
      prepTime: prepTime,
      cookTime: cookTime,
      servings: 4, // Default servings
      category: category,
      imageUrl: meal['strMealThumb'],
    );
  }
}
