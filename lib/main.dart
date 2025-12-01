import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'auth/login_page.dart';
import 'cart.dart';
import 'models/cart_item.dart';
import 'models/coffee_item.dart';
import 'models/order.dart';
import 'myhome.dart';
import 'profile.dart';
import 'services/api_service.dart';
import 'theme.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  ThemeMode _themeMode = ThemeMode.light;

  @override
  void initState() {
    super.initState();
    _loadThemeMode();
  }

  Future<void> _loadThemeMode() async {
    final prefs = await SharedPreferences.getInstance();
    final isDarkMode = prefs.getBool('darkMode') ?? false;
    setState(() {
      _themeMode = isDarkMode ? ThemeMode.dark : ThemeMode.light;
    });
  }

  void _onThemeChanged(bool isDark) {
    setState(() {
      _themeMode = isDark ? ThemeMode.dark : ThemeMode.light;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Coffee Shop',
      theme: AppTheme.theme,
      darkTheme: AppTheme.darkTheme,
      themeMode: _themeMode,
      debugShowCheckedModeBanner: false,
      home: AuthGate(onThemeChanged: _onThemeChanged),
    );
  }
}

class AuthGate extends StatefulWidget {
  final void Function(bool)? onThemeChanged;

  const AuthGate({super.key, this.onThemeChanged});

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  bool _isLoading = true;
  bool _isLoggedIn = false;

  @override
  void initState() {
    super.initState();
    _checkAuthState();
  }

  Future<void> _checkAuthState() async {
    final prefs = await SharedPreferences.getInstance();
    final loggedIn = prefs.getBool('isLoggedIn') ?? false;
    setState(() {
      _isLoggedIn = loggedIn;
      _isLoading = false;
    });
  }

  void _handleLoginSuccess() {
    setState(() {
      _isLoggedIn = true;
    });
  }

  void _handleLogout() {
    setState(() {
      _isLoggedIn = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    if (_isLoggedIn) {
      return MainPage(
        onLogout: _handleLogout,
        onThemeChanged: widget.onThemeChanged,
      );
    }
    return LoginPage(onLoginSuccess: _handleLoginSuccess);
  }
}

class MainPage extends StatefulWidget {
  const MainPage({super.key, required this.onLogout, this.onThemeChanged});

  final VoidCallback onLogout;
  final void Function(bool)? onThemeChanged;

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int _selectedIndex = 0;
  final List<CartItem> _cartItems = [];
  final Set<String> _favorites = <String>{};
  final List<Order> _orders = [];
  final ApiService _apiService = ApiService();

  List<CoffeeItem> _coffeeItems = [];
  bool _isLoadingCoffeeItems = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadCoffeeItems();
    _loadUserOrders();
  }

  @override
  void dispose() {
    _apiService.dispose();
    super.dispose();
  }

  /// Load coffee items from API
  Future<void> _loadCoffeeItems() async {
    setState(() {
      _isLoadingCoffeeItems = true;
      _errorMessage = null;
    });

    try {
      final items = await _apiService.getCoffeeItems();
      setState(() {
        _coffeeItems = items;
        _isLoadingCoffeeItems = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to load coffee items: ${e.toString()}';
        _isLoadingCoffeeItems = false;
      });
    }
  }

  /// Load user orders from API
  Future<void> _loadUserOrders() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getString('userId') ?? 'default_user';
      final orders = await _apiService.getUserOrders(userId);
      setState(() {
        _orders.clear();
        _orders.addAll(orders);
      });
    } catch (e) {
      // Silently fail for orders, as they might not exist yet
    }
  }

  void _addItemToCart(CoffeeItem item) {
    setState(() {
      final double price = double.parse(item.price.replaceAll('\$', ''));
      final int existingIndex = _cartItems.indexWhere(
        (e) => e.name == item.name && e.price == price,
      );
      if (existingIndex != -1) {
        _cartItems[existingIndex].quantity += 1;
      } else {
        _cartItems.add(CartItem(name: item.name, price: price, quantity: 1));
      }
    });
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  void _toggleFavorite(String name) {
    setState(() {
      if (_favorites.contains(name)) {
        _favorites.remove(name);
      } else {
        _favorites.add(name);
      }
    });
  }

  void _incrementItem(int index) {
    setState(() {
      _cartItems[index].quantity++;
    });
  }

  void _decrementItem(int index) {
    setState(() {
      if (_cartItems[index].quantity > 1) {
        _cartItems[index].quantity--;
      } else {
        _cartItems.removeAt(index);
      }
    });
  }

  void _removeItem(int index) {
    setState(() {
      _cartItems.removeAt(index);
    });
  }

  Future<void> _placeOrder() async {
    if (_cartItems.isEmpty) return;

    final total = _cartItems.fold(
      0.0,
      (sum, item) => sum + item.price * item.quantity,
    );

    // Show loading indicator
    if (!mounted) return;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    try {
      final order = await _apiService.placeOrder(
        items: List.from(_cartItems),
        totalAmount: total,
      );

      if (!mounted) return;
      Navigator.of(context).pop(); // Close loading dialog

      setState(() {
        _orders.add(order);
        _cartItems.clear();
        _selectedIndex = 0;
      });

      // Show success message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Order placed successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      Navigator.of(context).pop(); // Close loading dialog

      // Show error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to place order: ${e.toString()}'),
          backgroundColor: Colors.red,
          action: SnackBarAction(label: 'Retry', onPressed: _placeOrder),
        ),
      );
    }
  }

  void _clearCart() {
    setState(() {
      _cartItems.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(child: _buildPage(_selectedIndex)),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_cart),
            label: 'Cart',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }

  Widget _buildPage(int index) {
    // Show loading/error state for coffee items if needed
    if (_isLoadingCoffeeItems && _coffeeItems.isEmpty) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (_errorMessage != null && _coffeeItems.isEmpty) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              Text(
                _errorMessage!,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: _loadCoffeeItems,
                icon: const Icon(Icons.refresh),
                label: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    switch (index) {
      case 0:
        return MyHomePage(
          onAddToCart: _addItemToCart,
          favorites: _favorites,
          onToggleFavorite: _toggleFavorite,
          cartItems: _cartItems,
          onNavigateToCart: () => _onItemTapped(1),
          orders: _orders,
          coffeeItems: _coffeeItems,
          isLoading: _isLoadingCoffeeItems,
          onRefresh: _loadCoffeeItems,
          onThemeChanged: widget.onThemeChanged,
        );
      case 1:
        return MyCart(
          cartItems: _cartItems,
          coffeeItems: _coffeeItems,
          onIncrement: _incrementItem,
          onDecrement: _decrementItem,
          onRemove: _removeItem,
          onPlaceOrder: _placeOrder,
          onClearCart: _clearCart,
        );
      case 2:
      default:
        return MyProfile(
          favorites: _favorites.toList(growable: false),
          orders: _orders,
          allItems: _coffeeItems,
          onToggleFavorite: _toggleFavorite,
          onLogout: widget.onLogout,
        );
    }
  }
}
