import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// PERF: Theme resolves Google Fonts once here — avoid per-widget GoogleFonts.*
// calls in lists/grids (hurts rebuild cost & Web font resolution churn).

import 'bunkai_feedback_theme.dart';
import 'bunkai_tokens.dart';

Color _hsl(double h, double s, double l) {
  return HSLColor.fromAHSL(1, h, s / 100, l / 100).toColor();
}

ThemeData buildBunkaiDarkTheme() {
  final tokens = BunkaiTokens.dark;
  final pageBg = tokens.pageBg;
  final surface = tokens.surface1;
  final surfaceHigh = tokens.surface3;

  final accent = tokens.accent;
  final onAccent = _highContrastOn(accent);

  var scheme = ColorScheme.fromSeed(
    seedColor: accent,
    brightness: Brightness.dark,
    primary: accent,
    onPrimary: onAccent,
    surface: surface,
    surfaceContainerHighest: surfaceHigh,
  );
  scheme = scheme.copyWith(
    primary: accent,
    onPrimary: onAccent,
    primaryContainer: _hsl(205, 40, 16),
    onPrimaryContainer: _hsl(200, 100, 88),
    secondary: _hsl(318, 50, 55),
    onSecondary: tokens.textStrong,
    secondaryContainer: _hsl(300, 30, 18),
    onSecondaryContainer: _hsl(320, 40, 88),
    tertiary: _hsl(36, 90, 58),
    onTertiary: _hsl(230, 22, 8),
    surface: surface,
    surfaceContainerLow: tokens.surface1,
    surfaceContainer: tokens.surface2,
    surfaceContainerHigh: tokens.surface2,
    surfaceContainerHighest: tokens.surface3,
    onSurface: tokens.textMain,
    onSurfaceVariant: tokens.textMuted,
    outline: Color.lerp(tokens.borderStrong, tokens.textMuted, 0.35)!,
    outlineVariant: tokens.borderSoft,
  );

  final notoFamily = GoogleFonts.notoSansJp().fontFamily!;
  final interBase = GoogleFonts.interTextTheme(Typography.whiteMountainView);
  final textTheme = interBase.copyWith(
    displaySmall: interBase.displaySmall?.copyWith(
      fontWeight: FontWeight.w700,
      letterSpacing: -0.6,
      height: 1.15,
      color: tokens.textStrong,
      fontFamilyFallback: [notoFamily],
    ),
    headlineMedium: interBase.headlineMedium?.copyWith(
      fontWeight: FontWeight.w700,
      letterSpacing: -0.4,
      height: 1.2,
      color: tokens.textStrong,
      fontFamilyFallback: [notoFamily],
    ),
    titleLarge: interBase.titleLarge?.copyWith(
      letterSpacing: 0.02,
      fontWeight: FontWeight.w700,
      height: 1.35,
      color: tokens.textStrong,
      fontFamilyFallback: [notoFamily],
    ),
    titleMedium: interBase.titleMedium?.copyWith(
      letterSpacing: 0.03,
      fontWeight: FontWeight.w600,
      height: 1.4,
      color: tokens.textStrong,
      fontFamilyFallback: [notoFamily],
    ),
    titleSmall: interBase.titleSmall?.copyWith(
      letterSpacing: 0.04,
      fontWeight: FontWeight.w600,
      height: 1.35,
      color: tokens.textMain,
      fontFamilyFallback: [notoFamily],
    ),
    bodyLarge: interBase.bodyLarge?.copyWith(
      letterSpacing: 0.02,
      height: 1.55,
      fontWeight: FontWeight.w400,
      color: tokens.textMain,
      fontFamilyFallback: [notoFamily],
    ),
    bodyMedium: interBase.bodyMedium?.copyWith(
      letterSpacing: 0.02,
      height: 1.5,
      color: tokens.textMain,
      fontFamilyFallback: [notoFamily],
    ),
    bodySmall: interBase.bodySmall?.copyWith(
      letterSpacing: 0.02,
      height: 1.45,
      color: tokens.textMuted,
      fontFamilyFallback: [notoFamily],
    ),
    labelLarge: interBase.labelLarge?.copyWith(
      letterSpacing: 0.4,
      fontWeight: FontWeight.w600,
      color: tokens.textMain,
      fontFamilyFallback: [notoFamily],
    ),
    labelMedium: interBase.labelMedium?.copyWith(
      letterSpacing: 0.28,
      fontWeight: FontWeight.w500,
      color: tokens.textMuted,
      fontFamilyFallback: [notoFamily],
    ),
    labelSmall: interBase.labelSmall?.copyWith(
      letterSpacing: 0.22,
      fontWeight: FontWeight.w500,
      color: tokens.textMuted,
      fontFamilyFallback: [notoFamily],
    ),
  );

  return ThemeData(
    useMaterial3: true,
    colorScheme: scheme,
    scaffoldBackgroundColor: pageBg,
    fontFamily: GoogleFonts.inter().fontFamily,
    fontFamilyFallback: [notoFamily],
    textTheme: textTheme,
    cardTheme: CardThemeData(
      elevation: 0,
      color: tokens.surface2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(tokens.radiusMd),
        side: BorderSide(color: tokens.borderSoft),
      ),
    ),
    dividerTheme: DividerThemeData(color: tokens.borderSoft),
    appBarTheme: AppBarTheme(
      elevation: 0,
      scrolledUnderElevation: 0,
      backgroundColor: Colors.transparent,
      foregroundColor: tokens.textStrong,
      centerTitle: false,
      titleTextStyle: GoogleFonts.inter(
        color: tokens.textStrong,
        fontSize: 17,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.02,
      ),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        foregroundColor: onAccent,
        backgroundColor: accent,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(tokens.radiusSm),
        ),
      ),
    ),
    focusColor: tokens.accent.withValues(alpha: 0.35),
    hoverColor: tokens.accentSoft,
    highlightColor: tokens.accentSoft,
    splashColor: tokens.accent.withValues(alpha: 0.12),
    extensions: const <ThemeExtension<dynamic>>[
      BunkaiFeedbackColors.dark,
      BunkaiTokens.dark,
    ],
  );
}

Color _highContrastOn(Color background) {
  final luminance = background.computeLuminance();
  return luminance > 0.45 ? const Color(0xFF0D1118) : const Color(0xFFFAFAFA);
}
