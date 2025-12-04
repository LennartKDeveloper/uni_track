import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

final ThemeData darkTheme = ThemeData(
  brightness: Brightness.dark,
  primaryColor: Colors.blue.shade200,
  scaffoldBackgroundColor: const Color(0xFF0B0D0F),
  canvasColor: Colors.grey.shade900,

  colorScheme: ColorScheme.dark(
    primary: Colors.blue.shade200,
    secondary: Colors.teal.shade200,
    surface: const Color(0xFF111315),
    onPrimary: Colors.black87,
    onSurface: Colors.white70,
    error: Colors.redAccent.shade200,
    shadow: Colors.black,
    inverseSurface: Colors.grey.shade300,
  ),

  cardColor: const Color(0xFF121416),

  textTheme: TextTheme(
    displayMedium: GoogleFonts.inter(
      fontSize: 18,
      fontWeight: FontWeight.w500,
      color: Colors.white70,
    ),
    displayLarge: GoogleFonts.inter(
      fontSize: 20,
      fontWeight: FontWeight.w500,
      color: Colors.white,
    ),
    labelMedium: GoogleFonts.inter(
      fontSize: 14,
      fontWeight: FontWeight.w400,
      color: Colors.white60,
    ),
  ),
);
