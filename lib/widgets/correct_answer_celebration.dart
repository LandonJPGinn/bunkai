import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../app/bunkai_feedback_theme.dart';
import '../app/color/oklch.dart';
import '../app/color/oklch_glow.dart';

/// Chrome, motion, and overlays for a submitted correct answer card.
class CorrectAnswerCelebrationFrame extends StatefulWidget {
  const CorrectAnswerCelebrationFrame({
    super.key,
    required this.reduceMotion,
    required this.feedback,
    required this.scheme,
    required this.onTap,
    required this.leading,
    this.borderRadius = 16,
  });

  final bool reduceMotion;
  final BunkaiFeedbackColors feedback;
  final ColorScheme scheme;
  final VoidCallback? onTap;
  final Widget leading;
  final double borderRadius;

  @override
  State<CorrectAnswerCelebrationFrame> createState() =>
      _CorrectAnswerCelebrationFrameState();
}

class _CorrectAnswerCelebrationFrameState extends State<CorrectAnswerCelebrationFrame>
    with SingleTickerProviderStateMixin {
  static const Duration _kDuration = Duration(milliseconds: 880);

  late final AnimationController _controller;
  late final Animation<double> _master;

  late final Animation<double> _cardScale;
  late final Animation<double> _cardTy;
  late final Animation<double> _shimmerSlide;
  late final Animation<double> _shimmerOpacity;

  late final Animation<double> _sparkleOpacity;
  late final Animation<double> _sparkleScale;
  late final Animation<double> _sparkleTy;

  late final Animation<double> _checkScale;
  late final Animation<double> _checkTurn;

  late final Animation<double> _kanjiOpacity;
  late final Animation<double> _kanjiTy;
  late final Animation<double> _kanjiScale;

  static const Cubic _easeOutBack = Cubic(0.16, 1.0, 0.3, 1.0);

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: _kDuration);
    _master = CurvedAnimation(parent: _controller, curve: Curves.linear);

    _cardScale = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween(begin: 1.0, end: 1.028).chain(
          CurveTween(curve: Curves.easeOut),
        ),
        weight: 34,
      ),
      TweenSequenceItem(
        tween: Tween(begin: 1.028, end: 1.0).chain(
          CurveTween(curve: _easeOutBack),
        ),
        weight: 66,
      ),
    ]).animate(_master);

    _cardTy = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween(begin: 0.0, end: -4.0).chain(
          CurveTween(curve: Curves.easeOut),
        ),
        weight: 34,
      ),
      TweenSequenceItem(
        tween: Tween(begin: -4.0, end: 0.0).chain(
          CurveTween(curve: _easeOutBack),
        ),
        weight: 66,
      ),
    ]).animate(_master);

    _shimmerOpacity = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween(begin: 0.0, end: 1.0).chain(
          CurveTween(curve: Curves.easeOut),
        ),
        weight: 25,
      ),
      TweenSequenceItem(
        tween: ConstantTween<double>(1.0),
        weight: 40,
      ),
      TweenSequenceItem(
        tween: Tween(begin: 1.0, end: 0.0).chain(
          CurveTween(curve: Curves.easeIn),
        ),
        weight: 35,
      ),
    ]).animate(_master);

    _shimmerSlide = Tween(begin: -1.15, end: 1.15).animate(
      CurvedAnimation(parent: _master, curve: const Interval(0.0, 0.82, curve: Curves.easeOut)),
    );

    _sparkleOpacity = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween(begin: 0.0, end: 1.0).chain(
          CurveTween(curve: Curves.easeOut),
        ),
        weight: 34,
      ),
      TweenSequenceItem(
        tween: Tween(begin: 1.0, end: 0.0).chain(
          CurveTween(curve: Curves.easeOut),
        ),
        weight: 66,
      ),
    ]).animate(_master);

    _sparkleScale = Tween(begin: 0.92, end: 1.06).animate(
      CurvedAnimation(parent: _master, curve: const Interval(0.0, 1.0, curve: Curves.easeOut)),
    );

    _sparkleTy = Tween(begin: 6.0, end: -10.0).animate(
      CurvedAnimation(parent: _master, curve: const Interval(0.0, 1.0, curve: Curves.easeOut)),
    );

    _checkScale = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween(begin: 0.72, end: 1.18).chain(
          CurveTween(curve: Curves.easeOut),
        ),
        weight: 45,
      ),
      TweenSequenceItem(
        tween: Tween(begin: 1.18, end: 1.0).chain(
          CurveTween(curve: _easeOutBack),
        ),
        weight: 55,
      ),
    ]).animate(_master);

    _checkTurn = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween(begin: -16.0, end: 6.0).chain(
          CurveTween(curve: Curves.easeOut),
        ),
        weight: 45,
      ),
      TweenSequenceItem(
        tween: Tween(begin: 6.0, end: 0.0).chain(
          CurveTween(curve: _easeOutBack),
        ),
        weight: 55,
      ),
    ]).animate(_master);

    _kanjiOpacity = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween(begin: 0.0, end: 1.0).chain(
          CurveTween(curve: Curves.easeOut),
        ),
        weight: 36,
      ),
      TweenSequenceItem(
        tween: Tween(begin: 1.0, end: 0.7).chain(
          CurveTween(curve: Curves.easeInOut),
        ),
        weight: 64,
      ),
    ]).animate(_master);

    _kanjiTy = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween(begin: 18.0, end: -4.0).chain(
          CurveTween(curve: Curves.easeOut),
        ),
        weight: 36,
      ),
      TweenSequenceItem(
        tween: Tween(begin: -4.0, end: 0.0).chain(
          CurveTween(curve: _easeOutBack),
        ),
        weight: 64,
      ),
    ]).animate(_master);

    _kanjiScale = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween(begin: 0.94, end: 1.04).chain(
          CurveTween(curve: Curves.easeOut),
        ),
        weight: 36,
      ),
      TweenSequenceItem(
        tween: Tween(begin: 1.04, end: 1.0).chain(
          CurveTween(curve: _easeOutBack),
        ),
        weight: 64,
      ),
    ]).animate(_master);

    if (!widget.reduceMotion) {
      _controller.forward();
    } else {
      _controller.value = 1.0;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  // OKLCH-derived backdrops (formerly `Color(0xFF15261C)` / `Color(0xFF1C1820)`).
  static final Color _topTintBg = const Oklch(0.250, 0.030, 157.6).toColor();
  static final Color _botCoolBg = const Oklch(0.217, 0.017, 307.6).toColor();

  Color _accent() => widget.feedback.correct;

  Color _checkBg() {
    final base = _accent();
    return Color.lerp(base, Oklch.white.toColor(), 0.38)!;
  }

  Color _checkFg() =>
      Color.lerp(widget.scheme.surface, Oklch.black.toColor(), 0.55)!;

  BoxDecoration _successDecoration() {
    final c = _accent();
    final bright = _checkBg();
    final topTint = Color.alphaBlend(
      c.withValues(alpha: 0.42),
      _topTintBg,
    );
    final botCool = Color.alphaBlend(
      widget.scheme.primary.withValues(alpha: 0.12),
      _botCoolBg,
    );
    return BoxDecoration(
      borderRadius: BorderRadius.circular(widget.borderRadius),
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          topTint,
          botCool,
        ],
      ),
      border: Border.all(
        color: bright.withValues(alpha: 0.72),
        width: 1.4,
      ),
      boxShadow: [
        // Spillover from `correctGlow` (l > 1.0) — only fires when the OKLCH
        // lightness exceeds 1.0, otherwise this is a `const []` no-op.
        ...glowShadowsFor(
          widget.feedback.correctGlow,
          blur: 36,
          spread: -4,
          offset: const Offset(0, 18),
        ),
        BoxShadow(
          color: bright.withValues(alpha: 0.34),
          blurRadius: 0,
          spreadRadius: 1,
          offset: Offset.zero,
        ),
        BoxShadow(
          color: c.withValues(alpha: 0.26),
          blurRadius: 48,
          spreadRadius: -6,
          offset: const Offset(0, 22),
        ),
        BoxShadow(
          color: whiteAlpha(0.06),
          blurRadius: 0,
          spreadRadius: 1,
          offset: Offset.zero,
        ),
      ],
    );
  }

  Widget _radialGlowBehind() {
    final bright = _checkBg();
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(widget.borderRadius),
        gradient: RadialGradient(
          center: const Alignment(-0.55, -0.62),
          radius: 0.85,
          colors: [
            bright.withValues(alpha: 0.24),
            Colors.transparent,
          ],
          stops: const [0.0, 0.55],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bright = _checkBg();

    Widget core({required bool animate}) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(widget.borderRadius),
        clipBehavior: Clip.hardEdge,
        child: Stack(
          clipBehavior: Clip.hardEdge,
          children: [
            Positioned.fill(child: _radialGlowBehind()),
            Positioned.fill(
              child: DecoratedBox(decoration: _successDecoration()),
            ),
            // Additive (BlendMode.plus) perimeter halo driven by `correctGlow`'s
            // overshoot. Sits on top of the decoration so it adds light over
            // the gradient instead of just tinting it.
            Positioned.fill(
              child: OklchGlowLayer(
                oklch: widget.feedback.correctGlow,
                shape: BoxShape.rectangle,
                borderRadius: BorderRadius.circular(widget.borderRadius),
                blur: 40,
                opacityScale: 0.55,
                inset: 2,
              ),
            ),
            if (animate)
              AnimatedBuilder(
                animation: _master,
                builder: (context, _) {
                  return Positioned.fill(
                    child: IgnorePointer(
                      child: Opacity(
                        opacity: _shimmerOpacity.value,
                        child: LayoutBuilder(
                          builder: (context, constraints) {
                            final w = constraints.maxWidth;
                            final h = constraints.maxHeight;
                            final slide = _shimmerSlide.value * w * 0.85;
                            return ClipRect(
                              child: OverflowBox(
                                maxWidth: w * 2.4,
                                maxHeight: h * 2.4,
                                alignment: Alignment.center,
                                child: Transform.rotate(
                                  angle: 8 * math.pi / 180,
                                  child: Transform.translate(
                                    offset: Offset(slide, 0),
                                    child: ShaderMask(
                                      blendMode: BlendMode.srcIn,
                                      shaderCallback: (rect) {
                                        return LinearGradient(
                                          begin: Alignment.centerLeft,
                                          end: Alignment.centerRight,
                                          colors: [
                                            Colors.transparent,
                                            whiteAlpha(0.08),
                                            whiteAlpha(0.42),
                                            whiteAlpha(0.08),
                                            Colors.transparent,
                                          ],
                                          stops: const [0.34, 0.42, 0.49, 0.56, 0.66],
                                        ).createShader(rect);
                                      },
                                      child: Container(
                                        width: w * 1.6,
                                        height: h * 2,
                                        color: Oklch.white.toColor(),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  );
                },
              ),
            if (animate)
              AnimatedBuilder(
                animation: _master,
                builder: (context, _) {
                  return Positioned.fill(
                    child: IgnorePointer(
                      child: Transform.translate(
                        offset: Offset(0, _sparkleTy.value),
                        child: Transform.scale(
                          scale: _sparkleScale.value,
                          alignment: Alignment.center,
                          child: Opacity(
                            opacity: _sparkleOpacity.value,
                            child: CustomPaint(
                              painter: _SparklePainter(
                                bright: Oklch.fromColor(widget.feedback.correct),
                                soft: Oklch.fromColor(bright),
                                white: Oklch.white,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            Positioned(
              right: 36,
              bottom: -10,
              child: IgnorePointer(
                child: ExcludeSemantics(
                  child: animate
                      ? AnimatedBuilder(
                          animation: _master,
                          builder: (context, _) {
                            return Transform.translate(
                              offset: Offset(0, _kanjiTy.value),
                              child: Transform.scale(
                                scale: _kanjiScale.value,
                                alignment: Alignment.bottomRight,
                                child: Opacity(
                                  opacity: _kanjiOpacity.value,
                                  child: Transform.rotate(
                                    angle: -8 * math.pi / 180,
                                    child: Text(
                                      '正',
                                      style: Theme.of(context)
                                          .textTheme
                                          .displayMedium!
                                          .copyWith(
                                                fontSize: 112,
                                                fontWeight: FontWeight.w900,
                                                height: 1,
                                                color: Color.lerp(
                                                  Oklch.white.toColor(),
                                                  widget.feedback.correct,
                                                  0.22,
                                                )!.withValues(alpha: 0.12),
                                              ),
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                        )
                      : Transform.rotate(
                          angle: -8 * math.pi / 180,
                          child: Text(
                            '正',
                            style: Theme.of(context)
                                .textTheme
                                .displayMedium!
                                .copyWith(
                              fontSize: 112,
                              fontWeight: FontWeight.w900,
                              height: 1,
                              color: Color.lerp(
                                    Oklch.white.toColor(),
                                    widget.feedback.correct,
                                    0.22,
                                  )!
                                  .withValues(alpha: 0.1),
                            ),
                          ),
                        ),
                ),
              ),
            ),
            Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: widget.onTap,
                borderRadius: BorderRadius.circular(widget.borderRadius),
                splashColor: bright.withValues(alpha: 0.18),
                highlightColor: bright.withValues(alpha: 0.08),
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(child: widget.leading),
                      const SizedBox(width: 12),
                      ExcludeSemantics(
                        child: animate
                            ? AnimatedBuilder(
                                animation: _master,
                                builder: (context, _) {
                                  return Transform.rotate(
                                    angle: _checkTurn.value * math.pi / 180,
                                    child: Transform.scale(
                                      scale: _checkScale.value,
                                      alignment: Alignment.center,
                                      child: _CheckBadge(
                                        bg: bright,
                                        fg: _checkFg(),
                                        glow: _accent(),
                                        glowSpec: widget.feedback.correctGlow,
                                      ),
                                    ),
                                  );
                                },
                              )
                            : _CheckBadge(
                                bg: bright,
                                fg: _checkFg(),
                                glow: _accent(),
                                glowSpec: widget.feedback.correctGlow,
                              ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    }

    if (widget.reduceMotion) {
      return core(animate: false);
    }

    return AnimatedBuilder(
      animation: _master,
      builder: (context, child) {
        final scale = _cardScale.value;
        final ty = _cardTy.value;
        return Transform.translate(
          offset: Offset(0, ty),
          child: Transform.scale(
            scale: scale,
            alignment: Alignment.center,
            child: child,
          ),
        );
      },
      child: core(animate: true),
    );
  }
}

class _CheckBadge extends StatelessWidget {
  const _CheckBadge({
    required this.bg,
    required this.fg,
    required this.glow,
    required this.glowSpec,
  });

  final Color bg;
  final Color fg;
  final Color glow;

  /// OKLCH spec for the over-bright glow. When `glowSpec.l > 1.0` an additive
  /// halo (BlendMode.plus) is painted behind the badge in addition to the
  /// standard tinted shadows.
  final Oklch glowSpec;

  @override
  Widget build(BuildContext context) {
    final c = glow;
    final badge = Container(
      width: 42,
      height: 42,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: bg,
        boxShadow: [
          // No-op when glowSpec.l <= 1.0, otherwise a soft spillover shadow
          // sized to the OKLCH overshoot.
          ...glowShadowsFor(glowSpec, blur: 28),
          BoxShadow(
            color: c.withValues(alpha: 0.14),
            blurRadius: 0,
            spreadRadius: 6,
          ),
          BoxShadow(
            color: c.withValues(alpha: 0.28),
            blurRadius: 26,
            spreadRadius: -4,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      alignment: Alignment.center,
      child: Icon(Icons.check_rounded, size: 26, color: fg),
    );
    if (!glowSpec.hasGlow) return badge;
    // Stack with overflow so the additive halo can bleed past the 42x42 badge.
    return SizedBox(
      width: 42,
      height: 42,
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.center,
        children: [
          Positioned(
            left: -22,
            right: -22,
            top: -22,
            bottom: -22,
            child: OklchGlowLayer(
              oklch: glowSpec,
              shape: BoxShape.circle,
              blur: 30,
              opacityScale: 0.8,
              inset: 18,
            ),
          ),
          badge,
        ],
      ),
    );
  }
}

class _SparklePainter extends CustomPainter {
  _SparklePainter({
    required this.bright,
    required this.soft,
    required this.white,
  });

  final Oklch bright;
  final Oklch soft;
  final Oklch white;

  @override
  void paint(Canvas canvas, Size size) {
    void dot(double x, double y, double r, Color color, {bool additive = false}) {
      final p = Offset(x * size.width, y * size.height);
      final paint = Paint()..color = color;
      if (additive) paint.blendMode = BlendMode.plus;
      canvas.drawCircle(p, r, paint);
    }

    // Brightest two dots paint additively so they read as light, not paint.
    dot(0.14, 0.34, 2.0, white.withAlpha(0.95).toColor(), additive: true);
    dot(
      0.24,
      0.72,
      2.0,
      bright.mix(soft, 0.35).withAlpha(0.92).toColor(),
      additive: true,
    );
    dot(0.54, 0.22, 1.5, white.withAlpha(0.72).toColor());
    dot(0.68, 0.66, 1.8, bright.withAlpha(0.75).toColor());
    dot(0.86, 0.36, 1.6, soft.withAlpha(0.85).toColor());
  }

  @override
  bool shouldRepaint(covariant _SparklePainter oldDelegate) => false;
}
