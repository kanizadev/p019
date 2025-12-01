class CartItem {
  final String name;
  final double price;
  int quantity;

  CartItem({required this.name, required this.price, required this.quantity});

  /// Create CartItem from JSON
  factory CartItem.fromJson(Map<String, dynamic> json) {
    return CartItem(
      name: json['name'] as String,
      price: (json['price'] as num).toDouble(),
      quantity: json['quantity'] as int? ?? 1,
    );
  }

  /// Convert CartItem to JSON
  Map<String, dynamic> toJson() {
    return {'name': name, 'price': price, 'quantity': quantity};
  }

  /// Create a copy with updated fields
  CartItem copyWith({String? name, double? price, int? quantity}) {
    return CartItem(
      name: name ?? this.name,
      price: price ?? this.price,
      quantity: quantity ?? this.quantity,
    );
  }
}
