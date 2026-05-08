import 'dart:math' as math;

import 'package:flutter/material.dart';

/// Perceptually uniform color in OKLCH (Oklab's cylindrical form).
///
/// Lightness [l] is allowed to exceed `1.0`; values above `1.0` clamp to white
/// when rendered to sRGB but expose the excess via [overshoot] so that
/// additive glow primitives in `oklch_glow.dart` can amplify highlights for
/// success animations.
@immutable
class Oklch {
  const Oklch(this.l, this.c, this.h, [this.alpha = 1.0]);

  /// Lightness. `0.0` is black, `1.0` is white. Values `> 1.0` are preserved
  /// verbatim and surface through [overshoot] for additive glow.
  final double l;

  /// Chroma (saturation). Typically in `[0, 0.4]`; clamped to gamut at
  /// conversion time.
  final double c;

  /// Hue in degrees `[0, 360)`.
  final double h;

  /// Alpha in `[0, 1]`.
  final double alpha;

  static const Oklch transparent = Oklch(0, 0, 0, 0);
  static const Oklch white = Oklch(1.0, 0.0, 0.0);
  static const Oklch black = Oklch(0.0, 0.0, 0.0);

  /// True when [l] exceeds `1.0`, signalling the renderer to add an additive
  /// glow on top of the clamped sRGB color.
  bool get hasGlow => l > 1.0;

  /// Amount of lightness above sRGB white, capped at `1.0`. Drives glow blur
  /// radius and additive alpha in `oklch_glow.dart`.
  double get overshoot => l > 1.0 ? (l - 1.0).clamp(0.0, 1.0) : 0.0;

  Oklch withL(double newL) => Oklch(newL, c, h, alpha);
  Oklch withC(double newC) => Oklch(l, newC, h, alpha);
  Oklch withH(double newH) => Oklch(l, c, newH, alpha);
  Oklch withAlpha(double newAlpha) => Oklch(l, c, h, newAlpha);

  Oklch lighter([double amount = 0.05]) => Oklch(l + amount, c, h, alpha);
  Oklch darker([double amount = 0.05]) =>
      Oklch((l - amount).clamp(0.0, double.infinity), c, h, alpha);

  /// Perceptual mix between two OKLCH values; interpolates lightness/chroma
  /// linearly and walks the shortest arc around the hue circle.
  Oklch mix(Oklch other, double t) {
    final dh = ((other.h - h + 540) % 360) - 180;
    return Oklch(
      l + (other.l - l) * t,
      c + (other.c - c) * t,
      h + dh * t,
      alpha + (other.alpha - alpha) * t,
    );
  }

  /// Render to sRGB, clamping `l` to `1.0` and per-channel values to `[0, 1]`.
  Color toColor() {
    final lForRgb = l > 1.0 ? 1.0 : (l < 0.0 ? 0.0 : l);
    final hRad = h * math.pi / 180.0;
    final aLab = c * math.cos(hRad);
    final bLab = c * math.sin(hRad);

    final lin = _labToLinearRgb(lForRgb, aLab, bLab);
    final r = _linearToSrgb(lin.$1.clamp(0.0, 1.0));
    final g = _linearToSrgb(lin.$2.clamp(0.0, 1.0));
    final b = _linearToSrgb(lin.$3.clamp(0.0, 1.0));
    final aByte = (alpha.clamp(0.0, 1.0) * 255 + 0.5).floor();
    return Color.fromARGB(
      aByte,
      (r * 255 + 0.5).floor(),
      (g * 255 + 0.5).floor(),
      (b * 255 + 0.5).floor(),
    );
  }

  /// Recover an OKLCH spec from an sRGB [Color]. Useful when migrating
  /// existing hex literals.
  factory Oklch.fromColor(Color color) {
    final r = _srgbToLinear(color.r);
    final g = _srgbToLinear(color.g);
    final b = _srgbToLinear(color.b);
    final lab = _linearRgbToLab(r, g, b);
    final chroma = math.sqrt(lab.$2 * lab.$2 + lab.$3 * lab.$3);
    var hue = math.atan2(lab.$3, lab.$2) * 180.0 / math.pi;
    if (hue < 0) hue += 360.0;
    return Oklch(lab.$1, chroma, hue, color.a);
  }

  // Oklab → linear-light sRGB.
  static (double, double, double) _labToLinearRgb(
    double L,
    double a,
    double b,
  ) {
    final lQuad = L + 0.3963377774 * a + 0.2158037573 * b;
    final mQuad = L - 0.1055613458 * a - 0.0638541728 * b;
    final sQuad = L - 0.0894841775 * a - 1.2914855480 * b;
    final lc = lQuad * lQuad * lQuad;
    final mc = mQuad * mQuad * mQuad;
    final sc = sQuad * sQuad * sQuad;
    return (
      4.0767416621 * lc - 3.3077115913 * mc + 0.2309699292 * sc,
      -1.2684380046 * lc + 2.6097574011 * mc - 0.3413193965 * sc,
      -0.0041960863 * lc - 0.7034186147 * mc + 1.7076147010 * sc,
    );
  }

  // Linear-light sRGB → Oklab.
  static (double, double, double) _linearRgbToLab(
    double r,
    double g,
    double b,
  ) {
    final lLms = 0.4122214708 * r + 0.5363325363 * g + 0.0514459929 * b;
    final mLms = 0.2119034982 * r + 0.6806995451 * g + 0.1073969566 * b;
    final sLms = 0.0883024619 * r + 0.2817188376 * g + 0.6299787005 * b;
    final lRoot = _cbrt(lLms);
    final mRoot = _cbrt(mLms);
    final sRoot = _cbrt(sLms);
    return (
      0.2104542553 * lRoot + 0.7936177850 * mRoot - 0.0040720468 * sRoot,
      1.9779984951 * lRoot - 2.4285922050 * mRoot + 0.4505937099 * sRoot,
      0.0259040371 * lRoot + 0.7827717662 * mRoot - 0.8086757660 * sRoot,
    );
  }

  static double _srgbToLinear(double v) {
    if (v <= 0.04045) return v / 12.92;
    return math.pow((v + 0.055) / 1.055, 2.4).toDouble();
  }

  static double _linearToSrgb(double v) {
    if (v <= 0.0031308) return 12.92 * v;
    return 1.055 * math.pow(v, 1 / 2.4).toDouble() - 0.055;
  }

  static double _cbrt(double v) {
    if (v == 0) return 0;
    final sign = v.isNegative ? -1.0 : 1.0;
    return sign * math.pow(v.abs(), 1 / 3.0).toDouble();
  }

  @override
  bool operator ==(Object other) =>
      other is Oklch &&
      other.l == l &&
      other.c == c &&
      other.h == h &&
      other.alpha == alpha;

  @override
  int get hashCode => Object.hash(l, c, h, alpha);

  @override
  String toString() =>
      'Oklch(l: ${l.toStringAsFixed(3)}, c: ${c.toStringAsFixed(3)}, '
      'h: ${h.toStringAsFixed(1)}, alpha: ${alpha.toStringAsFixed(3)})';
}

/// Shorthand for `Oklch.white.withAlpha(a).toColor()` — the most common
/// migration target for `Colors.white.withValues(alpha: a)`.
Color whiteAlpha(double a) => Oklch.white.withAlpha(a).toColor();

/// Shorthand for `Oklch.black.withAlpha(a).toColor()` — the migration target
/// for `Colors.black.withValues(alpha: a)`.
Color blackAlpha(double a) => Oklch.black.withAlpha(a).toColor();
