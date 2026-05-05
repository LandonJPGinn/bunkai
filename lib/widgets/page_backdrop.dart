import 'package:flutter/material.dart';

import '../app/bunkai_tokens.dart';

/// Radial wash + page base color (spec: subtle gradients, no image assets).
class PageBackdrop extends StatelessWidget {
  const PageBackdrop({super.key, this.child});

  final Widget? child;

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
                  const HSLColor.fromAHSL(
                    1,
                    205 / 360,
                    1,
                    0.62,
                  ).toColor().withValues(alpha: 0.14),
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
                  const HSLColor.fromAHSL(
                    1,
                    318 / 360,
                    0.7,
                    0.66,
                  ).toColor().withValues(alpha: 0.12),
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
                  const HSLColor.fromAHSL(
                    1,
                    36 / 360,
                    0.95,
                    0.6,
                  ).toColor().withValues(alpha: 0.08),
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
