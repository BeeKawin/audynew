import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Autism-friendly color palette designed for:
/// - Calming pastel tones to prevent sensory overload
/// - High contrast for visual clarity
/// - Reduced eye strain
/// - Clear visual differentiation
class AudyColors {
  // Core Palette
  static const Color skyBlue = Color(0xFF7FDBDA);
  static const Color mintGreen = Color.fromARGB(255, 152, 224, 123);
  static const Color iceBlue = Color(0xffede682);
  static const Color softLavender = Color(0xfffebf63);
  static const Color blushPink = Color(0xFFF1B4D3);
  static const Color ivoryWhite = Color(0xFFFFFCFC);

  // Background Colors
  static const Color backgroundPrimary = ivoryWhite;
  static const Color backgroundSoft = iceBlue;
  static const Color backgroundCard = ivoryWhite;

  // Text Colors
  static const Color textPrimary = Color(0xFF2D3748);
  static const Color textSecondary = Color(0xFF4A5568);
  static const Color textLight = Color(0xFF718096);
  static const Color textOnColor = Color(0xFFFFFFFF);

  // Functional Colors
  static const Color success = Color(0xFF68D391);
  static const Color error = Color(0xFFFC8181);
  static const Color warning = Color(0xFFFBD38D);
  static const Color info = skyBlue;

  // Activity Colors (soft, distinct, recognizable)
  static const Color activityGames = skyBlue;
  static const Color activityReading = mintGreen;
  static const Color activitySocial = Color.fromARGB(255, 252, 196, 184);
  static const Color activityRewards = Color(0xFFFBD38D);

  // Reward Colors
  static const Color starGold = Color(0xFFFBD38D);
  static const Color starSilver = Color(0xFFCBD5E0);

  // Border Colors
  static const Color borderLight = Color(0xFFE2E8F0);
  static const Color borderFocus = skyBlue;

  // Shadow Colors
  static const Color shadowSoft = Color(0x0A2D3748);
  static const Color shadowMedium = Color(0x142D3748);
}

class AudyTypography {
  static TextStyle get displayLarge => GoogleFonts.fredoka(
    fontSize: 44,
    fontWeight: FontWeight.w700,
    color: AudyColors.textPrimary,
    letterSpacing: 0.5,
    height: 1.2,
  );

  static TextStyle get displayMedium => GoogleFonts.fredoka(
    fontSize: 64,
    fontWeight: FontWeight.w700,
    color: AudyColors.textPrimary,
    letterSpacing: 0.3,
    height: 1.3,
  );

  static TextStyle get headingLarge => GoogleFonts.fredoka(
    fontSize: 30,
    fontWeight: FontWeight.w700,
    color: AudyColors.textPrimary,
    letterSpacing: 0.2,
    height: 1.3,
  );

  static TextStyle get headingMedium => GoogleFonts.fredoka(
    fontSize: 26,
    fontWeight: FontWeight.w600,
    color: AudyColors.textPrimary,
    letterSpacing: 0.1,
    height: 1.4,
  );

  static TextStyle get headingSmall => GoogleFonts.fredoka(
    fontSize: 22,
    fontWeight: FontWeight.w600,
    color: AudyColors.textPrimary,
    height: 1.4,
  );

  static TextStyle get bodyLarge => GoogleFonts.lexend(
    fontSize: 20,
    fontWeight: FontWeight.w400,
    color: AudyColors.textSecondary,
    height: 1.6,
  );

  static TextStyle get bodyMedium => GoogleFonts.lexend(
    fontSize: 18,
    fontWeight: FontWeight.w400,
    color: AudyColors.textSecondary,
    height: 1.6,
  );

  static TextStyle get bodySmall => GoogleFonts.lexend(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    color: AudyColors.textSecondary,
    height: 1.6,
  );

  static TextStyle get labelLarge => GoogleFonts.lexend(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    color: AudyColors.textPrimary,
    letterSpacing: 0.3,
  );

  static TextStyle get labelMedium => GoogleFonts.lexend(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: AudyColors.textPrimary,
    letterSpacing: 0.2,
  );

  static TextStyle get buttonText => GoogleFonts.lexend(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    color: AudyColors.textOnColor,
    letterSpacing: 0.3,
  );

  static TextStyle get cardTitle => GoogleFonts.fredoka(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    color: AudyColors.textPrimary,
    height: 1.3,
  );

  static TextStyle get greeting => GoogleFonts.fredoka(
    fontSize: 28,
    fontWeight: FontWeight.w600,
    color: AudyColors.textPrimary,
    height: 1.3,
  );

  static TextStyle get starCount => GoogleFonts.fredoka(
    fontSize: 32,
    fontWeight: FontWeight.w700,
    color: AudyColors.textPrimary,
    height: 1.2,
  );
}

/// Spacing and sizing constants - increased for autism-friendly touch targets
class AudySpacing {
  // Touch targets - minimum 56dp for accessibility
  static const double touchTargetMin = 56.0;
  static const double buttonHeight = 68.0;
  static const double cardPadding = 24.0;
  static const double sectionGap = 36.0;
  static const double elementGap = 20.0;
  static const double smallGap = 14.0;
  static const double screenPadding = 24.0;

  // Border radius for friendly, rounded shapes
  static const double radiusSmall = 14.0;
  static const double radiusMedium = 22.0;
  static const double radiusLarge = 32.0;
  static const double radiusXLarge = 40.0;
  static const double radiusCircular = 100.0;

  // Icon sizes - increased for visual clarity
  static const double iconSmall = 32.0;
  static const double iconMedium = 48.0;
  static const double iconLarge = 64.0;
  static const double iconXLarge = 80.0;
}

/// Shadow styles - soft, non-overwhelming depth
class AudyShadows {
  static const BoxShadow soft = BoxShadow(
    color: AudyColors.shadowSoft,
    blurRadius: 16,
    offset: Offset(0, 4),
    spreadRadius: -2,
  );

  static const BoxShadow medium = BoxShadow(
    color: AudyColors.shadowMedium,
    blurRadius: 24,
    offset: Offset(0, 8),
    spreadRadius: -4,
  );

  static const BoxShadow pressed = BoxShadow(
    color: AudyColors.shadowSoft,
    blurRadius: 12,
    offset: Offset(0, 2),
    spreadRadius: -1,
  );

  static const List<BoxShadow> cardShadow = [
    BoxShadow(
      color: AudyColors.shadowSoft,
      blurRadius: 20,
      offset: Offset(0, 6),
      spreadRadius: -3,
    ),
  ];
}

/// Animation durations - slower, gentler for accessibility
class AudyAnimation {
  static const Duration quick = Duration(milliseconds: 150);
  static const Duration normal = Duration(milliseconds: 250);
  static const Duration slow = Duration(milliseconds: 400);
  static const Duration emphasis = Duration(milliseconds: 600);
}
