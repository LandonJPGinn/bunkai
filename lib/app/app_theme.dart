import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'bunkai_feedback_theme.dart';

const Color _kScaffold = Color(0xFF101820);
const Color _kSurface = Color(0xFF15212E);
const Color _kSurfaceHigh = Color(0xFF1B2D3F);

ThemeData buildBunkaiDarkTheme() {
  const seed = Color(0xFFAF272F);
  var scheme = ColorScheme.fromSeed(
    seedColor: seed,
    brightness: Brightness.dark,
    surface: _kSurface,
    surfaceContainerHighest: _kSurfaceHigh,
  );
  scheme = scheme.copyWith(
    primary: const Color(0xFFAF272F),
    onPrimary: const Color(0xFFFFFFFF),
    primaryContainer: const Color(0xFF3A1014),
    onPrimaryContainer: const Color(0xFFF4C8CB),
    secondary: const Color(0xFF1A567A),
    onSecondary: const Color(0xFFE5E9EB),
    secondaryContainer: const Color(0xFF0E2C40),
    onSecondaryContainer: const Color(0xFFB8D4E5),
    tertiary: const Color(0xFF003057),
    onTertiary: const Color(0xFFE5E9EB),
    surface: _kSurface,
    onSurface: const Color(0xFFE5E9EB),
    onSurfaceVariant: const Color(0xFFB8C2CC),
    outline: const Color(0xFF2A4358),
    outlineVariant: const Color(0xFF1F3346),
  );

  final baseText = GoogleFonts.notoSansJpTextTheme(
    Typography.whiteMountainView,
  );

  return ThemeData(
    useMaterial3: true,
    colorScheme: scheme,
    scaffoldBackgroundColor: _kScaffold,
    fontFamily: GoogleFonts.notoSansJp().fontFamily,
    textTheme: baseText.copyWith(
      displaySmall: baseText.displaySmall?.copyWith(
        fontWeight: FontWeight.w600,
        letterSpacing: -0.5,
        height: 1.2,
      ),
      titleLarge: baseText.titleLarge?.copyWith(
        letterSpacing: 0.15,
        fontWeight: FontWeight.w600,
        height: 1.35,
      ),
      titleMedium: baseText.titleMedium?.copyWith(
        letterSpacing: 0.12,
        fontWeight: FontWeight.w600,
        height: 1.4,
      ),
      bodyLarge: baseText.bodyLarge?.copyWith(
        letterSpacing: 0.06,
        height: 1.5,
        fontWeight: FontWeight.w400,
      ),
      bodyMedium: baseText.bodyMedium?.copyWith(
        letterSpacing: 0.04,
        height: 1.45,
      ),
      bodySmall: baseText.bodySmall?.copyWith(
        letterSpacing: 0.03,
        height: 1.4,
      ),
      labelLarge: baseText.labelLarge?.copyWith(
        letterSpacing: 0.35,
        fontWeight: FontWeight.w600,
      ),
      labelMedium: baseText.labelMedium?.copyWith(
        letterSpacing: 0.25,
        fontWeight: FontWeight.w500,
      ),
      labelSmall: baseText.labelSmall?.copyWith(
        letterSpacing: 0.2,
        fontWeight: FontWeight.w500,
      ),
    ),
    cardTheme: CardThemeData(
      elevation: 0,
      color: scheme.surfaceContainerHighest,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: BorderSide(color: scheme.outlineVariant.withValues(alpha: 0.45)),
      ),
    ),
    dividerTheme: DividerThemeData(
      color: scheme.outlineVariant.withValues(alpha: 0.4),
    ),
    appBarTheme: AppBarTheme(
      elevation: 0,
      scrolledUnderElevation: 0,
      backgroundColor: _kScaffold,
      foregroundColor: scheme.onSurface,
      centerTitle: false,
      titleTextStyle: GoogleFonts.notoSansJp(
        color: scheme.onSurface,
        fontSize: 18,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.15,
      ),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    ),
    extensions: const <ThemeExtension<dynamic>>[
      BunkaiFeedbackColors.dark,
    ],
  );
}
