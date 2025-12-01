import 'package:my_app/models/cart_item.dart';

class Order {
  final String id;
  final String dateText;
  final List<CartItem> items;
  final double amount;
  final String status;

  const Order({
    required this.id,
    required this.dateText,
    required this.items,
    required this.amount,
    required this.status,
  });

  /// Create Order from JSON
  factory Order.fromJson(Map<String, dynamic> json) {
    final List<dynamic> itemsJson = json['items'] as List<dynamic>? ?? [];
    final items = itemsJson
        .map((item) => CartItem.fromJson(item as Map<String, dynamic>))
        .toList();

    return Order(
      id: json['id']?.toString() ?? '',
      dateText: json['dateText'] as String? ?? json['date'] as String? ?? '',
      items: items,
      amount: (json['amount'] as num?)?.toDouble() ?? 0.0,
      status: json['status'] as String? ?? 'Pending',
    );
  }

  /// Convert Order to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'dateText': dateText,
      'items': items.map((item) => item.toJson()).toList(),
      'amount': amount,
      'status': status,
    };
  }
}
