import 'package:bunkai/app/color/oklch.dart';
import 'package:bunkai/app/color/oklch_glow.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Oklch.toColor', () {
    test('Oklch.white round-trips to sRGB white', () {
      final c = Oklch.white.toColor();
      expect((c.r * 255).round(), 255);
      expect((c.g * 255).round(), 255);
      expect((c.b * 255).round(), 255);
      expect((c.a * 255).round(), 255);
    });

    test('Oklch.black round-trips to sRGB black', () {
      final c = Oklch.black.toColor();
      expect((c.r * 255).round(), 0);
      expect((c.g * 255).round(), 0);
      expect((c.b * 255).round(), 0);
    });

    test('Oklch.transparent has zero alpha', () {
      final c = Oklch.transparent.toColor();
      expect((c.a * 255).round(), 0);
    });

    test('alpha is preserved through conversion', () {
      final c = Oklch.white.withAlpha(0.5).toColor();
      expect((c.a * 255).round(), closeTo(128, 1));
    });

    test('Oklch.fromColor → toColor round-trips within 1 unit', () {
      // Cover a few representative tokens used across the app.
      const samples = <int>[
        0xFF3DCC7A, // success green
        0xFFE85D7A, // danger pink
        0xFFF5C84A, // warning gold
        0xFF3FA9FF, // accent blue
        0xFF0E1018, // page bg
        0xFFD6DCE8, // text main
      ];
      for (final argb in samples) {
        final original = Color(argb);
        final round = Oklch.fromColor(original).toColor();
        expect(
          (round.r * 255).round(),
          closeTo((original.r * 255).round(), 1),
          reason: 'r mismatch on 0x${argb.toRadixString(16)}',
        );
        expect(
          (round.g * 255).round(),
          closeTo((original.g * 255).round(), 1),
          reason: 'g mismatch on 0x${argb.toRadixString(16)}',
        );
        expect(
          (round.b * 255).round(),
          closeTo((original.b * 255).round(), 1),
          reason: 'b mismatch on 0x${argb.toRadixString(16)}',
        );
      }
    });

    test('l > 1.0 clamps to sRGB but preserves overshoot', () {
      const glow = Oklch(1.05, 0.18, 145.0);
      expect(glow.hasGlow, isTrue);
      expect(glow.overshoot, closeTo(0.05, 1e-9));
      // Renders to a valid sRGB color (not NaN, not over 255).
      final c = glow.toColor();
      expect((c.r * 255).round(), inInclusiveRange(0, 255));
      expect((c.g * 255).round(), inInclusiveRange(0, 255));
      expect((c.b * 255).round(), inInclusiveRange(0, 255));
    });
  });

  group('Oklch arithmetic', () {
    test('mix walks the shortest hue arc', () {
      const a = Oklch(0.5, 0.1, 350.0);
      const b = Oklch(0.5, 0.1, 10.0);
      // Crossing 0/360, midpoint should be near 0/360, NOT near 180.
      final m = a.mix(b, 0.5);
      final wrappedHue = (m.h + 720) % 360;
      // Midpoint: 350 + (-340/2) = 350 - 170 = 180? No — shortest arc goes
      // 350 → 10 via +20 degrees, midpoint hue 360 (i.e. 0).
      expect(wrappedHue, closeTo(0, 1));
    });

    test('lighter / darker shift l only', () {
      const base = Oklch(0.5, 0.12, 200);
      expect(base.lighter(0.1).l, closeTo(0.6, 1e-9));
      expect(base.darker(0.1).l, closeTo(0.4, 1e-9));
      expect(base.lighter().c, base.c);
      expect(base.lighter().h, base.h);
    });

    test('hasGlow false for normal lightness', () {
      const normal = Oklch(0.9, 0.1, 200);
      expect(normal.hasGlow, isFalse);
      expect(normal.overshoot, 0.0);
    });
  });

  group('glowShadowsFor', () {
    test('returns empty list when l <= 1.0', () {
      const flat = Oklch(0.95, 0.18, 145);
      expect(glowShadowsFor(flat), isEmpty);
    });

    test('returns one shadow for tiny overshoot', () {
      const tinyGlow = Oklch(1.02, 0.18, 145);
      final shadows = glowShadowsFor(tinyGlow);
      expect(shadows, hasLength(1));
    });

    test('returns two shadows once overshoot crosses 0.05', () {
      const bigGlow = Oklch(1.10, 0.18, 145);
      final shadows = glowShadowsFor(bigGlow);
      expect(shadows, hasLength(2));
      // Outer shadow has the larger blur.
      expect(shadows.last.blurRadius, greaterThan(shadows.first.blurRadius));
    });

    test('blur grows monotonically with overshoot', () {
      const small = Oklch(1.02, 0.18, 145);
      const large = Oklch(1.20, 0.18, 145);
      final smallBlur = glowShadowsFor(small).single.blurRadius;
      final largeBlur = glowShadowsFor(large).last.blurRadius;
      expect(largeBlur, greaterThan(smallBlur));
    });

    test('opacityScale scales the alpha channel', () {
      const glow = Oklch(1.10, 0.18, 145);
      final dim = glowShadowsFor(glow, opacityScale: 0.25).last.color.a;
      final full = glowShadowsFor(glow, opacityScale: 1.0).last.color.a;
      expect(dim, lessThan(full));
    });
  });

  group('whiteAlpha / blackAlpha helpers', () {
    test('whiteAlpha matches Oklch.white.withAlpha(a).toColor()', () {
      final a = whiteAlpha(0.42);
      final b = Oklch.white.withAlpha(0.42).toColor();
      expect(a.toARGB32(), b.toARGB32());
    });

    test('blackAlpha matches Oklch.black.withAlpha(a).toColor()', () {
      final a = blackAlpha(0.18);
      final b = Oklch.black.withAlpha(0.18).toColor();
      expect(a.toARGB32(), b.toARGB32());
    });
  });
}
