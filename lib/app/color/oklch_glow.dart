import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'oklch.dart';

/// Drop-in [BoxShadow]s that approximate the spillover light from an
/// over-bright [oklch] (where `l > 1.0`). Returns `const []` when [oklch] has
/// no overshoot, so callers can spread the result into existing shadow stacks
/// without conditionals:
///
/// ```dart
/// boxShadow: [
///   ...glowShadowsFor(tokens.correctGlow, blur: 28),
///   const BoxShadow(...),
/// ]
/// ```
///
/// [BoxShadow] cannot use `BlendMode.plus`, so this is a perceptual
/// approximation; for true additive light over textured backgrounds, layer
/// [OklchGlowLayer] on top instead.
List<BoxShadow> glowShadowsFor(
  Oklch oklch, {
  double blur = 24,
  double spread = 0,
  Offset offset = Offset.zero,
  double opacityScale = 1.0,
}) {
  final overshoot = oklch.overshoot;
  if (overshoot <= 0) return const <BoxShadow>[];
  final base = oklch.withL(1.0).toColor();
  final outer = BoxShadow(
    color: base.withValues(
      alpha: (overshoot * 0.6 * opacityScale).clamp(0.0, 1.0),
    ),
    blurRadius: blur + overshoot * 80,
    spreadRadius: spread,
    offset: offset,
  );
  if (overshoot <= 0.05) return <BoxShadow>[outer];
  final inner = BoxShadow(
    color: base.withValues(
      alpha: (overshoot * 0.9 * opacityScale).clamp(0.0, 1.0),
    ),
    blurRadius: blur * 0.4 + overshoot * 20,
    spreadRadius: spread - 1,
    offset: offset,
  );
  return <BoxShadow>[inner, outer];
}

/// Paints an additive (`BlendMode.plus`) halo whose intensity comes from
/// [Oklch.overshoot].
///
/// On textured or gradient backgrounds a normal [BoxShadow] just darkens the
/// surround; this layer literally adds light, so an `Oklch(1.05, 0.18, 145)`
/// reads as a glow rather than a tint. The widget collapses to a zero-size
/// box when [oklch] has no overshoot, so it can be dropped into a [Stack]
/// unconditionally.
class OklchGlowLayer extends StatelessWidget {
  const OklchGlowLayer({
    super.key,
    required this.oklch,
    this.shape = BoxShape.rectangle,
    this.borderRadius,
    this.blur = 28.0,
    this.opacityScale = 1.0,
    this.inset = 0.0,
  });

  /// Source color whose [Oklch.overshoot] drives blur and intensity.
  final Oklch oklch;

  /// Shape of the glow source.
  final BoxShape shape;

  /// Corner radius when [shape] is [BoxShape.rectangle].
  final BorderRadius? borderRadius;

  /// Base blur radius before [Oklch.overshoot] amplification.
  final double blur;

  /// Multiplier on the additive alpha; lower for subtler glow.
  final double opacityScale;

  /// Optional inset (in logical px) applied to the painted shape so the
  /// blur tail stays inside the parent bounds. Use negative values when the
  /// parent already clips and you want the halo to bleed past content.
  final double inset;

  @override
  Widget build(BuildContext context) {
    if (!oklch.hasGlow) return const SizedBox.shrink();
    return IgnorePointer(
      child: CustomPaint(
        size: Size.infinite,
        painter: _OklchGlowPainter(
          oklch: oklch,
          shape: shape,
          borderRadius: borderRadius,
          blur: blur,
          opacityScale: opacityScale,
          inset: inset,
        ),
      ),
    );
  }
}

class _OklchGlowPainter extends CustomPainter {
  _OklchGlowPainter({
    required this.oklch,
    required this.shape,
    required this.borderRadius,
    required this.blur,
    required this.opacityScale,
    required this.inset,
  });

  final Oklch oklch;
  final BoxShape shape;
  final BorderRadius? borderRadius;
  final double blur;
  final double opacityScale;
  final double inset;

  @override
  void paint(Canvas canvas, Size size) {
    final overshoot = oklch.overshoot;
    if (overshoot <= 0) return;
    final base = oklch.withL(1.0).toColor();
    final blurRadius = blur + overshoot * 80;
    final rect = (Offset.zero & size).deflate(inset);
    if (rect.width <= 0 || rect.height <= 0) return;

    void drawHalo(double sigma, double alpha) {
      final paint = Paint()
        ..blendMode = BlendMode.plus
        ..color = base.withValues(alpha: alpha.clamp(0.0, 1.0))
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, sigma);
      if (shape == BoxShape.circle) {
        final radius = math.min(rect.width, rect.height) / 2;
        canvas.drawCircle(rect.center, radius, paint);
      } else if (borderRadius != null) {
        canvas.drawRRect(borderRadius!.toRRect(rect), paint);
      } else {
        canvas.drawRect(rect, paint);
      }
    }

    drawHalo(blurRadius * 0.5, overshoot * 0.55 * opacityScale);
    if (overshoot > 0.05) {
      drawHalo(blurRadius * 0.18, overshoot * 0.85 * opacityScale);
    }
  }

  @override
  bool shouldRepaint(covariant _OklchGlowPainter oldDelegate) {
    return oldDelegate.oklch != oklch ||
        oldDelegate.shape != shape ||
        oldDelegate.borderRadius != borderRadius ||
        oldDelegate.blur != blur ||
        oldDelegate.opacityScale != opacityScale ||
        oldDelegate.inset != inset;
  }
}
