import 'package:flutter/material.dart';

// PERF: Use local platform font stacks so first paint never waits on web fonts.

import 'jpquizapp_feedback_theme.dart';
import 'jpquizapp_tokens.dart';
import 'color/oklch.dart';

Color _oklch(double l, double c, double h) => Oklch(l, c, h).toColor();

const String _primaryFontFamily = 'Segoe UI';
const List<String> _fontFallback = [
  'Roboto',
  'Helvetica Neue',
  'Arial',
  'Noto Sans JP',
  'Yu Gothic',
  'Meiryo',
  'Hiragino Sans',
  'sans-serif',
];

ThemeData buildJpQuizAppDarkTheme() {
  final tokens = JpQuizAppTokens.dark;
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
    primaryContainer: _oklch(0.2815, 0.0354, 240.74),
    onPrimaryContainer: _oklch(0.9165, 0.0507, 229.62),
    secondary: _oklch(0.6148, 0.1725, 340.83),
    onSecondary: tokens.textStrong,
    secondaryContainer: _oklch(0.2924, 0.0611, 327.00),
    onSecondaryContainer: _oklch(0.8953, 0.0346, 338.03),
    tertiary: _oklch(0.7858, 0.1520, 72.09),
    onTertiary: _oklch(0.1815, 0.0156, 275.92),
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

  final interBase = Typography.whiteMountainView.apply(
    fontFamily: _primaryFontFamily,
    fontFamilyFallback: _fontFallback,
    bodyColor: tokens.textMain,
    displayColor: tokens.textStrong,
  );
  final textTheme = interBase.copyWith(
    displaySmall: interBase.displaySmall?.copyWith(
      fontWeight: FontWeight.w700,
      letterSpacing: -0.6,
      height: 1.15,
      color: tokens.textStrong,
    ),
    headlineMedium: interBase.headlineMedium?.copyWith(
      fontWeight: FontWeight.w700,
      letterSpacing: -0.4,
      height: 1.2,
      color: tokens.textStrong,
    ),
    titleLarge: interBase.titleLarge?.copyWith(
      letterSpacing: 0.02,
      fontWeight: FontWeight.w700,
      height: 1.35,
      color: tokens.textStrong,
    ),
    titleMedium: interBase.titleMedium?.copyWith(
      letterSpacing: 0.03,
      fontWeight: FontWeight.w600,
      height: 1.4,
      color: tokens.textStrong,
    ),
    titleSmall: interBase.titleSmall?.copyWith(
      letterSpacing: 0.04,
      fontWeight: FontWeight.w600,
      height: 1.35,
      color: tokens.textMain,
    ),
    bodyLarge: interBase.bodyLarge?.copyWith(
      letterSpacing: 0.02,
      height: 1.55,
      fontWeight: FontWeight.w400,
      color: tokens.textMain,
    ),
    bodyMedium: interBase.bodyMedium?.copyWith(
      letterSpacing: 0.02,
      height: 1.5,
      color: tokens.textMain,
    ),
    bodySmall: interBase.bodySmall?.copyWith(
      letterSpacing: 0.02,
      height: 1.45,
      color: tokens.textMuted,
    ),
    labelLarge: interBase.labelLarge?.copyWith(
      letterSpacing: 0.4,
      fontWeight: FontWeight.w600,
      color: tokens.textMain,
    ),
    labelMedium: interBase.labelMedium?.copyWith(
      letterSpacing: 0.28,
      fontWeight: FontWeight.w500,
      color: tokens.textMuted,
    ),
    labelSmall: interBase.labelSmall?.copyWith(
      letterSpacing: 0.22,
      fontWeight: FontWeight.w500,
      color: tokens.textMuted,
    ),
  );

  return ThemeData(
    useMaterial3: true,
    colorScheme: scheme,
    scaffoldBackgroundColor: pageBg,
    fontFamily: _primaryFontFamily,
    fontFamilyFallback: _fontFallback,
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
      titleTextStyle: TextStyle(
        fontFamily: _primaryFontFamily,
        fontFamilyFallback: _fontFallback,
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
    extensions: <ThemeExtension<dynamic>>[
      JpQuizAppFeedbackColors.dark,
      JpQuizAppTokens.dark,
    ],
  );
}

// OKLCH equivalents of the prior `Color(0xFF0D1118)` / `Color(0xFFFAFAFA)`
// constants — resolved once and reused on every contrast lookup.
final Color _highContrastDark = const Oklch(0.1768, 0.0159, 261.52).toColor();
final Color _highContrastLight = const Oklch(0.9851, 0.000, 89.88).toColor();

Color _highContrastOn(Color background) {
  final luminance = background.computeLuminance();
  return luminance > 0.45 ? _highContrastDark : _highContrastLight;
}
