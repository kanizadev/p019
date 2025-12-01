import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'models/cart_item.dart';
import 'models/coffee_item.dart';
import 'payment_page.dart';
import 'order_confirmation_page.dart';

class CheckoutPage extends StatefulWidget {
  final List<CartItem> cartItems;
  final List<CoffeeItem> coffeeItems;
  final VoidCallback onPlaceOrder;

  const CheckoutPage({
    super.key,
    required this.cartItems,
    required this.coffeeItems,
    required this.onPlaceOrder,
  });

  @override
  State<CheckoutPage> createState() => _CheckoutPageState();
}

class _CheckoutPageState extends State<CheckoutPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _addressController = TextEditingController();

  double get subtotal => widget.cartItems.fold(
    0,
    (sum, item) => sum + (item.price * item.quantity),
  );

  double get total => subtotal;

  @override
  void dispose() {
    _addressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: Colors.transparent,
      appBar: AppBar(title: const Text('Checkout')),
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
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _CheckoutHero(
                          total: total,
                          itemCount: widget.cartItems.length,
                        ),
                        const SizedBox(height: 28),
                        const _SectionTitle(
                          icon: Icons.local_cafe,
                          title: 'Items in your order',
                        ),
                        const SizedBox(height: 16),
                        ..._buildItemTiles(),
                        const SizedBox(height: 28),
                        const _SectionTitle(
                          icon: Icons.location_on_outlined,
                          title: 'Delivery address',
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _addressController,
                          minLines: 2,
                          maxLines: 3,
                          decoration: const InputDecoration(
                            hintText: 'Enter your full address',
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter your delivery address';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 28),
                        const _SectionTitle(
                          icon: Icons.receipt_long_outlined,
                          title: 'Order summary',
                        ),
                        const SizedBox(height: 16),
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.surface,
                            borderRadius: BorderRadius.circular(26),
                            boxShadow: [
                              BoxShadow(
                                color: Theme.of(
                                  context,
                                ).colorScheme.shadow.withValues(alpha: 0.06),
                                blurRadius: 20,
                                offset: const Offset(0, 10),
                              ),
                            ],
                          ),
                          child: Column(
                            children: [
                              _SummaryRow(
                                label: 'Subtotal',
                                value: '\$${subtotal.toStringAsFixed(2)}',
                              ),
                              const SizedBox(height: 10),
                              _SummaryRow(
                                label: 'Delivery',
                                value: 'Free',
                                valueStyle: TextStyle(
                                  color: Theme.of(context).colorScheme.primary,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const Divider(height: 28),
                              _SummaryRow(
                                label: 'Total',
                                value: '\$${total.toStringAsFixed(2)}',
                                valueStyle: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w700,
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 120),
                      ],
                    ),
                  ),
                ),
              ),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
                child: ElevatedButton.icon(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => PaymentPage(
                            amount: total,
                            address: _addressController.text,
                            onPaymentSuccess: () {
                              widget.onPlaceOrder();
                              final orderId = DateTime.now()
                                  .millisecondsSinceEpoch
                                  .toString();
                              final navigator = Navigator.of(context);
                              navigator.pop(); // close payment page
                              Future.microtask(() {
                                navigator.pushReplacement(
                                  MaterialPageRoute(
                                    builder: (_) => OrderConfirmationPage(
                                      orderId: orderId,
                                      address: _addressController.text,
                                      totalAmount: total,
                                    ),
                                  ),
                                );
                              });
                            },
                          ),
                        ),
                      );
                    }
                  },
                  icon: const Icon(Icons.lock_open_rounded),
                  label: const Text('Confirm delivery details'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> _buildItemTiles() {
    final List<Widget> tiles = [];
    for (var i = 0; i < widget.cartItems.length; i++) {
      final cartItem = widget.cartItems[i];
      final coffeeItem = widget.coffeeItems.firstWhere(
        (item) => item.name == cartItem.name,
        orElse: () => CoffeeItem(
          name: cartItem.name,
          subtitle: 'Coffee',
          price: '\$${cartItem.price.toStringAsFixed(2)}',
          imageUrl: '',
          category: 'Unknown',
        ),
      );
      tiles.add(_CheckoutItemTile(cartItem: cartItem, coffeeItem: coffeeItem));
      if (i != widget.cartItems.length - 1) {
        tiles.add(const SizedBox(height: 12));
      }
    }
    if (tiles.isEmpty) {
      tiles.add(
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Theme.of(
              context,
            ).colorScheme.surface.withValues(alpha: 0.92),
            borderRadius: BorderRadius.circular(24),
          ),
          child: Text(
            'Your cart is empty. Add some coffees to continue.',
            style: TextStyle(
              color: Theme.of(
                context,
              ).colorScheme.onSurface.withValues(alpha: 0.6),
            ),
          ),
        ),
      );
    }
    return tiles;
  }
}

