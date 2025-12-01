class CoffeeItem {
  final String? id;
  final String name;
  final String subtitle;
  final String price;
  final String imageUrl;
  final String category;

  const CoffeeItem({
    this.id,
    required this.name,
    required this.subtitle,
    required this.price,
    required this.imageUrl,
    required this.category,
  });

  /// Create CoffeeItem from JSON
  factory CoffeeItem.fromJson(Map<String, dynamic> json) {
    return CoffeeItem(
      id: json['id']?.toString(),
      name: json['name'] as String,
      subtitle:
          json['subtitle'] as String? ?? json['description'] as String? ?? '',
      price: json['price']?.toString() ?? '\$0.00',
      imageUrl:
          json['imageUrl'] as String? ??
          json['image_url'] as String? ??
          json['image'] as String? ??
          '',
      category: json['category'] as String? ?? 'Uncategorized',
    );
  }

  /// Convert CoffeeItem to JSON
  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'name': name,
      'subtitle': subtitle,
      'price': price,
      'imageUrl': imageUrl,
      'category': category,
    };
  }

  /// Create a copy with updated fields
  CoffeeItem copyWith({
    String? id,
    String? name,
    String? subtitle,
    String? price,
    String? imageUrl,
    String? category,
  }) {
    return CoffeeItem(
      id: id ?? this.id,
      name: name ?? this.name,
      subtitle: subtitle ?? this.subtitle,
      price: price ?? this.price,
      imageUrl: imageUrl ?? this.imageUrl,
      category: category ?? this.category,
    );
  }
}
