import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Sage green inspired palette
  static const Color primary = Color(0xFF7A9E7E); // Sage green
  static const Color secondary = Color(0xFFA8C686); // Soft sage
  static const Color accent = Color(0xFFC7D9B7); // Misty sage
  static const Color background = Color(0xFFF5F7F0); // Light sage wash
  static const Color surface = Color(0xFFE9F1E0); // Pale clover
  static const Color textDark = Color(0xFF3D4A3F); // Deep woodland
  static const Color textLight = Color(0xFF6E7C6B); // Muted sage
  static const Color success = Color(0xFF8CB08B); // Vibrant sage
  static const Color error = Color(0xFF6F7A64); // Dusky sage

  // Dark mode colors
  static const Color darkBackground = Color(0xFF1A1F1B); // Dark sage
  static const Color darkSurface = Color(0xFF242A25); // Darker sage
  static const Color darkTextLight = Color(0xFFE5E8E6); // Light text
  static const Color darkTextDark = Color(0xFFB8C4BA); // Muted light text

  static ThemeData get theme {
    final baseTextTheme = GoogleFonts.latoTextTheme();
    final ColorScheme colorScheme = ColorScheme.light(
      primary: primary,
      onPrimary: Colors.white,
      secondary: secondary,
      onSecondary: textDark,
      tertiary: accent,
      onTertiary: textDark,
      surface: surface,
      onSurface: textDark,
      error: error,
      onError: Colors.white,
      surfaceTint: primary,
      primaryContainer: primary.withValues(alpha: 0.8),
      onPrimaryContainer: textDark,
      secondaryContainer: secondary.withValues(alpha: 0.9),
      onSecondaryContainer: textDark,
      outline: textDark.withValues(alpha: 0.25),
    );

    final TextTheme textTheme = baseTextTheme.copyWith(
      displayLarge: GoogleFonts.playfairDisplay(
        fontSize: 36,
        fontWeight: FontWeight.w800,
        color: textDark,
      ),
      headlineSmall: GoogleFonts.playfairDisplay(
        fontSize: 26,
        fontWeight: FontWeight.w700,
        color: textDark,
      ),
      titleLarge: GoogleFonts.lato(
        fontSize: 20,
        fontWeight: FontWeight.w700,
        color: textDark,
      ),
      titleMedium: GoogleFonts.lato(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: textDark,
      ),
      bodyLarge: GoogleFonts.lato(
        fontSize: 16,
        fontWeight: FontWeight.w500,
        color: textDark,
      ),
      bodyMedium: GoogleFonts.lato(
        fontSize: 14,
        color: textDark.withValues(alpha: 0.8),
      ),
      labelLarge: GoogleFonts.lato(
        fontWeight: FontWeight.w600,
        color: textDark,
      ),
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      primaryColor: primary,
      scaffoldBackgroundColor: background,
      canvasColor: background,
      visualDensity: VisualDensity.adaptivePlatformDensity,
      textTheme: textTheme,
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        foregroundColor: textDark,
        systemOverlayStyle: SystemUiOverlayStyle.dark,
        titleTextStyle: textTheme.titleLarge,
        actionsIconTheme: const IconThemeData(color: textDark),
        iconTheme: const IconThemeData(color: textDark),
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: Colors.white.withValues(alpha: 0.95),
        elevation: 8,
        selectedItemColor: primary,
        unselectedItemColor: textDark.withValues(alpha: 0.45),
        selectedLabelStyle: textTheme.labelLarge,
        unselectedLabelStyle: textTheme.labelLarge,
        type: BottomNavigationBarType.fixed,
        showUnselectedLabels: true,
      ),
      cardTheme: CardThemeData(
        color: Colors.white.withValues(alpha: 0.95),
        shadowColor: textDark.withValues(alpha: 0.08),
        elevation: 4,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
        margin: EdgeInsets.zero,
      ),
      chipTheme: ChipThemeData(
        backgroundColor: Colors.white.withValues(alpha: 0.95),
        disabledColor: Colors.grey.shade300,
        selectedColor: primary,
        secondarySelectedColor: primary.withValues(alpha: 0.8),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        labelStyle: textTheme.labelLarge?.copyWith(color: textDark),
        secondaryLabelStyle: textTheme.labelLarge?.copyWith(
          color: Colors.white,
        ),
        brightness: Brightness.light,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        elevation: 0,
        pressElevation: 0,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide(color: primary.withValues(alpha: 0.28)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide(color: primary.withValues(alpha: 0.28)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide(color: primary, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 16,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: Colors.white,
          shadowColor: primary.withValues(alpha: 0.35),
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          textStyle: textTheme.labelLarge,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          side: BorderSide(color: primary.withValues(alpha: 0.45), width: 1.2),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          textStyle: textTheme.labelLarge,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: primary,
          textStyle: textTheme.labelLarge,
        ),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: secondary,
        foregroundColor: textDark,
        elevation: 6,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: textDark,
        actionTextColor: Colors.white,
        behavior: SnackBarBehavior.floating,
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        contentTextStyle: textTheme.bodyMedium?.copyWith(color: Colors.white),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        titleTextStyle: textTheme.titleLarge,
        contentTextStyle: textTheme.bodyMedium,
      ),
      listTileTheme: ListTileThemeData(
        iconColor: primary,
        textColor: textDark,
        tileColor: Colors.white.withValues(alpha: 0.95),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      dividerTheme: DividerThemeData(
        color: textDark.withValues(alpha: 0.1),
        space: 24,
        thickness: 1,
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      ),
    );
  }

  static ThemeData get darkTheme {
    final baseTextTheme = GoogleFonts.latoTextTheme(ThemeData.dark().textTheme);
    final ColorScheme colorScheme = ColorScheme.dark(
      primary: primary,
      onPrimary: Colors.white,
      secondary: secondary,
      onSecondary: darkTextLight,
      tertiary: accent,
      onTertiary: darkTextLight,
      surface: darkSurface,
      onSurface: darkTextLight,
      error: error,
      onError: Colors.white,
      surfaceTint: primary,
      primaryContainer: primary.withValues(alpha: 0.3),
      onPrimaryContainer: darkTextLight,
      secondaryContainer: secondary.withValues(alpha: 0.3),
      onSecondaryContainer: darkTextLight,
      outline: darkTextDark.withValues(alpha: 0.3),
      brightness: Brightness.dark,
    );

    final TextTheme textTheme = baseTextTheme.copyWith(
      displayLarge: GoogleFonts.playfairDisplay(
        fontSize: 36,
        fontWeight: FontWeight.w800,
        color: darkTextLight,
      ),
      headlineSmall: GoogleFonts.playfairDisplay(
        fontSize: 26,
        fontWeight: FontWeight.w700,
        color: darkTextLight,
      ),
      titleLarge: GoogleFonts.lato(
        fontSize: 20,
        fontWeight: FontWeight.w700,
        color: darkTextLight,
      ),
      titleMedium: GoogleFonts.lato(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: darkTextLight,
      ),
      bodyLarge: GoogleFonts.lato(
        fontSize: 16,
        fontWeight: FontWeight.w500,
        color: darkTextLight,
      ),
      bodyMedium: GoogleFonts.lato(fontSize: 14, color: darkTextDark),
      labelLarge: GoogleFonts.lato(
        fontWeight: FontWeight.w600,
        color: darkTextLight,
      ),
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      primaryColor: primary,
      scaffoldBackgroundColor: darkBackground,
      canvasColor: darkBackground,
      visualDensity: VisualDensity.adaptivePlatformDensity,
      textTheme: textTheme,
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        foregroundColor: darkTextLight,
        systemOverlayStyle: SystemUiOverlayStyle.light,
        titleTextStyle: textTheme.titleLarge,
        actionsIconTheme: const IconThemeData(color: darkTextLight),
        iconTheme: const IconThemeData(color: darkTextLight),
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: darkSurface,
        elevation: 8,
        selectedItemColor: primary,
        unselectedItemColor: darkTextDark,
        selectedLabelStyle: textTheme.labelLarge,
        unselectedLabelStyle: textTheme.labelLarge,
        type: BottomNavigationBarType.fixed,
        showUnselectedLabels: true,
      ),
      cardTheme: CardThemeData(
        color: darkSurface,
        shadowColor: Colors.black.withValues(alpha: 0.5),
        elevation: 4,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
        margin: EdgeInsets.zero,
      ),
      chipTheme: ChipThemeData(
        backgroundColor: darkSurface,
        disabledColor: Colors.grey.shade700,
        selectedColor: primary,
        secondarySelectedColor: primary.withValues(alpha: 0.5),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        labelStyle: textTheme.labelLarge?.copyWith(color: darkTextLight),
        secondaryLabelStyle: textTheme.labelLarge?.copyWith(
          color: Colors.white,
        ),
        brightness: Brightness.dark,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        elevation: 0,
        pressElevation: 0,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: darkSurface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide(color: primary.withValues(alpha: 0.4)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide(color: darkTextDark.withValues(alpha: 0.3)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide(color: primary, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 16,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: Colors.white,
          shadowColor: primary.withValues(alpha: 0.5),
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          textStyle: textTheme.labelLarge,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          side: BorderSide(color: primary.withValues(alpha: 0.6), width: 1.2),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          textStyle: textTheme.labelLarge,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: primary,
          textStyle: textTheme.labelLarge,
        ),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: secondary,
        foregroundColor: darkTextLight,
        elevation: 6,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: darkSurface,
        actionTextColor: primary,
        behavior: SnackBarBehavior.floating,
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        contentTextStyle: textTheme.bodyMedium?.copyWith(color: darkTextLight),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: darkSurface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        titleTextStyle: textTheme.titleLarge,
        contentTextStyle: textTheme.bodyMedium,
      ),
      listTileTheme: ListTileThemeData(
        iconColor: primary,
        textColor: darkTextLight,
        tileColor: darkSurface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      dividerTheme: DividerThemeData(
        color: darkTextDark.withValues(alpha: 0.2),
        space: 24,
        thickness: 1,
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: darkSurface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      ),
    );
  }
}
