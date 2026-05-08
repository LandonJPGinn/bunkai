import 'package:flutter/material.dart';

import 'color/oklch.dart';

/// Design tokens (plan: CSS variables as Flutter [ThemeExtension]).
///
/// Every static color is sourced from an OKLCH literal and resolved to sRGB
/// once at startup; downstream consumers still receive plain [Color] values so
/// `Color.lerp` in [lerp] keeps interpolating in sRGB.
@immutable
class BunkaiTokens extends ThemeExtension<BunkaiTokens> {
  const BunkaiTokens({
    required this.pageBg,
    required this.surface1,
    required this.surface2,
    required this.surface3,
    required this.textStrong,
    required this.textMain,
    required this.textMuted,
    required this.borderSoft,
    required this.borderStrong,
    required this.accent,
    required this.accentSoft,
    required this.radiusSm,
    required this.radiusMd,
    required this.radiusLg,
    required this.shadowSoft,
    required this.shadowCard,
    required this.maxContentWidth,
    required this.brandMark,
    required this.headerHeight,
    required this.motionFast,
    required this.motionMedium,
    required this.motionSlow,
    required this.motionStandardCurve,
    required this.motionEmphasizedCurve,
  });

  final Color pageBg;
  final Color surface1;
  final Color surface2;
  final Color surface3;
  final Color textStrong;
  final Color textMain;
  final Color textMuted;
  final Color borderSoft;
  final Color borderStrong;
  final Color accent;
  final Color accentSoft;
  final double radiusSm;
  final double radiusMd;
  final double radiusLg;
  final List<BoxShadow> shadowSoft;
  final List<BoxShadow> shadowCard;
  final double maxContentWidth;
  final String brandMark;
  final double headerHeight;

  // Motion tokens: shared durations + curves for hover/focus/layout transitions.
  // Keep these in lockstep so the entire site reads as one motion system.
  final Duration motionFast;
  final Duration motionMedium;
  final Duration motionSlow;
  final Curve motionStandardCurve;
  final Curve motionEmphasizedCurve;

  // OKLCH source-of-truth values. Cool dark theme: low-L, low-C, hue ~270.
  static final Color _pageBg = const Oklch(0.175, 0.017, 273.6).toColor();
  static final Color _surface1 = const Oklch(0.207, 0.022, 272.5).toColor();
  static final Color _surface2 = const Oklch(0.237, 0.024, 270.2).toColor();
  static final Color _surface3 = const Oklch(0.266, 0.025, 271.3).toColor();
  static final Color _accent = const Oklch(0.714, 0.158, 247.1).toColor();

  // Pure black tints; alpha encodes the shadow strength.
  static final List<BoxShadow> kShadowSoft = <BoxShadow>[
    BoxShadow(
      color: const Oklch(0, 0, 0, 0.278).toColor(),
      offset: const Offset(0, 18),
      blurRadius: 60,
    ),
  ];

  static final List<BoxShadow> kShadowCard = <BoxShadow>[
    BoxShadow(
      color: const Oklch(0, 0, 0, 0.380).toColor(),
      offset: const Offset(0, 24),
      blurRadius: 80,
    ),
  ];

  static final BunkaiTokens dark = BunkaiTokens(
    pageBg: _pageBg,
    surface1: _surface1,
    surface2: _surface2,
    surface3: _surface3,
    textStrong: const Oklch(0.985, 0.000, 89.9).toColor(),
    textMain: const Oklch(0.894, 0.018, 264.5).toColor(),
    textMuted: const Oklch(0.713, 0.021, 260.2).toColor(),
    borderSoft: const Oklch(1.0, 0.0, 0.0, 0.102).toColor(),
    borderStrong: const Oklch(1.0, 0.0, 0.0, 0.180).toColor(),
    accent: _accent,
    accentSoft: const Oklch(0.714, 0.158, 247.1, 0.161).toColor(),
    radiusSm: 12,
    radiusMd: 18,
    radiusLg: 28,
    shadowSoft: kShadowSoft,
    shadowCard: kShadowCard,
    maxContentWidth: 1180,
    brandMark: '語',
    headerHeight: 52,
    motionFast: const Duration(milliseconds: 140),
    motionMedium: const Duration(milliseconds: 220),
    motionSlow: const Duration(milliseconds: 320),
    motionStandardCurve: Curves.easeOutCubic,
    motionEmphasizedCurve: Curves.easeOutQuart,
  );

