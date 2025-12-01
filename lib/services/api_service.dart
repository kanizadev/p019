import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/coffee_item.dart';
import '../models/order.dart';
import '../models/cart_item.dart';

/// Custom exception for API errors
class ApiException implements Exception {
  final String message;
  final int? statusCode;

  ApiException(this.message, [this.statusCode]);

  @override
  String toString() => message;
}

/// API Service for handling all HTTP requests
class ApiService {
  // Base URL - Replace with your actual API endpoint
  // For demo purposes, using a mock API structure
  static const String baseUrl = 'https://api.coffeeshop.example.com/api/v1';

  // For development/testing, you can use a mock service
  // Set this to true to use mock data instead of real API calls
  static const bool useMockData = true;

  final http.Client _client;
  final Duration _timeout = const Duration(seconds: 30);

  ApiService({http.Client? client}) : _client = client ?? http.Client();

  /// Generic GET request handler
  Future<Map<String, dynamic>> _get(
    String endpoint, {
    Map<String, String>? headers,
  }) async {
    try {
      final uri = Uri.parse('$baseUrl$endpoint');
      final response = await _client
          .get(uri, headers: headers)
          .timeout(_timeout);

      return _handleResponse(response);
    } on http.ClientException catch (e) {
      throw ApiException('Network error: ${e.message}');
    } catch (e) {
      throw ApiException('Unexpected error: $e');
    }
  }

  /// Generic POST request handler
  Future<Map<String, dynamic>> _post(
    String endpoint, {
    Map<String, String>? headers,
    Object? body,
  }) async {
    try {
      final uri = Uri.parse('$baseUrl$endpoint');
      final response = await _client
          .post(
            uri,
            headers: {'Content-Type': 'application/json', ...?headers},
            body: body != null ? jsonEncode(body) : null,
          )
          .timeout(_timeout);

      return _handleResponse(response);
    } on http.ClientException catch (e) {
      throw ApiException('Network error: ${e.message}');
    } catch (e) {
      throw ApiException('Unexpected error: $e');
    }
  }

