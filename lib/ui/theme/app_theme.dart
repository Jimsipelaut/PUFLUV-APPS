import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

/// Token warna resmi PUFLUV (Luxury Dark Theme, keputusan D-19).
/// Nilainya diambil langsung dari desain Home / Tag balasan / Widget 4×2.
class AppColors {
  AppColors._();

  static const bg = Color(0xFF0E1014); // latar layar
  static const surface = Color(0xFF181B22); // kartu, sheet, dialog
  static const surfaceHigh = Color(0xFF252931); // permukaan lebih terang
  static const accent = Color(0xFFE6D3C3); // sand
  static const onAccent = Color(0xFF14161B); // teks di atas accent
  static const text = Color(0xFFFAF6F1);
  static const textSoft = Color(0xFFD4CCC3);
  static const muted = Color(0xFF9AA0AA);
  static const hint = Color(0xFF6B7380);
  static const danger = Color(0xFFE5736F);

  // Garis tipis putih transparan (rgba(255,255,255,.14 / .08 / .06))
  static const outline = Color(0x24FFFFFF);
  static const hairline = Color(0x14FFFFFF);
  static const cardBorder = Color(0x0FFFFFFF);
}

/// Gaya teks bersama: DM Sans untuk UI, Fraunces untuk angka/judul besar.
class AppText {
  AppText._();

  static TextStyle body(
    double size, {
    FontWeight weight = FontWeight.w400,
    Color color = AppColors.text,
    double? letterSpacing,
    double? height,
  }) =>
      GoogleFonts.dmSans(
        fontSize: size,
        fontWeight: weight,
        color: color,
        letterSpacing: letterSpacing,
        height: height,
      );

  static TextStyle display(
    double size, {
    Color color = AppColors.text,
    double height = 1.1,
  }) =>
      GoogleFonts.fraunces(
        fontSize: size,
        fontWeight: FontWeight.w400,
        color: color,
        height: height,
      );

  /// Label kecil kapital, mis. "ANNIVERSARY".
  static TextStyle label({Color color = AppColors.accent}) => GoogleFonts.dmSans(
        fontSize: 10,
        fontWeight: FontWeight.w500,
        letterSpacing: 2.6,
        color: color,
      );

  /// Label kolom form (12px, muted) seperti "Nama tag" di desain.
  static TextStyle fieldLabel() => body(12, color: AppColors.muted);
}

class AppTheme {
  AppTheme._();

  /// Pengaturan overlay status bar & navigation bar untuk tema gelap.
  static const SystemUiOverlayStyle overlay = SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light,
    statusBarBrightness: Brightness.dark,
    systemNavigationBarColor: AppColors.bg,
    systemNavigationBarIconBrightness: Brightness.light,
  );

  static ThemeData dark() {
    final base = ThemeData(brightness: Brightness.dark, useMaterial3: true);

    final textTheme = GoogleFonts.dmSansTextTheme(base.textTheme).apply(
      bodyColor: AppColors.text,
      displayColor: AppColors.text,
    );

    const scheme = ColorScheme.dark(
      primary: AppColors.accent,
      onPrimary: AppColors.onAccent,
      secondary: AppColors.accent,
      onSecondary: AppColors.onAccent,
      error: AppColors.danger,
      onError: AppColors.onAccent,
      surface: AppColors.surface,
      onSurface: AppColors.text,
      onSurfaceVariant: AppColors.muted,
      outline: AppColors.outline,
      outlineVariant: AppColors.hairline,
      surfaceTint: Colors.transparent,
    );

    final pillShape = const StadiumBorder();

    return base.copyWith(
      colorScheme: scheme,
      scaffoldBackgroundColor: AppColors.bg,
      canvasColor: AppColors.bg,
      textTheme: textTheme,
      primaryTextTheme: textTheme,
      splashColor: AppColors.accent.withValues(alpha: 0.08),
      highlightColor: Colors.transparent,
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.bg,
        foregroundColor: AppColors.text,
        elevation: 0,
        scrolledUnderElevation: 0,
        surfaceTintColor: Colors.transparent,
        centerTitle: false,
        titleTextStyle: AppText.body(18, weight: FontWeight.w500),
        iconTheme: const IconThemeData(color: AppColors.text),
        actionsIconTheme: const IconThemeData(color: AppColors.text),
        systemOverlayStyle: overlay,
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.accent,
          foregroundColor: AppColors.onAccent,
          disabledBackgroundColor: AppColors.accent.withValues(alpha: 0.35),
          disabledForegroundColor: AppColors.onAccent.withValues(alpha: 0.7),
          minimumSize: const Size(0, 48),
          padding: const EdgeInsets.symmetric(horizontal: 22),
          shape: pillShape,
          textStyle: AppText.body(15, weight: FontWeight.w500),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.accent,
          foregroundColor: AppColors.onAccent,
          elevation: 0,
          minimumSize: const Size(0, 44),
          shape: pillShape,
          textStyle: AppText.body(14, weight: FontWeight.w500),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.text,
          disabledForegroundColor: AppColors.muted,
          side: const BorderSide(color: AppColors.outline),
          minimumSize: const Size(0, 48),
          padding: const EdgeInsets.symmetric(horizontal: 22),
          shape: pillShape,
          textStyle: AppText.body(14),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.accent,
          disabledForegroundColor: AppColors.hint,
          minimumSize: const Size(44, 44),
          shape: pillShape,
          textStyle: AppText.body(14, weight: FontWeight.w500),
        ),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: AppColors.accent,
        foregroundColor: AppColors.onAccent,
        elevation: 0,
        focusElevation: 0,
        hoverElevation: 0,
        highlightElevation: 0,
        shape: pillShape,
        extendedTextStyle: AppText.body(14, weight: FontWeight.w500),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: AppColors.surface,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        titleTextStyle: AppText.body(18, weight: FontWeight.w500),
        contentTextStyle: AppText.body(14, color: AppColors.muted, height: 1.45),
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: AppColors.surface,
        modalBackgroundColor: AppColors.surface,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: AppColors.surface,
        behavior: SnackBarBehavior.floating,
        elevation: 0,
        contentTextStyle: AppText.body(14),
        actionTextColor: AppColors.accent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: AppColors.outline),
        ),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.selected)
              ? AppColors.onAccent
              : AppColors.muted,
        ),
        trackColor: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.selected)
              ? AppColors.accent
              : AppColors.bg,
        ),
        trackOutlineColor: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.selected)
              ? AppColors.accent
              : AppColors.outline,
        ),
      ),
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: AppColors.accent,
        circularTrackColor: Colors.transparent,
      ),
      dividerTheme: const DividerThemeData(
        color: AppColors.hairline,
        thickness: 1,
        space: 1,
      ),
      textSelectionTheme: TextSelectionThemeData(
        cursorColor: AppColors.accent,
        selectionColor: AppColors.accent.withValues(alpha: 0.3),
        selectionHandleColor: AppColors.accent,
      ),
      // Sengaja minimal: gaya kolom input dipasang oleh AppTextField, supaya
      // TextField lain (mis. di bottom sheet Tag balasan) tidak ikut berubah.
      inputDecorationTheme: InputDecorationTheme(
        hintStyle: AppText.body(15, color: AppColors.hint),
        errorStyle: AppText.body(12, color: AppColors.danger),
      ),
      datePickerTheme: DatePickerThemeData(
        backgroundColor: AppColors.surface,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
        headerBackgroundColor: AppColors.surface,
        headerForegroundColor: AppColors.text,
      ),
    );
  }
}
