import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../constants/app_colors.dart';

class AppTextStyles {
  AppTextStyles._();

  // === DISPLAY ===
  static TextStyle displayLarge(BuildContext context) => GoogleFonts.outfit(
        fontSize: 36,
        fontWeight: FontWeight.w800,
        color: _textPrimary(context),
        letterSpacing: -1.0,
        height: 1.1,
      );

  static TextStyle displayMedium(BuildContext context) => GoogleFonts.outfit(
        fontSize: 28,
        fontWeight: FontWeight.w700,
        color: _textPrimary(context),
        letterSpacing: -0.5,
        height: 1.2,
      );

  // === HEADLINE ===
  static TextStyle headlineLarge(BuildContext context) => GoogleFonts.outfit(
        fontSize: 22,
        fontWeight: FontWeight.w700,
        color: _textPrimary(context),
        letterSpacing: -0.3,
        height: 1.3,
      );

  static TextStyle headlineMedium(BuildContext context) => GoogleFonts.outfit(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: _textPrimary(context),
        letterSpacing: -0.2,
        height: 1.3,
      );

  static TextStyle headlineSmall(BuildContext context) => GoogleFonts.outfit(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: _textPrimary(context),
        height: 1.4,
      );

  // === BODY ===
  static TextStyle bodyLarge(BuildContext context) => GoogleFonts.inter(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        color: _textPrimary(context),
        height: 1.5,
      );

  static TextStyle bodyMedium(BuildContext context) => GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: _textPrimary(context),
        height: 1.5,
      );

  static TextStyle bodySmall(BuildContext context) => GoogleFonts.inter(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        color: _textSecondary(context),
        height: 1.5,
      );

  // === LABEL ===
  static TextStyle labelLarge(BuildContext context) => GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: _textPrimary(context),
        letterSpacing: 0.1,
      );

  static TextStyle labelMedium(BuildContext context) => GoogleFonts.inter(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        color: _textSecondary(context),
        letterSpacing: 0.5,
      );

  static TextStyle labelSmall(BuildContext context) => GoogleFonts.inter(
        fontSize: 10,
        fontWeight: FontWeight.w600,
        color: _textTertiary(context),
        letterSpacing: 0.5,
      );

  // === NUMERIC / MONEY ===
  static TextStyle moneyLarge(BuildContext context) => GoogleFonts.outfit(
        fontSize: 32,
        fontWeight: FontWeight.w800,
        color: _textPrimary(context),
        letterSpacing: -1.0,
      );

  static TextStyle moneyMedium(BuildContext context) => GoogleFonts.outfit(
        fontSize: 20,
        fontWeight: FontWeight.w700,
        color: _textPrimary(context),
        letterSpacing: -0.5,
      );

  static TextStyle moneySmall(BuildContext context) => GoogleFonts.outfit(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: _textSecondary(context),
      );

  // === CAPTION ===
  static TextStyle caption(BuildContext context) => GoogleFonts.inter(
        fontSize: 11,
        fontWeight: FontWeight.w400,
        color: _textTertiary(context),
        height: 1.4,
      );

  // === HELPERS ===
  static Color _textPrimary(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? AppColors.textPrimaryDark
        : AppColors.textPrimaryLight;
  }

  static Color _textSecondary(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? AppColors.textSecondaryDark
        : AppColors.textSecondaryLight;
  }

  static Color _textTertiary(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? AppColors.textTertiaryDark
        : AppColors.textTertiaryLight;
  }
}
