import 'package:flutter/material.dart';
import 'package:my_app/theme.dart';
import 'favorite.dart';
import 'models/cart_item.dart';
import 'models/coffee_item.dart';
import 'models/order.dart';
import 'my_orders_page.dart';
import 'settings.dart';

class MenuDrawer extends StatelessWidget {
  final Set<String> favorites;
  final void Function(String) onToggleFavorite;
  final List<CoffeeItem> allItems;
  final List<CartItem> cartItems;
  final VoidCallback onNavigateToCart;
  final List<Order> orders;
  final void Function(bool)? onThemeChanged;

  const MenuDrawer({
    super.key,
    required this.favorites,
    required this.onToggleFavorite,
    required this.allItems,
    required this.cartItems,
    required this.onNavigateToCart,
    required this.orders,
    this.onThemeChanged,
  });

  @override
  Widget build(BuildContext context) {
    final int favoritesCount = favorites.length;
    final int cartCount = cartItems.fold<int>(
      0,
      (sum, item) => sum + item.quantity,
    );
    final int ordersCount = orders.length;

    return Drawer(
      backgroundColor: Colors.transparent,
      child: Container(
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
          child: Column(
            children: [
              const SizedBox(height: 12),
              _DrawerHeader(
                favoritesCount: favoritesCount,
                cartCount: cartCount,
                ordersCount: ordersCount,
              ),
              const SizedBox(height: 24),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const _MenuSectionTitle('Main'),
                      _MenuListTile(
                        icon: Icons.home_outlined,
                        label: 'Home',
                        onTap: () {
                          Navigator.of(context).pop();
                        },
                      ),
                      _MenuListTile(
                        icon: Icons.favorite_outline,
                        label: favoritesCount == 0
                            ? 'Favorites'
                            : 'Favorites ($favoritesCount)',
                        onTap: () {
                          Navigator.of(context).pop();
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => FavoritesPage(
                                favorites: favorites,
                                onToggleFavorite: onToggleFavorite,
                                allItems: allItems,
                              ),
                            ),
                          );
                        },
                      ),
                      _MenuListTile(
                        icon: Icons.shopping_bag_outlined,
                        label: cartCount == 0
                            ? 'My Cart'
                            : 'My Cart ($cartCount)',
                        onTap: () {
                          Navigator.of(context).pop();
                          onNavigateToCart();
                        },
                      ),
                      _MenuListTile(
                        icon: Icons.receipt_long_outlined,
                        label: ordersCount == 0
                            ? 'My Orders'
                            : 'My Orders ($ordersCount)',
                        onTap: () {
                          Navigator.of(context).pop();
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => MyOrdersPage(
                                orders: orders,
                                allItems: allItems,
                              ),
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 24),
                      const _MenuSectionTitle('Account'),
                      _MenuListTile(
                        icon: Icons.settings_outlined,
                        label: 'Settings',
                        onTap: () {
                          Navigator.of(context).pop();
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) =>
                                  Settings(onThemeChanged: onThemeChanged),
                            ),
                          );
                        },
                      ),
                      _MenuListTile(
                        icon: Icons.info_outline,
                        label: 'About',
                        onTap: () {
                          Navigator.of(context).pop();
                          _showAboutDialog(context);
                        },
                      ),
                      const SizedBox(height: 32),
                    ],
                  ),
                ),
              ),
              _DrawerFooter(),
            ],
          ),
        ),
      ),
    );
  }

  void _showAboutDialog(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        final Color primary = Theme.of(context).colorScheme.primary;
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          title: Row(
            children: [
              Icon(Icons.coffee, color: primary),
              const SizedBox(width: 12),
              const Text('About Coffee Shop'),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Text(
                'Welcome to our Coffee Shop app!',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 12),
              Text(
                'Discover the finest coffee blends, keep track of your favorites, and enjoy a premium coffee experience.',
                style: TextStyle(fontSize: 14),
              ),
              SizedBox(height: 16),
              Text(
                'Highlights',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text('- Curated coffee catalog'),
              Text('- Personal favorites list'),
              Text('- Cash on delivery checkout'),
              Text('- Reward points with every order'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'Close',
                style: TextStyle(color: primary, fontWeight: FontWeight.w600),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _DrawerHeader extends StatelessWidget {
  final int favoritesCount;
  final int cartCount;
  final int ordersCount;

  const _DrawerHeader({
    required this.favoritesCount,
    required this.cartCount,
    required this.ordersCount,
  });

  @override
  Widget build(BuildContext context) {
    final Color primary = Theme.of(context).colorScheme.primary;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(28),
          gradient: LinearGradient(
            colors: [primary, primary.withValues(alpha: 0.7)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: [
            BoxShadow(
              color: primary.withValues(alpha: 0.35),
              blurRadius: 24,
              offset: const Offset(0, 12),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 58,
                    height: 58,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Theme.of(
                        context,
                      ).colorScheme.surface.withValues(alpha: 0.86),
                    ),
                    child: Icon(
                      Icons.coffee,
                      size: 30,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text(
                          'Coffee Shop',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Your daily brew companion',
                          style: TextStyle(color: Colors.white70, fontSize: 13),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _StatChip(label: 'Favorites', value: favoritesCount),
                  _StatChip(label: 'Cart', value: cartCount),
                  _StatChip(label: 'Orders', value: ordersCount),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  final String label;
  final int value;

  const _StatChip({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          value.toString(),
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(color: Colors.white70, fontSize: 12),
        ),
      ],
    );
  }
}

class _MenuSectionTitle extends StatelessWidget {
  final String title;

  const _MenuSectionTitle(this.title);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.w700,
          color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
        ),
      ),
    );
  }
}

class _MenuListTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _MenuListTile({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final Color primary = Theme.of(context).colorScheme.primary;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface.withValues(alpha: 0.94),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).colorScheme.shadow.withValues(alpha: 0.06),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: primary.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(icon, color: primary, size: 22),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  label,
                  style: Theme.of(
                    context,
                  ).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600),
                ),
              ),
              Icon(
                Icons.chevron_right,
                color: Theme.of(
                  context,
                ).colorScheme.onSurface.withValues(alpha: 0.3),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DrawerFooter extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface.withValues(alpha: 0.9),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Theme.of(
                context,
              ).colorScheme.shadow.withValues(alpha: 0.05),
              blurRadius: 14,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          children: [
            Text(
              'Coffee Shop v1.0',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(
                  context,
                ).colorScheme.onSurface.withValues(alpha: 0.6),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '© 2024 Coffee Shop',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(
                  context,
                ).colorScheme.onSurface.withValues(alpha: 0.5),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
