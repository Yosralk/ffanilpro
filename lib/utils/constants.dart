import 'package:flutter/material.dart';

/// API (اختياري لو بدك REST)
const String kBaseUrl = "https://your-api.example.com";

/// Colors
const kPrimaryStart = Color(0xFF3450A1);
const kPrimaryEnd   = Color(0xFF041955);
const kPrimary      = Color(0xFF3450A1);
const kAccent       = Color(0xFF27AE60);

/// Layout
const kPadding = 20.0;

/// Gradients
const kHeaderGradient = LinearGradient(
  colors: [kPrimaryStart, kPrimaryEnd],
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
);

BoxDecoration curvedHeader() => const BoxDecoration(
  gradient: kHeaderGradient,
  borderRadius: BorderRadius.only(
    bottomLeft: Radius.circular(35),
    bottomRight: Radius.circular(35),
  ),
);

/// Theme
AppBarTheme appBarTheme() => const AppBarTheme(
  backgroundColor: kPrimary,
  elevation: 0,
  centerTitle: true,
  foregroundColor: Colors.white,
);

ThemeData buildTheme() {
  final scheme = ColorScheme.fromSeed(
    seedColor: kPrimary,
    primary: kPrimary,
    brightness: Brightness.light,
  );
  return ThemeData(
    colorScheme: scheme,
    useMaterial3: true,
    appBarTheme: appBarTheme(),
    inputDecorationTheme: InputDecorationTheme(
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.black12),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: kPrimary, width: 1.6),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: kPrimary,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        minimumSize: const Size.fromHeight(48),
      ),
    ),
  );
}
