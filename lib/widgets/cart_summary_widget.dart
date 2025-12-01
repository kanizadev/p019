import 'package:flutter/material.dart';
import 'package:my_app/checkout.dart';
import 'package:my_app/models/cart_item.dart';
import 'package:my_app/models/coffee_item.dart';

class CartSummaryWidget extends StatelessWidget {
  final List<CartItem> cartItems;
  final List<CoffeeItem> coffeeItems;
  final VoidCallback onPlaceOrder;
  final VoidCallback onClearCart;

  const CartSummaryWidget({
    super.key,
    required this.cartItems,
    required this.coffeeItems,
    required this.onPlaceOrder,
    required this.onClearCart,
  });

  double get subtotal =>
      cartItems.fold(0, (sum, item) => sum + (item.price * item.quantity));
  double get total => subtotal;

  @override
  Widget build(BuildContext context) {
    final Color primary = Theme.of(context).colorScheme.primary;
    final bool isEmpty = cartItems.isEmpty;

    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).colorScheme.shadow.withValues(alpha: 0.12),
            blurRadius: 26,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Order summary',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              if (!isEmpty)
                TextButton.icon(
                  onPressed: onClearCart,
                  icon: const Icon(Icons.delete_outline, size: 18),
                  label: const Text('Clear'),
                ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: primary.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(18),
            ),
            child: Column(
              children: [
                _SummaryRow(
                  label: 'Subtotal (${cartItems.length} items)',
                  value: '\$${subtotal.toStringAsFixed(2)}',
                ),
                const SizedBox(height: 10),
                _SummaryRow(
                  label: 'Delivery',
                  value: 'Free',
                  valueStyle: TextStyle(
                    color: primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Divider(
                  height: 24,
                  thickness: 1,
                  color: Theme.of(
                    context,
                  ).colorScheme.outline.withValues(alpha: 0.2),
                ),
                _SummaryRow(
                  label: 'Total',
                  value: '\$${total.toStringAsFixed(2)}',
                  valueStyle: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: primary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {
                if (isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: const Text('Your cart is empty.'),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                  return;
                }
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => CheckoutPage(
                      cartItems: cartItems,
                      coffeeItems: coffeeItems,
                      onPlaceOrder: onPlaceOrder,
                    ),
                  ),
                );
              },
              icon: Icon(
                isEmpty ? Icons.shopping_cart_outlined : Icons.delivery_dining,
                size: 20,
              ),
              label: const Text('Proceed to checkout'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
          ),
          if (!isEmpty) ...[
            const SizedBox(height: 18),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: primary.withValues(alpha: 0.12)),
              ),
              child: Row(
                children: [
                  Icon(Icons.local_fire_department, color: primary, size: 20),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Members earn ${(total * 0.1).toStringAsFixed(0)} reward points with this order.',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  final String label;
  final String value;
  final TextStyle? valueStyle;

  const _SummaryRow({
    required this.label,
    required this.value,
    this.valueStyle,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: Theme.of(
              context,
            ).colorScheme.onSurface.withValues(alpha: 0.6),
          ),
        ),
        Text(
          value,
          style:
              valueStyle ??
              TextStyle(
                fontWeight: FontWeight.w600,
                color: Theme.of(context).colorScheme.onSurface,
              ),
        ),
      ],
    );
  }
}
