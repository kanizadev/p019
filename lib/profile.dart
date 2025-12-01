import 'package:flutter/material.dart';
import 'package:my_app/auth/edit_profile_page.dart';
import 'package:my_app/models/order.dart';
import 'package:my_app/models/coffee_item.dart';
import 'package:my_app/my_orders_page.dart';
import 'package:my_app/widgets/profile/header_card.dart';
import 'package:my_app/widgets/profile/stat_card.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:my_app/theme.dart';

class MyProfile extends StatefulWidget {
  const MyProfile({
    super.key,
    this.favorites = const [],
    required this.orders,
    required this.allItems,
    required this.onToggleFavorite,
    this.onLogout,
  });

  final List<String> favorites;
  final List<Order> orders;
  final List<CoffeeItem> allItems;
  final void Function(String) onToggleFavorite;
  final VoidCallback? onLogout;

  @override
  State<MyProfile> createState() => _MyProfileState();
}

class _MyProfileState extends State<MyProfile> {
  String userName = 'Sarah Johnson';
  String userEmail = 'sarah.johnson@email.com';
  String userPhone = '+1 (555) 123-4567';
  String userAddress = '123 Coffee Street, Cafe District';
  String memberSince = 'March 2023';

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      userName = prefs.getString('userName') ?? 'Sarah Johnson';
      userEmail = prefs.getString('userEmail') ?? 'sarah.johnson@email.com';
      userPhone = prefs.getString('userPhone') ?? '+1 (555) 123-4567';
      userAddress =
          prefs.getString('userAddress') ?? '123 Coffee Street, Cafe District';
      memberSince = prefs.getString('memberSince') ?? 'March 2023';
    });
  }

  /// Get the actual orders count from widget.orders
  int get userOrders => widget.orders.length;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    final int favoritesCount = widget.favorites.length;
    final String favoritesValue = favoritesCount > 0
        ? '$favoritesCount saved'
        : 'No favorites yet';

    // Get the latest favorite coffee item name if available
    String? latestFavoriteName;
    if (favoritesCount > 0 && widget.allItems.isNotEmpty) {
      final favoriteItem = widget.allItems.firstWhere(
        (item) => widget.favorites.contains(item.name),
        orElse: () => widget.allItems.first,
      );
      latestFavoriteName = favoriteItem.name;
    }

    final String favoritesDescription = latestFavoriteName != null
        ? 'Latest pick: $latestFavoriteName'
        : favoritesCount > 0
        ? 'You have $favoritesCount favorite${favoritesCount > 1 ? 's' : ''}'
        : 'Tap the heart icon to save drinks you love';

    final int recentOrdersCount = widget.orders.length;
    final String ordersValue = recentOrdersCount > 0
        ? '$recentOrdersCount orders'
        : 'No orders yet';
    final String ordersDescription = recentOrdersCount > 0
        ? 'Last order: ${widget.orders.first.dateText}'
        : 'Checkout to start tracking your history';

    // Calculate total spent from orders
    final double totalSpent = widget.orders.fold(
      0.0,
      (sum, order) => sum + order.amount,
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Profile'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () async {
              final updated = await Navigator.of(context)
                  .push<Map<String, String>?>(
                    MaterialPageRoute(
                      builder: (_) => EditProfilePage(
                        initialName: userName,
                        initialEmail: userEmail,
                        initialPhone: userPhone,
                        initialAddress: userAddress,
                      ),
                    ),
                  );

              if (updated != null) {
                final prefs = await SharedPreferences.getInstance();
                setState(() {
                  userName = updated['name'] ?? userName;
                  userEmail = updated['email'] ?? userEmail;
                  userPhone = updated['phone'] ?? userPhone;
                  userAddress = updated['address'] ?? userAddress;
                });
                await prefs.setString('userName', userName);
                await prefs.setString('userEmail', userEmail);
                await prefs.setString('userPhone', userPhone);
                await prefs.setString('userAddress', userAddress);
                if (!context.mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Profile updated')),
                );
              }
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              final prefs = await SharedPreferences.getInstance();
              await prefs.setBool('isLoggedIn', false);
              if (!context.mounted) return;
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Logged out successfully')),
              );
              widget.onLogout?.call();
            },
          ),
        ],
      ),
      body: Container(
        width: double.infinity,
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
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                HeaderCard(
                  primary: colorScheme.primary,
                  accent: colorScheme.secondary,
                  border: colorScheme.secondary.withValues(alpha: 0.4),
                  name: userName,
                  email: userEmail,
                  phone: userPhone,
                  address: userAddress,
                  ordersCount: userOrders,
                  memberSince: memberSince,
                ),
                const SizedBox(height: 24),
                _buildSectionTitle(
                  context,
                  'Highlights',
                  Icons.insights_outlined,
                ),
                const SizedBox(height: 12),
                LayoutBuilder(
                  builder: (context, constraints) {
                    final bool isNarrow = constraints.maxWidth < 600;
                    final double cardWidth = isNarrow
                        ? constraints.maxWidth
                        : (constraints.maxWidth - 32) / 3;

                    return Wrap(
                      spacing: 16,
                      runSpacing: 16,
                      children: [
                        SizedBox(
                          width: cardWidth,
                          child: StatCard(
                            icon: Icons.favorite,
                            title: 'Favorites',
                            value: favoritesValue,
                            description: favoritesDescription,
                            accentColor: colorScheme.secondary,
                          ),
                        ),
                        SizedBox(
                          width: cardWidth,
                          child: InkWell(
                            onTap: recentOrdersCount > 0
                                ? () {
                                    Navigator.of(context).push(
                                      MaterialPageRoute(
                                        builder: (_) => MyOrdersPage(
                                          orders: widget.orders,
                                          allItems: widget.allItems,
                                        ),
                                      ),
                                    );
                                  }
                                : null,
                            borderRadius: BorderRadius.circular(18),
                            child: StatCard(
                              icon: Icons.local_cafe,
                              title: 'Orders',
                              value: ordersValue,
                              description: ordersDescription,
                              accentColor: colorScheme.primary,
                            ),
                          ),
                        ),
                        if (totalSpent > 0)
                          SizedBox(
                            width: cardWidth,
                            child: StatCard(
                              icon: Icons.payments,
                              title: 'Total Spent',
                              value: '\$${totalSpent.toStringAsFixed(2)}',
                              description: 'Across all orders',
                              accentColor: colorScheme.secondary,
                            ),
                          ),
                      ],
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title, IconData icon) {
    final Color accentColor = Theme.of(context).colorScheme.primary;
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: accentColor.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, size: 18, color: accentColor),
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
