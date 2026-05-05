import 'dart:math' as math;
import 'dart:ui' show lerpDouble;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../app/bunkai_tokens.dart';
import '../data/topic_card_style.dart';
import '../models/quiz_id.dart';

class QuizCard extends StatefulWidget {
  const QuizCard({
    super.key,
    required this.quizId,
    required this.title,
    required this.subtitle,
    required this.description,
    required this.tags,
    required this.difficulty,
    required this.onStart,
  });

  final QuizId quizId;
  final String title;
  final String subtitle;
  final String description;
  final List<String> tags;
  final String difficulty;
  final VoidCallback onStart;

  @override
  State<QuizCard> createState() => _QuizCardState();
}

class _QuizCardState extends State<QuizCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _motion;
  late final FocusNode _focusNode;

  bool _hover = false;
  Offset _parallax = Offset.zero;

  /// PERF: Decorative drift waits until after first layout — avoids competing with grid layout/paint.
  bool _motionReady = false;

  static const double _radius = 28;

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode(debugLabel: 'QuizCard:${widget.title}');
    _focusNode.addListener(() {
      setState(() {});
      _scheduleDecorMotionSync();
    });
    _motion = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 9),
    );
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      setState(() => _motionReady = true);
      _scheduleDecorMotionSync();
    });
  }

  /// PERF: [AnimationController.repeat] must not run while idle — [TickerMode]
  /// does not mute a controller created on this [State]'s ticker.
  void _scheduleDecorMotionSync() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _syncDecorMotion();
    });
  }

  void _syncDecorMotion() {
    if (!mounted) return;
    final reduceMotion = MediaQuery.disableAnimationsOf(context);
    final active =
        _motionReady && !reduceMotion && (_hover || _focusNode.hasFocus);
    if (active) {
      if (!_motion.isAnimating) _motion.repeat();
    } else if (_motion.isAnimating) {
      _motion.stop();
      _motion.reset();
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _scheduleDecorMotionSync();
  }

  @override
  void dispose() {
    _motion.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _onPointerMove(
    PointerEvent e,
    BoxConstraints constraints,
    bool reduceMotion,
  ) {
    if (reduceMotion) return;
    final lp = e.localPosition;
    final nx = (lp.dx / constraints.maxWidth - 0.5) * 2;
    final ny = (lp.dy / constraints.maxHeight - 0.5) * 2;
    final px = nx.clamp(-1.0, 1.0) * 10;
    final py = ny.clamp(-1.0, 1.0) * 8;
    setState(() => _parallax = Offset(px, py));
  }

  KeyEventResult _onKey(FocusNode node, KeyEvent event) {
    if (event is! KeyDownEvent) return KeyEventResult.ignored;
    if (event.logicalKey == LogicalKeyboardKey.enter ||
        event.logicalKey == LogicalKeyboardKey.space) {
      widget.onStart();
      return KeyEventResult.handled;
    }
    return KeyEventResult.ignored;
  }

  @override
  Widget build(BuildContext context) {
    final style = topicCardStyleFor(widget.quizId);
    final reduceMotion = MediaQuery.of(context).disableAnimations;
    final tokens = context.bunkaiTokens;
    final focused = _focusNode.hasFocus;
    final lift = _hover && !reduceMotion;
    final kanjiBright = _hover || focused;
    final decorMotionActive =
        _motionReady && !reduceMotion && (_hover || focused);

    final tagList = widget.tags.take(4).toList(growable: false);
    final desc = widget.description.trim();
    final showDesc = desc.isNotEmpty;
    final showSubtitle = widget.subtitle.trim().isNotEmpty;

    final semanticsLabel =
        '${widget.title}. ${widget.difficulty}. Double tap or press Enter to start.';

    return LayoutBuilder(
      builder: (context, constraints) {
        final w = constraints.maxWidth;
        final h = constraints.maxHeight;
        final kanjiSize = (w * 0.92).clamp(120.0, 260.0);
        final titleSize = (w * 0.10).clamp(20.0, 30.0);
        final subtitleSize = (w * 0.032).clamp(12.0, 14.0);
        final descSize = (w * 0.028).clamp(11.0, 13.0);

        final shadow = lift ? tokens.shadowCard : tokens.shadowSoft;

        final cardStack = ClipRRect(
          borderRadius: BorderRadius.circular(_radius),
          clipBehavior: Clip.antiAlias,
          child: Stack(
            clipBehavior: Clip.hardEdge,
            fit: StackFit.expand,
            children: [
              _GradientBackdrop(style: style, radius: _radius),
              if (decorMotionActive)
                _NoiseAndSweepLayer(
                  animation: _motion,
                  reduceMotion: reduceMotion,
                  height: h,
                  width: w,
                ),
              _BackdropKanji(
                kanji: style.kanji,
                tiltDegrees: style.tiltDegrees,
                fontSize: kanjiSize,
                parallax: reduceMotion ? Offset.zero : _parallax,
                bright: kanjiBright,
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.title,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            fontSize: titleSize,
                            fontWeight: FontWeight.w900,
                            height: 0.92,
                            letterSpacing: -1.0,
                            color: Colors.white,
                          ),
                    ),
                    if (showSubtitle) ...[
                      SizedBox(height: (w * 0.018).clamp(5.0, 8.0)),
                      Text(
                        widget.subtitle,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style:
                            Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontSize: subtitleSize,
                                  fontWeight: FontWeight.w600,
                                  height: 1.32,
                                  color: Colors.white.withValues(alpha: 0.88),
                                ),
                      ),
                    ],
                    if (showDesc) ...[
                      SizedBox(height: (w * 0.02).clamp(6.0, 10.0)),
                      Text(
                        desc,
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              fontSize: descSize,
                              fontWeight: FontWeight.w400,
                              height: 1.38,
                              color: Colors.white.withValues(alpha: 0.78),
                            ),
                      ),
                    ],
                    if (tagList.isNotEmpty) ...[
                      SizedBox(height: (w * 0.022).clamp(8.0, 12.0)),
                      Wrap(
                        spacing: 6,
                        runSpacing: 6,
                        children: [
                          for (final tag in tagList)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 3,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.black.withValues(alpha: 0.22),
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(
                                  color: Colors.white.withValues(alpha: 0.28),
                                ),
                              ),
                              child: Text(
                                tag,
                                style: Theme.of(context)
                                    .textTheme
                                    .labelMedium
                                    ?.copyWith(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w600,
                                      letterSpacing: 0.15,
                                      color: Colors.white.withValues(alpha: 0.88),
                                    ),
                              ),
                            ),
                        ],
                      ),
                    ],
                    const Spacer(),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        _DifficultyCapsule(label: widget.difficulty),
                        const Spacer(),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 10,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.92),
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.18),
                                offset: const Offset(0, 4),
                                blurRadius: 12,
                              ),
                            ],
                          ),
                          child: Text(
                            'Start',
                            style: Theme.of(context)
                                .textTheme
                                .labelLarge
                                ?.copyWith(
                                  fontWeight: FontWeight.w700,
                                  color: style.accent,
                                  fontSize: 13,
                                ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        );

        return MergeSemantics(
          child: Semantics(
            button: true,
            label: semanticsLabel,
            onTap: widget.onStart,
            child: Focus(
              focusNode: _focusNode,
              onKeyEvent: _onKey,
              child: AnimatedContainer(
                duration: reduceMotion
                    ? Duration.zero
                    : const Duration(milliseconds: 220),
                curve: Curves.easeOutCubic,
                transform: Matrix4.translationValues(0, lift ? -5 : 0, 0),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(_radius),
                  boxShadow: shadow,
                ),
                child: Material(
                  color: Colors.transparent,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(_radius),
                      border: Border.all(
                        color: focused
                            ? tokens.accent.withValues(alpha: 0.95)
                            : Colors.white.withValues(alpha: 0.14),
                        width: focused ? 2.5 : 1,
                      ),
                    ),
                    child: Listener(
                      onPointerMove: (e) =>
                          _onPointerMove(e, constraints, reduceMotion),
                      onPointerHover: (_) {},
                      child: MouseRegion(
                        onEnter: (_) {
                          setState(() => _hover = true);
                          _scheduleDecorMotionSync();
                        },
                        onExit: (_) {
                          setState(() {
                            _hover = false;
                            _parallax = Offset.zero;
                          });
                          _scheduleDecorMotionSync();
                        },
                        child: InkWell(
                          onTap: widget.onStart,
                          borderRadius: BorderRadius.circular(_radius),
                          hoverColor: Colors.white.withValues(alpha: 0.06),
                          splashColor: Colors.white.withValues(alpha: 0.12),
                          child: cardStack,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _GradientBackdrop extends StatelessWidget {
  const _GradientBackdrop({required this.style, required this.radius});

  final TopicCardStyle style;
  final double radius;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [style.bg1, style.bg2],
        ),
      ),
      child: Stack(
        fit: StackFit.expand,
        children: [
          DecoratedBox(
            decoration: BoxDecoration(
              gradient: RadialGradient(
                center: const Alignment(-0.55, -0.55),
                radius: 0.85,
                colors: [style.bg2.withValues(alpha: 0.95), Colors.transparent],
                stops: const [0.0, 0.55],
              ),
            ),
          ),
          DecoratedBox(
            decoration: BoxDecoration(
              border: Border.all(color: Colors.white.withValues(alpha: 0.14)),
              borderRadius: BorderRadius.circular(radius),
            ),
          ),
        ],
      ),
    );
  }
}

class _BackdropKanji extends StatelessWidget {
  const _BackdropKanji({
    required this.kanji,
    required this.tiltDegrees,
    required this.fontSize,
    required this.parallax,
    required this.bright,
  });

  final String kanji;
  final double tiltDegrees;
  final double fontSize;
  final Offset parallax;
  final bool bright;

  @override
  Widget build(BuildContext context) {
    final baseOpacity = bright ? 0.68 : 0.58;
    return ExcludeSemantics(
      child: IgnorePointer(
        child: Align(
          alignment: Alignment.bottomLeft,
          child: Transform.translate(
            offset: Offset(-6 + parallax.dx, 18 + parallax.dy),
            child: Transform.rotate(
              angle: tiltDegrees * math.pi / 180,
              alignment: Alignment.bottomLeft,
              child: Text(
                kanji,
                style: Theme.of(context).textTheme.displayMedium?.copyWith(
                      fontSize: fontSize,
                      fontWeight: FontWeight.w900,
                      height: 0.75,
                      letterSpacing: -fontSize * 0.05,
                      color: Colors.white.withValues(alpha: baseOpacity),
                    ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Dot sparkle + light sweep — gated by parent [TickerMode] (hover/focus only).
class _NoiseAndSweepLayer extends StatelessWidget {
  const _NoiseAndSweepLayer({
    required this.animation,
    required this.reduceMotion,
    required this.width,
    required this.height,
  });

  final Animation<double> animation;
  final bool reduceMotion;
  final double width;
  final double height;

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: AnimatedBuilder(
        animation: animation,
        builder: (context, child) {
          final t = reduceMotion ? 0.0 : animation.value;
          final phase = t * math.pi * 2;
          final ox = math.sin(phase) * 11.0;
          final oy = math.cos(phase * 0.85) * 7.2;
          final sweepShift = math.sin(phase) * 0.5 + 0.5;

          return Stack(
            fit: StackFit.expand,
            children: [
              Transform.translate(
                offset: Offset(ox, oy),
                child: _ParticleDots(width: width, height: height),
              ),
              IgnorePointer(
                child: Opacity(
                  opacity: lerpDouble(0.68, 0.82, sweepShift)!,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment(
                          -1.0 + math.sin(phase) * 0.4,
                          -0.2 + math.cos(phase * 0.7) * 0.08,
                        ),
                        end: Alignment(
                          1.2 - math.sin(phase * 0.9) * 0.3,
                          0.35 + math.cos(phase) * 0.05,
                        ),
                        colors: [
                          Colors.transparent,
                          Colors.white.withValues(alpha: 0.14),
                          Colors.transparent,
                        ],
                        stops: const [0.38, 0.48, 0.62],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

/// Sparse radial “dust” without CustomPainter: fixed alignment offsets.
class _ParticleDots extends StatelessWidget {
  const _ParticleDots({required this.width, required this.height});

  final double width;
  final double height;

  @override
  Widget build(BuildContext context) {
    final dots = <Widget>[
      _dot(0.12, 0.18, 0.34),
      _dot(0.72, 0.12, 0.24),
      _dot(0.38, 0.78, 0.26),
      _dot(0.84, 0.72, 0.18),
      _dot(0.48, 0.42, 0.22),
      _dot(0.22, 0.62, 0.2),
    ];
    return Stack(fit: StackFit.expand, children: dots);
  }

  Widget _dot(double fx, double fy, double a) {
    return Positioned(
      left: width * fx,
      top: height * fy,
      child: Container(
        width: 2,
        height: 2,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.white.withValues(alpha: a),
          boxShadow: [
            BoxShadow(
              color: Colors.white.withValues(alpha: a * 0.8),
              blurRadius: 1.2,
            ),
          ],
        ),
      ),
    );
  }
}

class _DifficultyCapsule extends StatelessWidget {
  const _DifficultyCapsule({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.16),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.white.withValues(alpha: 0.35)),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelMedium?.copyWith(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.12,
              color: Colors.white.withValues(alpha: 0.92),
            ),
      ),
    );
  }
}
