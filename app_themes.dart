import 'package:flutter/material.dart';

class AppThemes {
  // Rounded shape
  static final OutlinedBorder _roundedShape = RoundedRectangleBorder(    borderRadius: BorderRadius.circular(30), // Increased from 12
  );

  // --- DARK THEME ---
  static final ThemeData darkTheme = ThemeData.dark().copyWith(
    primaryColor: Colors.green, // Main yellow
    indicatorColor: Colors.green,
    canvasColor: Colors.red, // Active borders
    scaffoldBackgroundColor: const Color(0xFF000000),
    cardColor: const Color(0xFF1C1C1E), // Box background
    disabledColor: const Color(0xFF2C2C2E),
    hintColor: Colors.grey[600],
    shadowColor: Colors.transparent,
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.transparent,
      elevation: 0,
      centerTitle: true,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.green, // Yellow button
        foregroundColor: Colors.black, // Black text
        shape: _roundedShape,
        padding: const EdgeInsets.symmetric(vertical: 14),
      ),
    ),
    cardTheme: CardThemeData(
      shape: _roundedShape,
      color: const Color(0xFF1C1C1E),
      elevation: 0,
    ),
    dialogBackgroundColor: const Color(0xFF1C1C1E),
    dialogTheme: DialogThemeData(shape: _roundedShape),
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      backgroundColor: const Color(0xFF1C1C1E),
      selectedItemColor: Colors.green,
      unselectedItemColor: const Color.fromARGB(255, 94, 94, 94),
      type: BottomNavigationBarType.fixed,
    ),
  );

  // --- LIGHT THEME ---
  static final ThemeData lightTheme = ThemeData.light().copyWith(
    primaryColor: Colors.green, // Main green
    indicatorColor: Colors.green, // "Red linings" for active borders
    canvasColor: Colors.red,
    scaffoldBackgroundColor: const Color.fromARGB(255, 231, 231, 231),
    cardColor: const Color(0xFFF5F5F5), // "Light shade" for boxes
    disabledColor: const Color(0xFFE0E0E0),
    hintColor: Colors.grey[700],
    shadowColor: Colors.grey.withOpacity(0.2), // Light shadow for boxes
    appBarTheme: const AppBarTheme(
      backgroundColor: Color.fromARGB(255, 216, 216, 216),
      elevation: 0,
      centerTitle: true,
      foregroundColor: Colors.black, // Black title
      iconTheme: IconThemeData(color: Colors.black), // Black icons
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.green, // Green button
        foregroundColor: Colors.white, // White text
        shape: _roundedShape,
        padding: const EdgeInsets.symmetric(vertical: 14),
      ),
    ),
    cardTheme: CardThemeData(
      shape: _roundedShape,
      color: const Color(0xFFF5F5F5),
      elevation: 0, // I'll use a shadow on containers instead
    ),
    dialogBackgroundColor: const Color.fromARGB(255, 205, 205, 205),
    dialogTheme: DialogThemeData(shape: _roundedShape),
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      backgroundColor: const Color.fromARGB(255, 192, 192, 192),
      selectedItemColor: Colors.green,
      unselectedItemColor: Color.fromARGB(255, 94, 94, 94),
      type: BottomNavigationBarType.fixed,
    ),
  );
}