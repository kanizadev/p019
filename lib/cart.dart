import 'package:flutter/material.dart';
import 'package:my_app/models/cart_item.dart';
import 'package:my_app/models/coffee_item.dart';
import 'package:my_app/widgets/cart_item_widget.dart';
import 'package:my_app/widgets/cart_summary_widget.dart';
import 'package:my_app/theme.dart';

class MyCart extends StatefulWidget {
  final List<CartItem> cartItems;
  final List<CoffeeItem> coffeeItems;
  final Function(int) onIncrement;
  final Function(int) onDecrement;
  final Function(int) onRemove;
  final VoidCallback onPlaceOrder;
  final VoidCallback onClearCart;

  const MyCart({
    super.key,
    required this.cartItems,
    required this.coffeeItems,
    required this.onIncrement,
    required this.onDecrement,
    required this.onRemove,
    required this.onPlaceOrder,
    required this.onClearCart,
  });

  @override
  State<MyCart> createState() => _MyCartState();
}

class _MyCartState extends State<MyCart> {
  @override
  Widget build(BuildContext context) {
    final int totalItems = widget.cartItems.fold(
      0,
      (sum, item) => sum + item.quantity,
    );
    final bool hasItems = widget.cartItems.isNotEmpty;

    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: const Text('My Cart'),
        actions: [
          if (hasItems)
            Padding(
              padding: const EdgeInsets.only(right: 12),
              child: Chip(
                avatar: const Icon(
                  Icons.local_cafe,
                  size: 18,
                  color: Colors.white,
                ),
                label: Text('$totalItems items'),
                labelStyle: const TextStyle(color: Colors.white),
                backgroundColor: Theme.of(context).colorScheme.primary,
              ),
            ),
          if (hasItems)
            IconButton(
              icon: const Icon(Icons.delete_sweep_outlined),
              tooltip: 'Clear cart',
              onPressed: () async {
                final confirmed = await showDialog<bool>(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Clear Cart'),
                    content: const Text(
                      'Are you sure you want to remove all items from your cart?',
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(false),
                        child: const Text('Cancel'),
                      ),
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(true),
                        style: TextButton.styleFrom(
                          foregroundColor: AppTheme.error,
                        ),
                        child: const Text('Clear All'),
                      ),
                    ],
                  ),
                );
                if (confirmed == true) {
                  widget.onClearCart();
                  if (!context.mounted) return;
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(const SnackBar(content: Text('Cart cleared')));
                }
              },
            ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Theme.of(context).colorScheme.surface,
              Theme.of(context).scaffoldBackgroundColor,
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          top: false,
          child: Column(
            children: [
              const SizedBox(height: kToolbarHeight + 12),
              Expanded(
                child: hasItems
                    ? CustomScrollView(
                        physics: const BouncingScrollPhysics(),
                        slivers: [
                          SliverToBoxAdapter(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                              ),
                              child: _CartOverview(
                                totalItems: totalItems,
                                cartItems: widget.cartItems,
                              ),
                            ),
                          ),
                          SliverPadding(
                            padding: const EdgeInsets.fromLTRB(16, 24, 16, 12),
                            sliver: SliverList(
                              delegate: SliverChildBuilderDelegate((
                                context,
                                index,
                              ) {
                                final cartItem = widget.cartItems[index];
                                final coffeeItem = widget.coffeeItems
                                    .firstWhere(
                                      (item) => item.name == cartItem.name,
                                    );
                                return Padding(
                                  padding: EdgeInsets.only(
                                    bottom: index == widget.cartItems.length - 1
                                        ? 0
                                        : 18,
                                  ),
                                  child: CartItemWidget(
                                    cartItem: cartItem,
                                    coffeeItem: coffeeItem,
                                    onIncrement: () =>
                                        widget.onIncrement(index),
                                    onDecrement: () =>
                                        widget.onDecrement(index),
                                    onRemove: () => widget.onRemove(index),
                                  ),
                                );
                              }, childCount: widget.cartItems.length),
                            ),
                          ),
                        ],
                      )
                    : const _EmptyCart(),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
                child: CartSummaryWidget(
                  cartItems: widget.cartItems,
                  coffeeItems: widget.coffeeItems,
                  onPlaceOrder: widget.onPlaceOrder,
                  onClearCart: widget.onClearCart,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CartOverview extends StatelessWidget {
  final int totalItems;
  final List<CartItem> cartItems;

  const _CartOverview({required this.totalItems, required this.cartItems});

  double get subtotal =>
      cartItems.fold(0, (sum, item) => sum + item.price * item.quantity);

  @override
  Widget build(BuildContext context) {
    final Color primary = Theme.of(context).colorScheme.primary;
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface.withValues(alpha: 0.94),
        borderRadius: BorderRadius.circular(26),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).colorScheme.shadow.withValues(alpha: 0.06),
            blurRadius: 22,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: primary.withValues(alpha: 0.15),
            ),
            child: Icon(Icons.shopping_bag, color: primary),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'You\'re almost there!',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 4),
                Text(
                  '$totalItems item${totalItems == 1 ? '' : 's'} ready to brew',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '\$${subtotal.toStringAsFixed(2)}',
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(color: primary),
              ),
              const SizedBox(height: 4),
              Text(
                'Subtotal',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(
                    context,
                  ).colorScheme.onSurface.withValues(alpha: 0.45),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _EmptyCart extends StatelessWidget {
  const _EmptyCart();

  @override
  Widget build(BuildContext context) {
    final Color primary = Theme.of(context).colorScheme.primary;
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: primary.withValues(alpha: 0.12),
              ),
              child: Icon(
                Icons.shopping_cart_outlined,
                size: 48,
                color: primary,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Your cart is empty',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Add some delicious coffee to get started!',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(
                  context,
                ).colorScheme.onSurface.withValues(alpha: 0.6),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
