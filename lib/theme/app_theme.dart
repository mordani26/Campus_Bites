import 'package:flutter/material.dart';

// handles light and dark theme styling for the app
class AppTheme {
  // light theme design
  static ThemeData get lightTheme {
    // main colors used in the app
    const Color seedColor = Color(0xFFE67E22);
    const Color backgroundColor = Color(0xFFF7F4F1);
    const Color cardColor = Colors.white;
    const Color textColor = Color(0xFF2D2A26);

    return ThemeData(
      useMaterial3: true,

      // generates color scheme based on seed color
      colorScheme: ColorScheme.fromSeed(
        seedColor: seedColor,
        brightness: Brightness.light,
      ),

      // background and card styling
      scaffoldBackgroundColor: backgroundColor,
      cardColor: cardColor,

      // app bar style
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.white,
        foregroundColor: textColor,
        centerTitle: true,
        elevation: 0,
      ),

      // bottom navigation bar styling
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: Colors.white,
        indicatorColor: seedColor.withAlpha(45),

        // text style for selected and unselected tabs
        labelTextStyle: WidgetStateProperty.resolveWith<TextStyle?>((states) {
          if (states.contains(WidgetState.selected)) {
            return const TextStyle(
              color: seedColor,
              fontWeight: FontWeight.w600,
            );
          }
          return const TextStyle(
            color: Colors.black54,
            fontWeight: FontWeight.w500,
          );
        }),

        // icon colors
        iconTheme: WidgetStateProperty.resolveWith<IconThemeData?>((states) {
          if (states.contains(WidgetState.selected)) {
            return const IconThemeData(color: seedColor);
          }
          return const IconThemeData(color: Colors.black54);
        }),
      ),

      // card style used across app
      cardTheme: CardThemeData(
        color: cardColor,
        elevation: 2,
        shadowColor: Colors.black.withAlpha(20),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        margin: EdgeInsets.zero,
      ),

      // input fields styling (text fields)
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        labelStyle: const TextStyle(color: Colors.black87),

        // borders for input fields
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xFFD9D2CB)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xFFD9D2CB)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: seedColor, width: 1.5),
        ),
      ),

      // button styling
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: seedColor,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      ),

      // snackbar (messages) style
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: const Color(0xFF2D2A26),
        contentTextStyle: const TextStyle(color: Colors.white),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),

      // text styles used in app
      textTheme: const TextTheme(
        headlineSmall: TextStyle(color: textColor, fontWeight: FontWeight.w700),
        titleLarge: TextStyle(color: textColor, fontWeight: FontWeight.w700),
        bodyLarge: TextStyle(color: textColor),
        bodyMedium: TextStyle(color: Colors.black87),
      ),
    );
  }

  // dark theme design
  static ThemeData get darkTheme {
    const Color seedColor = Color(0xFFE67E22);
    const Color backgroundColor = Color(0xFF181614);
    const Color cardColor = Color(0xFF24211E);
    const Color textColor = Color(0xFFF5EFE8);

    return ThemeData(
      useMaterial3: true,

      // dark color scheme
      colorScheme: ColorScheme.fromSeed(
        seedColor: seedColor,
        brightness: Brightness.dark,
      ),

      // dark background
      scaffoldBackgroundColor: backgroundColor,
      cardColor: cardColor,

      // app bar styling
      appBarTheme: const AppBarTheme(
        backgroundColor: Color(0xFF181614),
        foregroundColor: textColor,
        centerTitle: true,
        elevation: 0,
      ),

      // navigation bar styling
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: const Color(0xFF1F1C19),
        indicatorColor: seedColor.withAlpha(55),

        labelTextStyle: WidgetStateProperty.resolveWith<TextStyle?>((states) {
          if (states.contains(WidgetState.selected)) {
            return const TextStyle(
              color: seedColor,
              fontWeight: FontWeight.w600,
            );
          }
          return const TextStyle(
            color: Colors.white70,
            fontWeight: FontWeight.w500,
          );
        }),

        iconTheme: WidgetStateProperty.resolveWith<IconThemeData?>((states) {
          if (states.contains(WidgetState.selected)) {
            return const IconThemeData(color: seedColor);
          }
          return const IconThemeData(color: Colors.white70);
        }),
      ),

      // card style for dark mode
      cardTheme: CardThemeData(
        color: cardColor,
        elevation: 2,
        shadowColor: Colors.black.withAlpha(40),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        margin: EdgeInsets.zero,
      ),

      // input field styling for dark mode
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFF2A2622),
        labelStyle: const TextStyle(color: Colors.white70),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xFF4A433D)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xFF4A433D)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: seedColor, width: 1.5),
        ),
      ),

      // button styling for dark mode
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: seedColor,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      ),

      // snackbar styling for dark mode
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: const Color(0xFFF5EFE8),
        contentTextStyle: const TextStyle(color: Colors.black87),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),

      // list tile colors
      listTileTheme: const ListTileThemeData(
        textColor: textColor,
        iconColor: Colors.white70,
      ),

      // text styling for dark mode
      textTheme: const TextTheme(
        headlineSmall: TextStyle(color: textColor, fontWeight: FontWeight.w700),
        titleLarge: TextStyle(color: textColor, fontWeight: FontWeight.w700),
        bodyLarge: TextStyle(color: textColor),
        bodyMedium: TextStyle(color: Colors.white70),
      ),
    );
  }
}
