import 'package:flutter/material.dart';

/// Design tokens (plan: CSS variables as Flutter [ThemeExtension]).
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

  // HSL-matched approximations for const construction.
  static const Color _pageBg = Color(0xFF0E1018);
  static const Color _surface1 = Color(0xFF141722);
  static const Color _surface2 = Color(0xFF1A1E2A);
  static const Color _surface3 = Color(0xFF212532);
  static const Color _accent = Color(0xFF3FA9FF);

  static const List<BoxShadow> kShadowSoft = [
    BoxShadow(color: Color(0x47000000), offset: Offset(0, 18), blurRadius: 60),
  ];

  static const List<BoxShadow> kShadowCard = [
    BoxShadow(color: Color(0x61000000), offset: Offset(0, 24), blurRadius: 80),
  ];

  static const BunkaiTokens dark = BunkaiTokens(
    pageBg: _pageBg,
    surface1: _surface1,
    surface2: _surface2,
    surface3: _surface3,
    textStrong: Color(0xFFFAFAFA),
    textMain: Color(0xFFD6DCE8),
    textMuted: Color(0xFF9BA3B0),
    borderSoft: Color(0x1AFFFFFF),
    borderStrong: Color(0x2EFFFFFF),
    accent: _accent,
    accentSoft: Color(0x293FA9FF),
    radiusSm: 12,
    radiusMd: 18,
    radiusLg: 28,
    shadowSoft: BunkaiTokens.kShadowSoft,
    shadowCard: BunkaiTokens.kShadowCard,
    maxContentWidth: 1180,
    brandMark: '語',
    headerHeight: 52,
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
    );
  }
}

extension BunkaiTokensX on BuildContext {
  BunkaiTokens get bunkaiTokens =>
      Theme.of(this).extension<BunkaiTokens>() ?? BunkaiTokens.dark;
}
