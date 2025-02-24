import 'package:flutter/material.dart';

class LetHimCookTheme {
  // ---------------------------
  // Dark Theme Colors
  // ---------------------------
  static const Color darkTextColor = Color(0xFFFFFFFF); // #FFFFFF Text
  static const Color darkTitleColor = Color(0xFFFFFFFF); // #FFFFFF Titles
  static const Color darkPrimaryColor = Color(0xFF9E7EF9); // #9E7EF9 Primary
  static const Color darkSecondaryColor =
      Color(0xFF383838); // #383838 Secondary
  static const Color darkTetriaryColor = Color(0xFFFFFFFF); // #FFFFFF Tetriary
  static const Color darkBorderColor = Color(0xFF222222); // #222222 Borders
  static const Color darkCardColor = Color(0xFF111111); // #111111 Card
  static const Color darkBackgroundColor =
      Color(0xFF000000); // #000000 Background

  // ---------------------------
  // Light Theme Colors
  // ---------------------------
  static const Color lightTextColor = Color(0xFF535465); // #535465 Text
  static const Color lightTitleColor = Color(0xFF11142D); // #11142D Titles
  static const Color lightPrimaryColor = Color(0xFF6C5DD3); // #6C5DD3 Primary
  static const Color lightSecondaryColor =
      Color(0xFF1B1D21); // #1B1D21 Secondary
  static const Color lightTetriaryColor = Color(0xFFB8DCE9); // #B8DCE9 Tetriary
  static const Color lightBorderColor = Color(0xFFE4E4E4); // #E4E4E4 Borders
  static const Color lightCardColor = Color(0xFFFFFFFF); // #FFFFFF Card
  static const Color lightBackgroundColor =
      Color(0xFFF6F6F8); // #F6F6F8 Background

  // ---------------------------
  // Dark Theme Definition
  // ---------------------------
  static final ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    primaryColor: darkPrimaryColor,
    scaffoldBackgroundColor: darkBackgroundColor,
    cardColor: darkCardColor,
    dividerColor: darkBorderColor,
    textTheme: const TextTheme(
      displayLarge:
          TextStyle(color: darkTitleColor, fontWeight: FontWeight.bold),
      displayMedium:
          TextStyle(color: darkTitleColor, fontWeight: FontWeight.bold),
      displaySmall:
          TextStyle(color: darkTitleColor, fontWeight: FontWeight.bold),
      headlineMedium:
          TextStyle(color: darkTitleColor, fontWeight: FontWeight.bold),
      headlineSmall:
          TextStyle(color: darkTitleColor, fontWeight: FontWeight.bold),
      titleLarge: TextStyle(color: darkTitleColor, fontWeight: FontWeight.bold),
      bodyLarge: TextStyle(color: darkTextColor),
      bodyMedium: TextStyle(color: darkTextColor),
      titleMedium: TextStyle(color: darkTextColor),
      titleSmall: TextStyle(color: darkTextColor),
      labelLarge: TextStyle(color: darkTextColor),
      bodySmall: TextStyle(color: darkTextColor),
      labelSmall: TextStyle(color: darkTextColor),
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: darkCardColor,
      iconTheme: IconThemeData(color: darkTextColor),
      titleTextStyle: TextStyle(
        color: darkTitleColor,
        fontSize: 20.0,
        fontWeight: FontWeight.bold,
      ),
    ),
    buttonTheme: const ButtonThemeData(
      buttonColor: darkPrimaryColor,
      textTheme: ButtonTextTheme.primary,
    ),
    colorScheme: const ColorScheme.dark(
      primary: darkPrimaryColor,
      secondary: darkSecondaryColor,
      surface: darkCardColor,
      error: Colors.red,
      onPrimary: darkTextColor,
      onSecondary: darkTextColor,
      onSurface: darkTextColor,
      onError: darkTextColor,
    ).copyWith(surface: darkBackgroundColor),
  );

  // ---------------------------
  // Light Theme Definition
  // ---------------------------
  static final ThemeData lightTheme = ThemeData(
      brightness: Brightness.light,
      primaryColor: lightPrimaryColor,
      scaffoldBackgroundColor: lightBackgroundColor,
      cardColor: lightCardColor,
      dividerColor: lightBorderColor,
      textTheme: const TextTheme(
        displayLarge:
            TextStyle(color: lightTitleColor, fontWeight: FontWeight.bold),
        displayMedium:
            TextStyle(color: lightTitleColor, fontWeight: FontWeight.bold),
        displaySmall:
            TextStyle(color: lightTitleColor, fontWeight: FontWeight.bold),
        headlineMedium:
            TextStyle(color: lightTitleColor, fontWeight: FontWeight.bold),
        headlineSmall:
            TextStyle(color: lightTitleColor, fontWeight: FontWeight.bold),
        titleLarge:
            TextStyle(color: lightTitleColor, fontWeight: FontWeight.bold),
        bodyLarge: TextStyle(color: lightTextColor),
        bodyMedium: TextStyle(color: lightTextColor),
        titleMedium: TextStyle(color: lightTextColor),
        titleSmall: TextStyle(color: lightTextColor),
        labelLarge: TextStyle(color: lightTextColor),
        bodySmall: TextStyle(color: lightTextColor),
        labelSmall: TextStyle(color: lightTextColor),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: lightCardColor,
        iconTheme: IconThemeData(color: lightTextColor),
        titleTextStyle: TextStyle(
          color: lightTitleColor,
          fontSize: 20.0,
          fontWeight: FontWeight.bold,
        ),
      ),
      buttonTheme: const ButtonThemeData(
        buttonColor: lightPrimaryColor,
        textTheme: ButtonTextTheme.primary,
      ),
      colorScheme: const ColorScheme.light(
        primary: lightPrimaryColor,
        secondary: lightSecondaryColor,
        surface: lightCardColor,
        error: Colors.red,
        onPrimary: lightTextColor,
        onSecondary: lightTextColor,
        onSurface: lightTextColor,
        onError: lightTextColor,
      ).copyWith(surface: lightBackgroundColor),
      inputDecorationTheme: const InputDecorationTheme(
        labelStyle: TextStyle(color: lightPrimaryColor),
        enabledBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: lightPrimaryColor),
        ),
        focusedBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: lightTitleColor),
        ),
      ));
}
