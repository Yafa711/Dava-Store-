// lib/core/theme/app_theme.dart
// DAVA Store – Global theme with Glassmorphism, dark palette & rose accents

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../constants/app_constants.dart';

class AppTheme {
  // ─── Core Color Palette ──────────────────────────────────────────────────────
  static const Color primary   = Color(AppConstants.primaryColorHex);
  static const Color secondary = Color(AppConstants.secondaryColorHex);
  static const Color accent    = Color(AppConstants.accentColorHex);
  static const Color surface   = Color(AppConstants.surfaceColorHex);
  static const Color card      = Color(AppConstants.cardColorHex);
  static const Color divider   = Color(AppConstants.dividerColorHex);

  // Extended palette
  static const Color textPrimary   = Color(0xFFF0EDE8);
  static const Color textSecondary = Color(0xFFB0ADA8);
  static const Color textMuted     = Color(0xFF6B7068);
  static const Color success       = Color(0xFF4CAF82);
  static const Color warning       = Color(0xFFFFB74D);
  static const Color error         = Color(0xFFEF5350);
  static const Color info          = Color(0xFF64B5F6);

  // Glassmorphism colours
  static const Color glassWhite     = Color(0x14FFFFFF);
  static const Color glassBorder    = Color(0x22FFFFFF);
  static const Color glassDark      = Color(0x1A000000);
  static const Color accentGlow     = Color(0x33D1848C);

