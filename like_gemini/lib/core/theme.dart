import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Background Colors
  static const Color backgroundColor = Color(0xFF090A0F);
  static const Color surfaceColor = Color(0xFF13141F);
  static const Color glassColor = Color(0x0DFFFFFF); // 5% white opacity
  static const Color glassBorderColor = Color(0x1AFFFFFF); // 10% white opacity
  
  // Accent Colors
  static const Color cyanAccent = Color(0xFF00F2FE);
  static const Color purpleAccent = Color(0xFF9B51E0);
  
  // Gradients
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [cyanAccent, purpleAccent],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );

  static const LinearGradient borderGradient = LinearGradient(
    colors: [
      Color(0x3300F2FE), // 20% Cyan
      Color(0x339B51E0), // 20% Purple
    ],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static ThemeData get darkTheme {
    return ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: backgroundColor,
      primaryColor: cyanAccent,
      colorScheme: const ColorScheme.dark(
        surface: surfaceColor,
        primary: cyanAccent,
        secondary: purpleAccent,
        onSurface: Colors.white,
      ),
      useMaterial3: true,
      textTheme: TextTheme(
        // Space Grotesk for Headers
        displayLarge: GoogleFonts.spaceGrotesk(
          fontSize: 64,
          fontWeight: FontWeight.bold,
          color: Colors.white,
          letterSpacing: -1.5,
        ),
        displayMedium: GoogleFonts.spaceGrotesk(
          fontSize: 48,
          fontWeight: FontWeight.bold,
          color: Colors.white,
          letterSpacing: -1.0,
        ),
        displaySmall: GoogleFonts.spaceGrotesk(
          fontSize: 36,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
        headlineMedium: GoogleFonts.spaceGrotesk(
          fontSize: 28,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
        headlineSmall: GoogleFonts.spaceGrotesk(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
        titleLarge: GoogleFonts.spaceGrotesk(
          fontSize: 18,
          fontWeight: FontWeight.w500,
          color: Colors.white,
        ),
        // Inter for Body and Buttons
        bodyLarge: GoogleFonts.inter(
          fontSize: 16,
          fontWeight: FontWeight.normal,
          color: Colors.white.withValues(alpha: 0.85),
          height: 1.5,
        ),
        bodyMedium: GoogleFonts.inter(
          fontSize: 14,
          fontWeight: FontWeight.normal,
          color: Colors.white.withValues(alpha: 0.7),
          height: 1.5,
        ),
        labelLarge: GoogleFonts.inter(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: Colors.white,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}
