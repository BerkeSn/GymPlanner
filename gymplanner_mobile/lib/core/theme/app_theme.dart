import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gymplanner_mobile/core/constants/app_colors.dart';

/// Obsidian Athletics tasarım sistemi tek bir "dark-first" tema olarak
/// kurgulanmıştır. Prototipte ayrı bir açık (light) tema tanımlanmamıştı,
/// bu yüzden şimdilik light tema de aynı palete işaret ediyor. Marka kimliği
/// zaten koyu zemin üzerine kurulu olduğu için ileride tema değiştirme
/// (dark/light toggle) özelliğini tamamen kaldırmayı değerlendirebiliriz.
class AppTheme {
  AppTheme._();

  static ThemeData get darkTheme => _buildTheme();

  static ThemeData get lightTheme =>
      _buildTheme();

  static ThemeData _buildTheme() {
    final textTheme =
        GoogleFonts.hankenGroteskTextTheme(
          ThemeData(
            brightness: Brightness.dark,
          ).textTheme,
        ).apply(
          bodyColor: AppColors.onSurface,
          displayColor: AppColors.onSurface,
        );

    return ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor:
          AppColors.background,
      primaryColor: AppColors.primary,
      textTheme: textTheme,
      colorScheme: const ColorScheme.dark(
        primary: AppColors.primary,
        onPrimary: AppColors.onPrimary,
        secondary: AppColors.secondary,
        onSecondary: AppColors.onSecondary,
        surface: AppColors.surface,
        onSurface: AppColors.onSurface,
        error: AppColors.error,
        onError: AppColors.onError,
      ),

      // --- AppBar ---
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.background,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: GoogleFonts.hankenGrotesk(
          fontSize: 20,
          fontWeight: FontWeight.w500,
          color: AppColors.onSurface,
        ),
        iconTheme: const IconThemeData(
          color: AppColors.onSurface,
        ),
      ),

      // --- Bottom Navigation Bar ---
      bottomNavigationBarTheme:
          BottomNavigationBarThemeData(
            backgroundColor:
                AppColors.surfaceContainerLowest,
            selectedItemColor: AppColors.primary,
            unselectedItemColor:
                AppColors.onSurfaceVariant,
            type: BottomNavigationBarType.fixed,
            elevation: 0,
            selectedLabelStyle: GoogleFonts.geist(
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
            unselectedLabelStyle:
                GoogleFonts.geist(fontSize: 11),
          ),

      // --- Card (Level 1: no shadow, 1px glass-edge stroke, 4px radius) ---
      cardTheme: CardThemeData(
        color: AppColors.surface,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(4),
          side: BorderSide(
            color: Colors.white.withValues(
              alpha: 0.08,
            ),
            width: 1,
          ),
        ),
      ),

      // --- Input (TextField): minimalist, 4px radius, focus = Ice Blue ---
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surface,
        hintStyle: GoogleFonts.hankenGrotesk(
          color: AppColors.onSurfaceVariant,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(4),
          borderSide: BorderSide(
            color: Colors.white.withValues(
              alpha: 0.08,
            ),
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(4),
          borderSide: BorderSide(
            color: Colors.white.withValues(
              alpha: 0.08,
            ),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(4),
          borderSide: const BorderSide(
            color: AppColors.primary,
            width: 1.5,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(4),
          borderSide: const BorderSide(
            color: AppColors.error,
            width: 1.5,
          ),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(4),
          borderSide: const BorderSide(
            color: AppColors.error,
            width: 1.5,
          ),
        ),
      ),

      // --- ElevatedButton: flat Ice Blue, koyu metin, 4px radius ---
      elevatedButtonTheme:
          ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor:
                  AppColors.onPrimary,
              disabledBackgroundColor: AppColors
                  .primary
                  .withValues(alpha: 0.4),
              minimumSize: const Size(
                double.infinity,
                52,
              ),
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius:
                    BorderRadius.circular(4),
              ),
              textStyle: GoogleFonts.geist(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.05 * 12,
              ),
            ),
          ),

      // --- OutlinedButton: "Ghost" — şeffaf, %20 opak beyaz kenarlık ---
      outlinedButtonTheme:
          OutlinedButtonThemeData(
            style: OutlinedButton.styleFrom(
              foregroundColor:
                  AppColors.onSurface,
              side: BorderSide(
                color: Colors.white.withValues(
                  alpha: 0.2,
                ),
              ),
              minimumSize: const Size(
                double.infinity,
                52,
              ),
              shape: RoundedRectangleBorder(
                borderRadius:
                    BorderRadius.circular(4),
              ),
            ),
          ),

      // --- TextButton ---
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.primary,
          textStyle: GoogleFonts.hankenGrotesk(
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      // --- Divider: %5-10 opak beyaz, borderless liste hissi ---
      dividerTheme: DividerThemeData(
        color: Colors.white.withValues(
          alpha: 0.08,
        ),
        thickness: 1,
        space: 1,
      ),

      // --- Chip (kas grubu / ekipman etiketleri) ---
      chipTheme: ChipThemeData(
        backgroundColor: AppColors.surface,
        labelStyle: GoogleFonts.geist(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.05 * 12,
          color: AppColors.onSurfaceVariant,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(2),
          side: BorderSide(
            color: Colors.white.withValues(
              alpha: 0.08,
            ),
          ),
        ),
      ),
    );
  }
}