  // ─── Gradient Definitions ────────────────────────────────────────────────────
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primary, secondary],
  );

  static const LinearGradient accentGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFD1848C), Color(0xFFE8A0A8)],
  );

  static const LinearGradient cardGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF1E2D2A), Color(0xFF243330)],
  );

  static const LinearGradient backgroundGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFF182421), Color(0xFF18242C), Color(0xFF182421)],
    stops: [0.0, 0.5, 1.0],
  );

  static const RadialGradient accentRadial = RadialGradient(
    center: Alignment.topRight,
    radius: 1.2,
    colors: [Color(0x22D1848C), Colors.transparent],
  );

  // ─── Text Styles ─────────────────────────────────────────────────────────────
  static const TextStyle displayLarge = TextStyle(
    fontSize: 32, fontWeight: FontWeight.w700,
    color: textPrimary, letterSpacing: -0.5,
  );
  static const TextStyle displayMedium = TextStyle(
    fontSize: 26, fontWeight: FontWeight.w700,
    color: textPrimary, letterSpacing: -0.3,
  );
  static const TextStyle headlineLarge = TextStyle(
    fontSize: 22, fontWeight: FontWeight.w600,
    color: textPrimary, letterSpacing: 0.2,
  );
  static const TextStyle headlineMedium = TextStyle(
    fontSize: 18, fontWeight: FontWeight.w600,
    color: textPrimary,
  );
  static const TextStyle titleLarge = TextStyle(
    fontSize: 16, fontWeight: FontWeight.w600,
    color: textPrimary,
  );
  static const TextStyle titleMedium = TextStyle(
    fontSize: 14, fontWeight: FontWeight.w600,
    color: textPrimary, letterSpacing: 0.1,
  );
  static const TextStyle bodyLarge = TextStyle(
    fontSize: 16, fontWeight: FontWeight.w400,
    color: textPrimary,
  );
  static const TextStyle bodyMedium = TextStyle(
    fontSize: 14, fontWeight: FontWeight.w400,
    color: textSecondary,
  );
  static const TextStyle bodySmall = TextStyle(
    fontSize: 12, fontWeight: FontWeight.w400,
    color: textMuted,
  );
  static const TextStyle labelLarge = TextStyle(
    fontSize: 14, fontWeight: FontWeight.w600,
    color: accent, letterSpacing: 0.5,
  );

  // ─── ThemeData ───────────────────────────────────────────────────────────────
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      fontFamily: 'Rajdhani',
      scaffoldBackgroundColor: primary,

      colorScheme: const ColorScheme.dark(
        primary:    accent,
        secondary:  secondary,
        surface:    surface,
        error:      error,
        onPrimary:  Colors.white,
        onSecondary: textPrimary,
        onSurface:  textPrimary,
        onError:    Colors.white,
      ),

      // AppBar
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.light,
        ),
        titleTextStyle: TextStyle(
          fontFamily: 'Rajdhani',
          fontSize: 20, fontWeight: FontWeight.w700,
          color: textPrimary, letterSpacing: 1.5,
        ),
        iconTheme: IconThemeData(color: textPrimary),
      ),

      // Cards
      cardTheme: CardTheme(
        color: card,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppConstants.radiusMd),
          side: const BorderSide(color: glassBorder, width: 1),
        ),
        margin: EdgeInsets.zero,
      ),

      // Elevated Button
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: accent,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppConstants.radiusMd),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          textStyle: const TextStyle(
            fontFamily: 'Rajdhani',
            fontSize: 15, fontWeight: FontWeight.w700,
            letterSpacing: 0.8,
          ),
        ),
      ),

      // Outlined Button
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: accent,
          side: const BorderSide(color: accent, width: 1.5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppConstants.radiusMd),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          textStyle: const TextStyle(
            fontFamily: 'Rajdhani',
            fontSize: 15, fontWeight: FontWeight.w600,
          ),
        ),
      ),

      // Text Button
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: accent,
          textStyle: const TextStyle(
            fontFamily: 'Rajdhani',
            fontSize: 14, fontWeight: FontWeight.w600,
          ),
        ),
      ),

      // Input Fields
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: glassWhite,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppConstants.radiusMd),
          borderSide: const BorderSide(color: glassBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppConstants.radiusMd),
          borderSide: const BorderSide(color: glassBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppConstants.radiusMd),
          borderSide: const BorderSide(color: accent, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppConstants.radiusMd),
          borderSide: const BorderSide(color: error),
        ),
        hintStyle: const TextStyle(color: textMuted, fontFamily: 'Rajdhani'),
        labelStyle: const TextStyle(color: textSecondary, fontFamily: 'Rajdhani'),
        prefixIconColor: textMuted,
        suffixIconColor: textMuted,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),

      // Chips
      chipTheme: ChipThemeData(
        backgroundColor: glassWhite,
        selectedColor: accent.withOpacity(0.3),
        side: const BorderSide(color: glassBorder),
        labelStyle: const TextStyle(
          fontFamily: 'Rajdhani', fontSize: 13,
          fontWeight: FontWeight.w500, color: textPrimary,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppConstants.radiusSm),
        ),
      ),

      // Bottom Navigation
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: secondary,
        selectedItemColor: accent,
        unselectedItemColor: textMuted,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
        selectedLabelStyle: TextStyle(
          fontFamily: 'Rajdhani', fontSize: 11, fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: TextStyle(
          fontFamily: 'Rajdhani', fontSize: 11,
        ),
      ),

      // Divider
      dividerTheme: const DividerThemeData(
        color: divider, thickness: 1, space: 1,
      ),

      // Snackbar
      snackBarTheme: SnackBarThemeData(
        backgroundColor: card,
        contentTextStyle: const TextStyle(
          fontFamily: 'Rajdhani', fontSize: 14, color: textPrimary,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppConstants.radiusSm),
        ),
        behavior: SnackBarBehavior.floating,
      ),

      // Dialog
      dialogTheme: DialogTheme(
        backgroundColor: surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppConstants.radiusLg),
          side: const BorderSide(color: glassBorder),
        ),
        titleTextStyle: const TextStyle(
          fontFamily: 'Rajdhani', fontSize: 20,
          fontWeight: FontWeight.w700, color: textPrimary,
        ),
        contentTextStyle: const TextStyle(
          fontFamily: 'Rajdhani', fontSize: 14, color: textSecondary,
        ),
      ),

      // Switch
      switchTheme: SwitchThemeData(
        thumbColor: MaterialStateProperty.resolveWith((states) =>
          states.contains(MaterialState.selected) ? accent : textMuted),
        trackColor: MaterialStateProperty.resolveWith((states) =>
          states.contains(MaterialState.selected)
            ? accent.withOpacity(0.4) : glassWhite),
      ),

      // Checkbox
      checkboxTheme: CheckboxThemeData(
        fillColor: MaterialStateProperty.resolveWith((states) =>
          states.contains(MaterialState.selected) ? accent : Colors.transparent),
        checkColor: MaterialStateProperty.all(Colors.white),
        side: const BorderSide(color: textMuted, width: 1.5),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(4),
        ),
      ),

      // Progress Indicator
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: accent,
        linearTrackColor: glassWhite,
      ),

      // Icon
      iconTheme: const IconThemeData(color: textSecondary, size: 22),
      primaryIconTheme: const IconThemeData(color: accent, size: 22),
    );
  }
}

// ─── Glassmorphism Helper ─────────────────────────────────────────────────────
class GlassContainer extends StatelessWidget {
  final Widget child;
  final double? width;
  final double? height;
  final EdgeInsets? padding;
  final EdgeInsets? margin;
  final double borderRadius;
  final double blur;
  final Color? color;
  final Border? border;

  const GlassContainer({
    super.key,
    required this.child,
    this.width,
    this.height,
    this.padding,
    this.margin,
    this.borderRadius = AppConstants.radiusMd,
    this.blur = 10,
    this.color,
    this.border,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      margin: margin,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(borderRadius),
        color: color ?? AppTheme.glassWhite,
        border: border ?? Border.all(color: AppTheme.glassBorder, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: Padding(
          padding: padding ?? const EdgeInsets.all(AppConstants.spacingMd),
          child: child,
        ),
      ),
    );
  }
}
