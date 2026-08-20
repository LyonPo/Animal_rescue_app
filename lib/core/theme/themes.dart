import 'package:flutter/material.dart';

class AppThemes {
  // LIGHT THEME
  static final lightTheme = ThemeData(
    brightness: Brightness.light,

    primarySwatch: Colors.red,

    scaffoldBackgroundColor: Colors.white,

    appBarTheme: const AppBarTheme(
      centerTitle: true,

      elevation: 0,

      titleTextStyle: TextStyle(
        fontSize: 22,

        fontWeight: FontWeight.bold,

        color: Colors.black,
      ),
    ),

    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: Colors.red,
    ),

    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      selectedItemColor: Colors.red,
    ),
  );

  // DARK THEME
  static final darkTheme = ThemeData(
    brightness: Brightness.dark,

    primarySwatch: Colors.red,

    scaffoldBackgroundColor: const Color(0xFF121212),

    appBarTheme: const AppBarTheme(
      centerTitle: true,

      elevation: 0,

      titleTextStyle: TextStyle(
        fontSize: 22,

        fontWeight: FontWeight.bold,

        color: Colors.white,
      ),
    ),

    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: Colors.red,
    ),

    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      selectedItemColor: Colors.red,
    ),
  );
}
