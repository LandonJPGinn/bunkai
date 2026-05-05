import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../app/bunkai_feedback_theme.dart';

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

  Color _accent() => widget.feedback.correct;

  Color _checkBg() {
    final base = _accent();
    return Color.lerp(base, Colors.white, 0.38)!;
  }

  Color _checkFg() => Color.lerp(widget.scheme.surface, Colors.black, 0.55)!;

  BoxDecoration _successDecoration() {
    final c = _accent();
    final bright = _checkBg();
    final topTint = Color.alphaBlend(
      c.withValues(alpha: 0.42),
      const Color(0xFF15261C),
    );
    final botCool = Color.alphaBlend(
      widget.scheme.primary.withValues(alpha: 0.12),
      const Color(0xFF1C1820),
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
          color: Colors.white.withValues(alpha: 0.06),
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
                                            Colors.white.withValues(alpha: 0.08),
                                            Colors.white.withValues(alpha: 0.42),
                                            Colors.white.withValues(alpha: 0.08),
                                            Colors.transparent,
                                          ],
                                          stops: const [0.34, 0.42, 0.49, 0.56, 0.66],
                                        ).createShader(rect);
                                      },
                                      child: Container(
                                        width: w * 1.6,
                                        height: h * 2,
                                        color: Colors.white,
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
                                bright: widget.feedback.correct,
                                soft: bright,
                                white: Colors.white,
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
                                              Colors.white,
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
                                        Colors.white,
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
                                      ),
                                    ),
                                  );
                                },
                              )
                            : _CheckBadge(
                                bg: bright,
                                fg: _checkFg(),
                                glow: _accent(),
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
  });

  final Color bg;
  final Color fg;
  final Color glow;

  @override
  Widget build(BuildContext context) {
    final c = glow;
    return Container(
      width: 42,
      height: 42,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: bg,
        boxShadow: [
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
  }
}

class _SparklePainter extends CustomPainter {
  _SparklePainter({
    required this.bright,
    required this.soft,
    required this.white,
  });

  final Color bright;
  final Color soft;
  final Color white;

  @override
  void paint(Canvas canvas, Size size) {
    void dot(double x, double y, double r, Color color) {
      final p = Offset(x * size.width, y * size.height);
      canvas.drawCircle(p, r, Paint()..color = color);
    }

    dot(0.14, 0.34, 2.0, white.withValues(alpha: 0.95));
    dot(0.24, 0.72, 2.0, Color.lerp(bright, soft, 0.35)!.withValues(alpha: 0.92));
    dot(0.54, 0.22, 1.5, white.withValues(alpha: 0.72));
    dot(0.68, 0.66, 1.8, bright.withValues(alpha: 0.75));
    dot(0.86, 0.36, 1.6, soft.withValues(alpha: 0.85));
  }

  @override
  bool shouldRepaint(covariant _SparklePainter oldDelegate) => false;
}
