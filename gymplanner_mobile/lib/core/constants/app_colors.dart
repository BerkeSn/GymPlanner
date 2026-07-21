import 'package:flutter/material.dart';

/// Obsidian Athletics — "Quiet Tech" / Premium Minimalism tasarım sistemi.
/// Kaynak: Prototip_1/stitch_fithub_social_progress/obsidian_athletics/DESIGN.md
class AppColors {
  AppColors._();

  // --- Marka ---
  static const Color primary = Color(
    0xFFA5C9EB,
  ); // Muted Ice Blue — CTA'lar, aktif durumlar
  static const Color onPrimary = Color(
    0xFF07334F,
  ); // Primary üzerindeki koyu metin
  static const Color primaryContainer = Color(
    0xFFA5C9EB,
  );
  static const Color onPrimaryContainer = Color(
    0xFF315572,
  );

  // --- İkincil ---
  static const Color secondary = Color(
    0xFFC6C6C7,
  );
  static const Color onSecondary = Color(
    0xFF2F3131,
  );

  // --- Zemin / Tonal Katmanlar (gölge yok, sadece ton farkı) ---
  static const Color background = Color(
    0xFF131315,
  ); // Level 0 — Canvas
  static const Color surfaceContainerLowest =
      Color(0xFF0E0E10);
  static const Color surface = Color(
    0xFF1E1E21,
  ); // Level 1 — Kart/Container
  static const Color surfaceContainerHigh = Color(
    0xFF2A2A2D,
  ); // Level 2 — Modal/Overlay
  static const Color surfaceBright = Color(
    0xFF39393B,
  );

  // --- Metin ---
  static const Color onSurface = Color(
    0xFFE5E1E4,
  ); // Ana metin (Crisp White)
  static const Color onSurfaceVariant = Color(
    0xFFC2C7CE,
  ); // İkincil/soluk metin
  static const Color textMuted = Color(
    0xFF8C9198,
  ); // outline / disabled

  // --- Çizgi / Kenarlık ---
  static const Color outline = Color(0xFF8C9198);
  static const Color outlineVariant = Color(
    0xFF42474D,
  );
  static const Color dividerOnDark = Colors
      .white; // %5-10 opacity ile kullanılacak
  static const Color ghostBorder = Colors
      .white; // %20 opacity ile kullanılacak (Secondary buton kenarlığı)

  // --- Durum Renkleri (deseature edilmiş, buz mavisi estetiğine uyumlu) ---
  static const Color success = Color(
    0xFF9FC6B8,
  ); // Desature yeşil
  static const Color onSuccess = Color(
    0xFF07334F,
  );
  static const Color error = Color(0xFFFFB4AB);
  static const Color onError = Color(0xFF690005);
  static const Color errorContainer = Color(
    0xFF93000A,
  );
  static const Color warning = Color(0xFFE3D7A6);

  // --- Geriye dönük uyumluluk (eski isimler; kademeli olarak kaldırılacak) ---
  static const Color primaryDark = Color(
    0xFF7FA9CE,
  );
  static const Color darkBackground = background;
  static const Color darkSurface = surface;
  static const Color darkCard = surface;
  static const Color lightBackground = background;
  static const Color lightSurface = surface;
  static const Color lightCard = surface;
  static const Color textLight = onSurface;
  static const Color textDark = onSurface;
  static const Color textGrey = onSurfaceVariant;
}
