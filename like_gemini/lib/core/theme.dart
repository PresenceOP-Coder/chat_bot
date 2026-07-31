import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// PaperMind editorial design system.
/// Light mode: warm cream + ink contrast + golden amber accent.
/// Dark mode:  charcoal panels + same amber accent.
class AppTheme {
  AppTheme._();

  // ── Palette ────────────────────────────────────────────────
  static const Color amberAccent   = Color(0xFFF5A623); // golden amber
  static const Color amberLight    = Color(0xFFFFF3D6); // very pale amber tint

  // Light mode
  static const Color bgLight       = Color(0xFFF5F0E8); // warm cream canvas
  static const Color surfaceLight  = Color(0xFFFFFFFF); // white card
  static const Color surface2Light = Color(0xFFFAF7F2); // off-white card
  static const Color borderLight   = Color(0xFFE8E0D4); // warm gray border
  static const Color textPrimaryL  = Color(0xFF1A1A1A); // near-black
  static const Color textSecondaryL= Color(0xFF6B6560); // warm gray
  static const Color textMutedL    = Color(0xFF9E988F); // muted gray
  static const Color userBubbleL   = Color(0xFFF0EBE1); // slightly deeper cream
  static const Color botBubbleL    = Color(0xFFFFF8ED); // amber-tinted white

  // Dark mode
  static const Color bgDark        = Color(0xFF111111); // near-black
  static const Color surfaceDark   = Color(0xFF1E1E1E); // dark card
  static const Color surface2Dark  = Color(0xFF272727); // slightly lighter card
  static const Color borderDark    = Color(0xFF333333); // subtle dark border
  static const Color textPrimaryD  = Color(0xFFF0EDE8); // warm off-white
  static const Color textSecondaryD= Color(0xFF9E988F); // warm gray
  static const Color textMutedD    = Color(0xFF666666); // muted dark
  static const Color userBubbleDk  = Color(0xFF2A2A2A); // user bubble dark
  static const Color botBubbleDk   = Color(0xFF1E1B17); // bot bubble dark amber tint

  // Backward compatibility aliases
  static const Color backgroundColor = bgDark;
  static const Color cardColor = surfaceDark;
  static const Color primaryColor = amberAccent;

  // ── Shared ─────────────────────────────────────────────────
  static const Color cyanAccent    = Color(0xFF00F2FE); // kept for network bg
  static const Color purpleAccent  = Color(0xFF9B51E0); // kept for network bg
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [cyanAccent, purpleAccent],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );

  // ── Text style helpers ─────────────────────────────────────
  static TextStyle _display(Color c) => GoogleFonts.dmSerifDisplay(
        fontSize: 38, fontWeight: FontWeight.w400, color: c, height: 1.15,
      );
  static TextStyle _heading(Color c) => GoogleFonts.dmSerifDisplay(
        fontSize: 20, fontWeight: FontWeight.w400, color: c,
      );
  static TextStyle _labelCaps(Color c) => GoogleFonts.inter(
        fontSize: 10, fontWeight: FontWeight.w700, color: c, letterSpacing: 1.2,
      );
  static TextStyle _body(Color c) => GoogleFonts.inter(
        fontSize: 14, fontWeight: FontWeight.w400, color: c, height: 1.55,
      );
  static TextStyle _bodyMed(Color c) => GoogleFonts.inter(
        fontSize: 13, fontWeight: FontWeight.w400, color: c, height: 1.5,
      );
  static TextStyle _label(Color c) => GoogleFonts.inter(
        fontSize: 13, fontWeight: FontWeight.w600, color: c,
      );
  static TextStyle _caption(Color c) => GoogleFonts.inter(
        fontSize: 11, fontWeight: FontWeight.w400, color: c,
      );

  // ── Theme builders ─────────────────────────────────────────
  static ThemeData get lightTheme => _build(Brightness.light);
  static ThemeData get darkTheme  => _build(Brightness.dark);

  static ThemeData _build(Brightness brightness) {
    final bool isLight = brightness == Brightness.light;
    final Color bg        = isLight ? bgLight        : bgDark;
    final Color surface   = isLight ? surfaceLight   : surfaceDark;
    final Color border    = isLight ? borderLight    : borderDark;
    final Color primary   = isLight ? textPrimaryL   : textPrimaryD;
    final Color secondary = isLight ? textSecondaryL : textSecondaryD;

    return ThemeData(
      brightness: brightness,
      useMaterial3: true,
      scaffoldBackgroundColor: bg,
      primaryColor: amberAccent,
      colorScheme: ColorScheme(
        brightness: brightness,
        primary: amberAccent,
        onPrimary: Colors.black,
        secondary: amberAccent,
        onSecondary: Colors.black,
        surface: surface,
        onSurface: primary,
        error: const Color(0xFFD32F2F),
        onError: Colors.white,
      ),
      dividerColor: border,
      cardTheme: CardThemeData(
        color: surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
          side: BorderSide(color: border, width: 1),
        ),
        margin: EdgeInsets.zero,
      ),
      textTheme: TextTheme(
        displayLarge:  _display(primary),
        displayMedium: _display(primary).copyWith(fontSize: 30),
        displaySmall:  _display(primary).copyWith(fontSize: 22),
        headlineMedium:_heading(primary),
        headlineSmall: _heading(primary).copyWith(fontSize: 16),
        titleLarge:    _label(primary).copyWith(fontSize: 15),
        titleMedium:   _label(primary),
        titleSmall:    _label(secondary),
        bodyLarge:     _body(primary),
        bodyMedium:    _bodyMed(primary),
        bodySmall:     _caption(secondary),
        labelLarge:    _label(primary),
        labelMedium:   _labelCaps(secondary),
        labelSmall:    _caption(secondary),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: isLight ? surface2Light : surface2Dark,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: amberAccent, width: 1.5),
        ),
        hintStyle: _body(isLight ? textMutedL : textMutedD),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: amberAccent,
          foregroundColor: Colors.black,
          elevation: 0,
          textStyle: _label(Colors.black),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        ),
      ),
    );
  }
}
