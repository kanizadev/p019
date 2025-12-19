import 'dart:ui';
import 'package:flutter/material.dart';
import 'recipe_list_screen.dart';
import 'favorites_screen.dart';
import 'add_edit_recipe_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  static const List<Widget> _widgetOptions = <Widget>[
    RecipeListScreen(),
    FavoritesScreen(),
  ];

  void _onItemTapped(int index) {
    if (index == 2) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const AddEditRecipeScreen()),
      ).then((result) {
        if (result != null) {
          // Recipe added, switch back to home
          setState(() {
            _selectedIndex = 0;
          });
        }
      });
    } else {
      setState(() {
        _selectedIndex = index;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: _widgetOptions.elementAt(_selectedIndex),
      extendBody: true,
      bottomNavigationBar: ClipRRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              border: Border(
                top: BorderSide(
                  color: Colors.white.withValues(alpha: 0.3),
                  width: 1,
                ),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 20,
                  offset: const Offset(0, -4),
                ),
              ],
            ),
            child: BottomNavigationBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              items: const <BottomNavigationBarItem>[
                BottomNavigationBarItem(
                  icon: Icon(Icons.home_outlined),
                  activeIcon: Icon(Icons.home),
                  label: 'Home',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.favorite_border),
                  activeIcon: Icon(Icons.favorite),
                  label: 'Favorite',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.add_circle_outline),
                  activeIcon: Icon(Icons.add_circle),
                  label: 'Add Recipe',
                ),
              ],
              currentIndex: _selectedIndex,
              selectedItemColor: Colors.white,
              unselectedItemColor: Colors.white.withValues(alpha: 0.7),
              selectedLabelStyle: const TextStyle(
                fontWeight: FontWeight.w600,
                shadows: [
                  Shadow(
                    offset: Offset(0, 1),
                    blurRadius: 4,
                    color: Colors.black26,
                  ),
                ],
              ),
              onTap: _onItemTapped,
            ),
          ),
        ),
      ),
    );
  }
}
