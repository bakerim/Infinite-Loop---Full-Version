import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

class AppTheme {
  static ThemeData get darkTheme {
    return ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: AppColors.backgroundDark,
      primaryColor: AppColors.neonCyan,
      
      // Font Ailesi Tanımları
      textTheme: TextTheme(
        displayLarge: GoogleFonts.orbitron(
          fontSize: 32, fontWeight: FontWeight.bold, color: Colors.white
        ),
        displayMedium: GoogleFonts.orbitron(
          fontSize: 24, fontWeight: FontWeight.w600, color: Colors.white
        ),
        bodyLarge: GoogleFonts.rajdhani(
          fontSize: 18, fontWeight: FontWeight.w500, color: Colors.white70
        ),
        bodyMedium: GoogleFonts.rajdhani(
          fontSize: 14, fontWeight: FontWeight.w400, color: Colors.white60
        ),
      ),
      
      // Renk Şeması
      colorScheme: const ColorScheme.dark(
        primary: AppColors.neonCyan,
        secondary: AppColors.neonMagenta,
        surface: AppColors.surfaceDark,
      ),
    );
  }
}