  @override
  BunkaiTokens copyWith({
    Color? pageBg,
    Color? surface1,
    Color? surface2,
    Color? surface3,
    Color? textStrong,
    Color? textMain,
    Color? textMuted,
    Color? borderSoft,
    Color? borderStrong,
    Color? accent,
    Color? accentSoft,
    double? radiusSm,
    double? radiusMd,
    double? radiusLg,
    List<BoxShadow>? shadowSoft,
    List<BoxShadow>? shadowCard,
    double? maxContentWidth,
    String? brandMark,
    double? headerHeight,
    Duration? motionFast,
    Duration? motionMedium,
    Duration? motionSlow,
    Curve? motionStandardCurve,
    Curve? motionEmphasizedCurve,
  }) {
    return BunkaiTokens(
      pageBg: pageBg ?? this.pageBg,
      surface1: surface1 ?? this.surface1,
      surface2: surface2 ?? this.surface2,
      surface3: surface3 ?? this.surface3,
      textStrong: textStrong ?? this.textStrong,
      textMain: textMain ?? this.textMain,
      textMuted: textMuted ?? this.textMuted,
      borderSoft: borderSoft ?? this.borderSoft,
      borderStrong: borderStrong ?? this.borderStrong,
      accent: accent ?? this.accent,
      accentSoft: accentSoft ?? this.accentSoft,
      radiusSm: radiusSm ?? this.radiusSm,
      radiusMd: radiusMd ?? this.radiusMd,
      radiusLg: radiusLg ?? this.radiusLg,
      shadowSoft: shadowSoft ?? this.shadowSoft,
      shadowCard: shadowCard ?? this.shadowCard,
      maxContentWidth: maxContentWidth ?? this.maxContentWidth,
      brandMark: brandMark ?? this.brandMark,
      headerHeight: headerHeight ?? this.headerHeight,
      motionFast: motionFast ?? this.motionFast,
      motionMedium: motionMedium ?? this.motionMedium,
      motionSlow: motionSlow ?? this.motionSlow,
      motionStandardCurve: motionStandardCurve ?? this.motionStandardCurve,
      motionEmphasizedCurve: motionEmphasizedCurve ?? this.motionEmphasizedCurve,
    );
  }

  @override
  BunkaiTokens lerp(ThemeExtension<BunkaiTokens>? other, double t) {
    if (other is! BunkaiTokens) return this;
    return BunkaiTokens(
      pageBg: Color.lerp(pageBg, other.pageBg, t)!,
      surface1: Color.lerp(surface1, other.surface1, t)!,
      surface2: Color.lerp(surface2, other.surface2, t)!,
      surface3: Color.lerp(surface3, other.surface3, t)!,
      textStrong: Color.lerp(textStrong, other.textStrong, t)!,
      textMain: Color.lerp(textMain, other.textMain, t)!,
      textMuted: Color.lerp(textMuted, other.textMuted, t)!,
      borderSoft: Color.lerp(borderSoft, other.borderSoft, t)!,
      borderStrong: Color.lerp(borderStrong, other.borderStrong, t)!,
      accent: Color.lerp(accent, other.accent, t)!,
      accentSoft: Color.lerp(accentSoft, other.accentSoft, t)!,
      radiusSm: radiusSm + (other.radiusSm - radiusSm) * t,
      radiusMd: radiusMd + (other.radiusMd - radiusMd) * t,
      radiusLg: radiusLg + (other.radiusLg - radiusLg) * t,
      shadowSoft: t < 0.5 ? shadowSoft : other.shadowSoft,
      shadowCard: t < 0.5 ? shadowCard : other.shadowCard,
      maxContentWidth:
          maxContentWidth + (other.maxContentWidth - maxContentWidth) * t,
      brandMark: t < 0.5 ? brandMark : other.brandMark,
      headerHeight: headerHeight + (other.headerHeight - headerHeight) * t,
      motionFast: t < 0.5 ? motionFast : other.motionFast,
      motionMedium: t < 0.5 ? motionMedium : other.motionMedium,
      motionSlow: t < 0.5 ? motionSlow : other.motionSlow,
      motionStandardCurve:
          t < 0.5 ? motionStandardCurve : other.motionStandardCurve,
      motionEmphasizedCurve:
          t < 0.5 ? motionEmphasizedCurve : other.motionEmphasizedCurve,
    );
  }
}

extension BunkaiTokensX on BuildContext {
  BunkaiTokens get bunkaiTokens =>
      Theme.of(this).extension<BunkaiTokens>() ?? BunkaiTokens.dark;
}