  /// Handle HTTP response
  Map<String, dynamic> _handleResponse(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      try {
        return jsonDecode(response.body) as Map<String, dynamic>;
      } catch (e) {
        throw ApiException('Invalid JSON response', response.statusCode);
      }
    } else {
      throw ApiException(
        'Request failed with status: ${response.statusCode}',
        response.statusCode,
      );
    }
  }

  /// Fetch all coffee items
  Future<List<CoffeeItem>> getCoffeeItems() async {
    if (useMockData) {
      // Simulate network delay
      await Future.delayed(const Duration(milliseconds: 800));
      return _getMockCoffeeItems();
    }

    try {
      final response = await _get('/coffee/items');
      final List<dynamic> items = response['data'] ?? response['items'] ?? [];
      return items
          .map((item) => CoffeeItem.fromJson(item as Map<String, dynamic>))
          .toList();
    } catch (e) {
      // Fallback to mock data on error
      return _getMockCoffeeItems();
    }
  }

  /// Fetch coffee items by category
  Future<List<CoffeeItem>> getCoffeeItemsByCategory(String category) async {
    if (useMockData) {
      await Future.delayed(const Duration(milliseconds: 600));
      final allItems = _getMockCoffeeItems();
      if (category == 'All') return allItems;
      return allItems.where((item) => item.category == category).toList();
    }

    try {
      final response = await _get('/coffee/items?category=$category');
      final List<dynamic> items = response['data'] ?? response['items'] ?? [];
      return items
          .map((item) => CoffeeItem.fromJson(item as Map<String, dynamic>))
          .toList();
    } catch (e) {
      final allItems = _getMockCoffeeItems();
      if (category == 'All') return allItems;
      return allItems.where((item) => item.category == category).toList();
    }
  }

  /// Place an order
  Future<Order> placeOrder({
    required List<CartItem> items,
    required double totalAmount,
    Map<String, dynamic>? shippingInfo,
  }) async {
    if (useMockData) {
      await Future.delayed(const Duration(milliseconds: 1200));
      final now = DateTime.now();
      return Order(
        id: 'ORD-${now.millisecondsSinceEpoch}',
        dateText: '${now.day}/${now.month}/${now.year}',
        items: items,
        amount: totalAmount,
        status: 'Processing',
      );
    }

    try {
      final response = await _post(
        '/orders',
        body: {
          'items': items
              .map(
                (item) => {
                  'name': item.name,
                  'price': item.price,
                  'quantity': item.quantity,
                },
              )
              .toList(),
          'totalAmount': totalAmount,
          'shippingInfo': shippingInfo ?? {},
        },
      );

      final orderData = response['data'] ?? response;
      return Order.fromJson(orderData as Map<String, dynamic>);
    } catch (e) {
      // Fallback to creating order locally
      final now = DateTime.now();
      return Order(
        id: 'ORD-${now.millisecondsSinceEpoch}',
        dateText: '${now.day}/${now.month}/${now.year}',
        items: items,
        amount: totalAmount,
        status: 'Processing',
      );
    }
  }

  /// Get user orders
  Future<List<Order>> getUserOrders(String userId) async {
    if (useMockData) {
      await Future.delayed(const Duration(milliseconds: 600));
      return [];
    }

    try {
      final response = await _get('/orders/user/$userId');
      final List<dynamic> orders = response['data'] ?? response['orders'] ?? [];
      return orders
          .map((order) => Order.fromJson(order as Map<String, dynamic>))
          .toList();
    } catch (e) {
      return [];
    }
  }

  /// Mock coffee items data (fallback)
  List<CoffeeItem> _getMockCoffeeItems() {
    return [
      CoffeeItem(
        id: '1',
        name: 'Caffe Latte',
        subtitle: 'With steamed milk',
        price: '\$4.99',
        imageUrl:
            'https://images.unsplash.com/photo-1570968915860-54d5c301fa9f?ixlib=rb-4.0.3&ixid=MnwxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8&auto=format&fit=crop&w=1075&q=80',
        category: 'Hot Drinks',
      ),
      CoffeeItem(
        id: '2',
        name: 'Cappuccino',
        subtitle: 'With foam and chocolate',
        price: '\$5.49',
        imageUrl:
            'https://images.unsplash.com/photo-1534778101976-62847782c213?ixlib=rb-4.0.3&ixid=MnwxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8&auto=format&fit=crop&w=1170&q=80',
        category: 'Hot Drinks',
      ),
      CoffeeItem(
        id: '3',
        name: 'Americano',
        subtitle: 'Espresso with hot water',
        price: '\$3.99',
        imageUrl:
            'https://images.unsplash.com/photo-1551030173-122aabc4489c?ixlib=rb-4.0.3&ixid=MnwxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8&auto=format&fit=crop&w=687&q=80',
        category: 'Hot Drinks',
      ),
      CoffeeItem(
        id: '4',
        name: 'Espresso',
        subtitle: 'Strong black coffee',
        price: '\$3.49',
        imageUrl:
            'https://images.unsplash.com/photo-1577968897966-3d4325b36b61?ixlib=rb-4.0.3&ixid=MnwxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8&auto=format&fit=crop&w=1074&q=80',
        category: 'Hot Drinks',
      ),
      CoffeeItem(
        id: '5',
        name: 'Flat White',
        subtitle: 'Espresso with steamed milk',
        price: '\$4.79',
        imageUrl:
            'https://images.unsplash.com/photo-1577968897966-3d4325b36b61?ixlib=rb-4.0.3&ixid=MnwxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8&auto=format&fit=crop&w=1074&q=80',
        category: 'Hot Drinks',
      ),
      CoffeeItem(
        id: '6',
        name: 'Mocha',
        subtitle: 'Espresso with chocolate',
        price: '\$5.99',
        imageUrl:
            'https://images.unsplash.com/photo-1578314675249-a6910f80cc4e?ixlib=rb-4.0.3&ixid=MnwxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8&auto=format&fit=crop&w=1074&q=80',
        category: 'Hot Drinks',
      ),
      CoffeeItem(
        id: '7',
        name: 'Iced Coffee',
        subtitle: 'Chilled coffee with ice',
        price: '\$4.49',
        imageUrl:
            'https://images.unsplash.com/photo-1517701604599-bb29b565090c?ixlib=rb-4.0.3&ixid=MnwxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8&auto=format&fit=crop&w=687&q=80',
        category: 'Cold Drinks',
      ),
      CoffeeItem(
        id: '8',
        name: 'Frappuccino',
        subtitle: 'Blended coffee drink',
        price: '\$6.49',
        imageUrl:
            'https://images.unsplash.com/photo-1578662996442-48f60103fc96?ixlib=rb-4.0.3&ixid=MnwxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8&auto=format&fit=crop&w=1170&q=80',
        category: 'Cold Drinks',
      ),
      CoffeeItem(
        id: '9',
        name: 'Cold Brew',
        subtitle: 'Slow-steeped cold coffee',
        price: '\$4.99',
        imageUrl:
            'https://images.unsplash.com/photo-1509042239860-f550ce710b93?ixlib=rb-4.0.3&ixid=MnwxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8&auto=format&fit=crop&w=1170&q=80',
        category: 'Cold Drinks',
      ),
      CoffeeItem(
        id: '10',
        name: 'Iced Latte',
        subtitle: 'Espresso with cold milk',
        price: '\$5.49',
        imageUrl:
            'https://images.unsplash.com/photo-1562440499-64e2bfba1f4e?ixlib=rb-4.0.3&ixid=MnwxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8&auto=format&fit=crop&w=1170&q=80',
        category: 'Cold Drinks',
      ),
      CoffeeItem(
        id: '11',
        name: 'Iced Mocha',
        subtitle: 'Cold espresso with chocolate',
        price: '\$6.29',
        imageUrl:
            'https://images.unsplash.com/photo-1582719478147-ff9c1b3c8f4e?ixlib=rb-4.0.3&ixid=MnwxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8&auto=format&fit=crop&w=1170&q=80',
        category: 'Cold Drinks',
      ),
      CoffeeItem(
        id: '12',
        name: 'Nitro Cold Brew',
        subtitle: 'Infused with nitrogen',
        price: '\$5.99',
        imageUrl:
            'https://images.unsplash.com/photo-1551024601-bec78aea704b?ixlib=rb-4.0.3&ixid=MnwxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8&auto=format&fit=crop&w=1170&q=80',
        category: 'Cold Drinks',
      ),
    ];
  }

  void dispose() {
    _client.close();
  }
}
