import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gymplanner_mobile/core/constants/app_colors.dart';

/// Hanken Grotesk: başlıklar & gövde metni (sıcak, profesyonel).
/// Geist: rakamsal veriler & küçük etiketler (teknik, "instrument" hissi).
class AppTextStyles {
  AppTextStyles._();

  // --- Başlıklar (Hanken Grotesk) ---
  static TextStyle get h1 => GoogleFonts.hankenGrotesk(
        fontSize: 24,
        fontWeight: FontWeight.w400,
        height: 32 / 24,
        color: AppColors.onSurface,
      );

  static TextStyle get h2 => GoogleFonts.hankenGrotesk(
        fontSize: 20,
        fontWeight: FontWeight.w500,
        height: 28 / 20,
        color: AppColors.onSurface,
      );

  static TextStyle get h3 => GoogleFonts.hankenGrotesk(
        fontSize: 18,
        fontWeight: FontWeight.w500,
        height: 26 / 18,
        color: AppColors.onSurface,
      );

  static TextStyle get display => GoogleFonts.hankenGrotesk(
        fontSize: 48,
        fontWeight: FontWeight.w300,
        height: 56 / 48,
        letterSpacing: -0.02 * 48,
        color: AppColors.onSurface,
      );

  // --- Gövde Metinleri (Hanken Grotesk) ---
  static TextStyle get bodyLarge => GoogleFonts.hankenGrotesk(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        height: 24 / 16,
        color: AppColors.onSurface,
      );

  static TextStyle get bodyMedium => GoogleFonts.hankenGrotesk(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        height: 20 / 14,
        color: AppColors.onSurface,
      );

  static TextStyle get bodySmall => GoogleFonts.hankenGrotesk(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        height: 16 / 12,
        color: AppColors.onSurfaceVariant,
      );

  // --- Özel (Hanken Grotesk) ---
  static TextStyle get button => GoogleFonts.hankenGrotesk(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: AppColors.onSurface,
      );

  // --- Küçük etiketler / chip'ler (Geist, harf aralığı geniş) ---
  static TextStyle get labelCaps => GoogleFonts.geist(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        height: 16 / 12,
        letterSpacing: 0.05 * 12,
        color: AppColors.onSurfaceVariant,
      );

  // Eski koddaki `label` alanını kullanan yerler kırılmasın diye:
  static TextStyle get label => labelCaps;

  // --- Rakamsal veriler: set/tekrar/ağırlık/zamanlayıcı (Geist mono-hissi) ---
  static TextStyle get dataMono => GoogleFonts.geist(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        height: 24 / 16,
        color: AppColors.onSurface,
      );

  static TextStyle get dataMonoLarge => GoogleFonts.geist(
        fontSize: 28,
        fontWeight: FontWeight.w500,
        height: 32 / 28,
        color: AppColors.primary,
      );
}