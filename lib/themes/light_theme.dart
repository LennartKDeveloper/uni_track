import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

final lightTheme = ThemeData(
  brightness: Brightness.light,
  primaryColor: Colors.teal,
  scaffoldBackgroundColor: Colors.white,
  canvasColor: Colors.blue,

  colorScheme: ColorScheme.light(
    primary: Colors.blue,
    secondary: Colors.grey.shade600,
    surface: Colors.white,
    onPrimary: Colors.white,
    onSurface: Colors.black87,
    error: Colors.red.shade700,
    shadow: Colors.black.withOpacity(0.5),
    inverseSurface: Colors.white,
  ),

  cardColor: Colors.white,

  textTheme: TextTheme(
    displayMedium: GoogleFonts.inter(
      fontSize: 17,
      fontWeight: FontWeight.w400,
      color: Colors.black87,
    ),
    displayLarge: GoogleFonts.inter(
      fontSize: 23,
      fontWeight: FontWeight.w400,
      color: Colors.black87,
    ),
    labelMedium: GoogleFonts.inter(
      fontSize: 14,
      fontWeight: FontWeight.w400,
      color: Colors.grey.shade600,
    ),
  ),
);
