import 'package:flutter/material.dart';

import '../app/bunkai_tokens.dart';
import '../app/color/oklch.dart';

/// Radial wash + page base color (spec: subtle gradients, no image assets).
class PageBackdrop extends StatelessWidget {
  const PageBackdrop({super.key, this.child});

  final Widget? child;

  // OKLCH equivalents of the prior `HSLColor.fromAHSL` washes.
  static final Color _washBlue =
      const Oklch(0.725, 0.154, 244.3, 0.14).toColor();
  static final Color _washPink =
      const Oklch(0.701, 0.179, 340.3, 0.12).toColor();
  static final Color _washGold =
      const Oklch(0.802, 0.153, 72.4, 0.08).toColor();

  @override
  Widget build(BuildContext context) {
    final pageBg = context.bunkaiTokens.pageBg;
    return Stack(
      fit: StackFit.expand,
      children: [
        ColoredBox(color: pageBg),
        Positioned.fill(
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: RadialGradient(
                center: const Alignment(-0.75, -0.9),
                radius: 1.15,
                colors: [
                  _washBlue,
                  Colors.transparent,
                ],
                stops: const [0, 0.45],
              ),
            ),
          ),
        ),
        Positioned.fill(
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: RadialGradient(
                center: const Alignment(0.9, -0.85),
                radius: 1.1,
                colors: [
                  _washPink,
                  Colors.transparent,
                ],
                stops: const [0, 0.5],
              ),
            ),
          ),
        ),
        Positioned.fill(
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: RadialGradient(
                center: const Alignment(0, 1.0),
                radius: 1.0,
                colors: [
                  _washGold,
                  Colors.transparent,
                ],
                stops: const [0, 0.55],
              ),
            ),
          ),
        ),
        if (child != null) child!,
      ],
    );
  }
}
