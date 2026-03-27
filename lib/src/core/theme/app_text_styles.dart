import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

class AppTextStyles {
  static TextStyle get headerLarge => GoogleFonts.inter(
    fontSize: 48, // Adjusted from 60px for mobile fit
    fontWeight: FontWeight.bold,
    color: AppColors.onSurfaceLight,
    height: 1.1,
  );

  static TextStyle get headerMedium => GoogleFonts.inter(
    fontSize: 24,
    fontWeight: FontWeight.bold,
    color: AppColors.onSurfaceLight,
  );

  static TextStyle get cardTitle => GoogleFonts.inter(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    color: AppColors.onSurfaceLight,
  );

  static TextStyle get bodyRegular => GoogleFonts.inter(
    fontSize: 14,
    fontWeight: FontWeight.normal,
    color: AppColors.onSurfaceLight,
  );

  static TextStyle get bodySmall => GoogleFonts.inter(
    fontSize: 12,
    fontWeight: FontWeight.normal,
    color: AppColors.onSurfaceVariantLight,
  );

  static TextStyle get badgeText => GoogleFonts.inter(
    fontSize: 10,
    fontWeight: FontWeight.w500,
    color: AppColors.textLight,
    letterSpacing: 1.0,
  );

  static TextStyle get priceText => GoogleFonts.inter(
    fontSize: 20,
    fontWeight: FontWeight.bold,
    color: AppColors.primary,
  );
}
