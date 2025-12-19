import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'screens/main_screen.dart';

void main() {
  runApp(const RecipeApp());
}

class RecipeApp extends StatelessWidget {
  const RecipeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Recipe App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF87A96B), // Sage green
          brightness: Brightness.light,
        ),
        useMaterial3: true,
        textTheme: GoogleFonts.poppinsTextTheme(),
        cardTheme: CardThemeData(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
        ),
        scaffoldBackgroundColor: Colors.transparent,
      ),
      home: const GlassyBackground(child: MainScreen()),
    );
  }
}

/// Glassy background with sage green gradient
class GlassyBackground extends StatelessWidget {
  final Widget child;

  const GlassyBackground({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFF9CAF88), // Sage green light
            const Color(0xFF87A96B), // Sage green
            const Color(0xFF6B8E5A), // Dark sage green
            const Color(0xFF5A7A4A), // Deeper sage
          ],
          stops: const [0.0, 0.4, 0.7, 1.0],
        ),
      ),
      child: Stack(
        children: [
          // Animated background elements for depth
          Positioned(
            top: -100,
            left: -100,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    const Color(0xFF87A96B).withValues(alpha: 0.3),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            bottom: -150,
            right: -150,
            child: Container(
              width: 400,
              height: 400,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    const Color(0xFF6B8E5A).withValues(alpha: 0.25),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          child,
        ],
      ),
    );
  }
}
