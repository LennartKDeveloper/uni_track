import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

final lightTheme = ThemeData(
  primaryColor: Colors.teal,
  scaffoldBackgroundColor: Colors.white,

  colorScheme: ColorScheme.light(
    primary: Colors.blue,
    secondary: Colors.grey.shade600,
    shadow: Colors.black.withOpacity(0.5),
  ),
  textTheme: TextTheme(
    displayMedium: GoogleFonts.inter(
      fontSize: 16,
      fontWeight: FontWeight.w500,
      color: Colors.black87,
    ),
    displayLarge: GoogleFonts.inter(
      fontSize: 20,
      fontWeight: FontWeight.w500,
      color: Colors.black87,
    ),
    labelMedium: GoogleFonts.inter(
      fontSize: 14,
      fontWeight: FontWeight.w400,
      color: Colors.grey.shade600,
    ),
  ),
);