class _CheckoutHero extends StatelessWidget {
  final double total;
  final int itemCount;

  const _CheckoutHero({required this.total, required this.itemCount});

  @override
  Widget build(BuildContext context) {
    final Color primary = Theme.of(context).colorScheme.primary;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        image: const DecorationImage(
          image: NetworkImage(
            'https://images.unsplash.com/photo-1495474472287-4d71bcdd2085?'
            'ixlib=rb-4.0.3&auto=format&fit=crop&w=1170&q=80',
          ),
          fit: BoxFit.cover,
        ),
      ),
      child: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(28),
              gradient: LinearGradient(
                begin: Alignment.bottomCenter,
                end: Alignment.topCenter,
                colors: [
                  Colors.black.withValues(alpha: 0.75),
                  Colors.black.withValues(alpha: 0.2),
                ],
              ),
            ),
          ),
          Positioned.fill(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                const Text(
                  'Ready to brew',
                  style: TextStyle(color: Colors.white70, fontSize: 14),
                ),
                const SizedBox(height: 6),
                Text(
                  '$itemCount item${itemCount == 1 ? '' : 's'} on the way',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: primary.withValues(alpha: 0.18),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    '\$${total.toStringAsFixed(2)} due on delivery',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CheckoutItemTile extends StatelessWidget {
  final CartItem cartItem;
  final CoffeeItem coffeeItem;

  const _CheckoutItemTile({required this.cartItem, required this.coffeeItem});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface.withValues(alpha: 0.92),
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).colorScheme.shadow.withValues(alpha: 0.06),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(18),
              child: coffeeItem.imageUrl.isEmpty
                  ? Container(
                      width: 64,
                      height: 64,
                      color: Theme.of(
                        context,
                      ).colorScheme.primary.withValues(alpha: 0.1),
                      child: Icon(
                        Icons.coffee,
                        color: Theme.of(
                          context,
                        ).colorScheme.primary.withValues(alpha: 0.7),
                      ),
                    )
                  : CachedNetworkImage(
                      imageUrl: coffeeItem.imageUrl,
                      width: 64,
                      height: 64,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => Container(
                        width: 64,
                        height: 64,
                        color: Theme.of(context).colorScheme.surfaceVariant,
                        child: const Center(
                          child: SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                        ),
                      ),
                      errorWidget: (context, url, error) => Container(
                        width: 64,
                        height: 64,
                        color: Theme.of(context).colorScheme.surfaceVariant,
                        child: Icon(
                          Icons.coffee,
                          color: Theme.of(
                            context,
                          ).colorScheme.primary.withValues(alpha: 0.7),
                        ),
                      ),
                    ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    coffeeItem.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    coffeeItem.subtitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 12,
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
                  '\$${(cartItem.price * cartItem.quantity).toStringAsFixed(2)}',
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'x${cartItem.quantity}',
                  style: TextStyle(
                    fontSize: 12,
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final IconData icon;
  final String title;

  const _SectionTitle({required this.icon, required this.title});

  @override
  Widget build(BuildContext context) {
    final Color primary = Theme.of(context).colorScheme.primary;
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: primary.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Icon(icon, size: 18, color: primary),
        ),
        const SizedBox(width: 12),
        Text(
          title,
          style: Theme.of(
            context,
          ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
        ),
      ],
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
            ).colorScheme.onSurface.withValues(alpha: 0.7),
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
