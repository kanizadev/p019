class Recipe {
  final String id;
  final String title;
  final String description;
  final List<String> ingredients;
  final List<String> instructions;
  final int prepTime; // in minutes
  final int cookTime; // in minutes
  final int servings;
  final String category;
  final String? imageUrl;
  final bool isFavorite;
  final double rating;

  Recipe({
    required this.id,
    required this.title,
    required this.description,
    required this.ingredients,
    required this.instructions,
    required this.prepTime,
    required this.cookTime,
    required this.servings,
    required this.category,
    this.imageUrl,
    this.isFavorite = false,
    this.rating = 0.0,
  });

  int get totalTime => prepTime + cookTime;

  Recipe copyWith({
    String? id,
    String? title,
    String? description,
    List<String>? ingredients,
    List<String>? instructions,
    int? prepTime,
    int? cookTime,
    int? servings,
    String? category,
    String? imageUrl,
    bool? isFavorite,
    double? rating,
  }) {
    return Recipe(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      ingredients: ingredients ?? this.ingredients,
      instructions: instructions ?? this.instructions,
      prepTime: prepTime ?? this.prepTime,
      cookTime: cookTime ?? this.cookTime,
      servings: servings ?? this.servings,
      category: category ?? this.category,
      imageUrl: imageUrl ?? this.imageUrl,
      isFavorite: isFavorite ?? this.isFavorite,
      rating: rating ?? this.rating,
    );
  }
}
