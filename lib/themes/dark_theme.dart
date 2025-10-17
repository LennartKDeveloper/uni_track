import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

final darkTheme = ThemeData(
  primaryColor: Colors.white,
  scaffoldBackgroundColor: Colors.black, //

  colorScheme: ColorScheme.dark(
    primary: Colors.blue.shade200, //
    secondary: Colors.grey.shade900,
    shadow: Colors.black,
  ),
  textTheme: TextTheme(
    displayMedium: GoogleFonts.inter(
      fontSize: 18,
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
