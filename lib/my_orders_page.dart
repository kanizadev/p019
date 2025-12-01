import 'package:flutter/material.dart';
import 'package:my_app/models/order.dart';
import 'package:my_app/models/coffee_item.dart';
import 'package:my_app/widgets/profile/order_tile.dart';
import 'package:my_app/theme.dart';

class MyOrdersPage extends StatelessWidget {
  final List<Order> orders;
  final List<CoffeeItem> allItems;
  const MyOrdersPage({super.key, required this.orders, required this.allItems});

  @override
  Widget build(BuildContext context) {
    final Color primary = AppTheme.primary;
    final Color border = AppTheme.surface;

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Orders'),
        backgroundColor: AppTheme.background,
        foregroundColor: primary,
        elevation: 0.5,
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: orders.length,
        separatorBuilder: (_, __) => Divider(height: 1, color: border),
        itemBuilder: (context, index) {
          final order = orders[index];
          return OrderTile(order: order, primary: primary, allItems: allItems);
        },
      ),
    );
  }
}
