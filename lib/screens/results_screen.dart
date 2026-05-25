import 'dart:math';

import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';

import '../app/app_router.dart';
import '../app/jpquizapp_tokens.dart';
import '../app/color/oklch.dart';
import '../data/topic_card_style.dart';
import '../services/practice_session_builder.dart';
import '../services/quiz_bank_loader.dart';
import '../services/quiz_practice_settings_store.dart';
import '../app/breakpoints.dart';
import '../services/score_service.dart';
import '../widgets/app_shell.dart' show AppShell, AppShellHeaderMode;
import '../widgets/primary_button.dart';
import '../widgets/results_needs_review_section.dart';
import '../widgets/quiz_practice_settings_sheet.dart';
import '../widgets/results_score_summary.dart';
import '../widgets/results_strongest_section.dart';

class ResultsScreen extends StatefulWidget {
  const ResultsScreen({super.key, required this.args});

  final ResultsRouteArgs args;

  @override
  State<ResultsScreen> createState() => _ResultsScreenState();
}

// OKLCH-derived confetti palette (formerly hard-coded sRGB hex).
final List<Color> _confettiPalette = <Color>[
  const Oklch(0.7505, 0.1687, 153.58).toColor(),
  const Oklch(0.8408, 0.1167, 207.67).toColor(),
  const Oklch(0.8504, 0.1478, 88.78).toColor(),
  const Oklch(0.6634, 0.1731, 10.36).toColor(),
];

class _ResultsScreenState extends State<ResultsScreen> {
  static const _score = ScoreService();

  late ConfettiController _confetti;
  bool _confettiPlayScheduled = false;

  Future<void> _retryWithSavedSettings() async {
    final result = widget.args.result;
    try {
      final base = await QuizBankLoader.instance.ensureQuizLoaded(
        result.quizId,
      );
      final settings = await QuizPracticeSettingsStore.instance.load(
        result.quizId,
        availableSettings: derivePracticeAvailableSettings(base),
      );
      if (!mounted) return;
      final session = buildPracticeSessionQuiz(base, settings: settings);
      Navigator.of(context).pushReplacementNamed(
        AppRoutes.quiz,
        arguments: QuizRouteArgs(quiz: session),
      );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.maybeOf(context)?.showSnackBar(
        const SnackBar(content: Text('Could not load quiz. Try again.')),
      );
    }
  }

  Future<void> _openSettings() async {
    final result = widget.args.result;
    try {
      final base = await QuizBankLoader.instance.ensureQuizLoaded(
        result.quizId,
      );
      final current = await QuizPracticeSettingsStore.instance.load(
        result.quizId,
        availableSettings: derivePracticeAvailableSettings(base),
      );
      if (!mounted) return;
      final updated = await showQuizPracticeSettingsSheet(
        context: context,
        quiz: base,
        initialSettings: current,
      );
      if (updated == null) return;
      await QuizPracticeSettingsStore.instance.save(result.quizId, updated);
      if (!mounted) return;
      ScaffoldMessenger.maybeOf(context)?.showSnackBar(
        SnackBar(
          content: Text(
            'Saved: ${updated.countLabel} questions, ${updated.summaryLabel}.',
          ),
        ),
      );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.maybeOf(context)?.showSnackBar(
        const SnackBar(content: Text('Could not open quiz settings.')),
      );
    }
  }

  @override
  void initState() {
    super.initState();
    _confetti = ConfettiController(duration: const Duration(seconds: 4));
  }

  @override
  void dispose() {
    _confetti.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_confettiPlayScheduled) return;
    _confettiPlayScheduled = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final reduceMotion = MediaQuery.disableAnimationsOf(context);
      if (_score.showConfetti(widget.args.result) && !reduceMotion) {
        _confetti.play();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final result = widget.args.result;
    final percent = _score.percentRounded(result);
    final passing = _score.isPassing(result);
    final headline = _score.resultsHeadline(result);
    final showConfettiLayer =
        _score.showConfetti(result) && !MediaQuery.disableAnimationsOf(context);

    final misses = result.diagnosticMisses;
    final tagsInRun = result.diagnosticTagsInRun;

    final strongestTags = tagsInRun.where((t) => (misses[t] ?? 0) == 0).toList()
      ..sort();

    final sortedMisses = misses.entries.toList()
      ..sort((a, b) {
        final c = b.value.compareTo(a.value);
        if (c != 0) return c;
        return a.key.compareTo(b.key);
      });

    final width = MediaQuery.sizeOf(context).width;
    final phone = LayoutBreakpoints.isPhoneWidth(width);
    final narrow = LayoutBreakpoints.isNarrowWidth(width);
    final horizontalPadding = phone
        ? 4.0
        : narrow
        ? 16.0
        : 20.0;

    return AppShell(
      headerMode: AppShellHeaderMode.compact,
      title: 'Results',
      body: Stack(
        children: [
          Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 560),
              child: Padding(
                padding: EdgeInsets.fromLTRB(
                  horizontalPadding,
                  phone ? 4 : 8,
                  horizontalPadding,
                  phone ? 12 : 16,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Expanded(
                      child: LayoutBuilder(
                        builder: (context, constraints) {
                          final tokens = context.jpQuizAppTokens;
                          final reduceMotion = MediaQuery.of(
                            context,
                          ).disableAnimations;
                          final motionSlow = reduceMotion
                              ? Duration.zero
                              : tokens.motionSlow;
                          return SingleChildScrollView(
                            clipBehavior: Clip.none,
                            child: ConstrainedBox(
                              constraints: BoxConstraints(
                                minHeight: constraints.maxHeight,
                              ),
                              // AnimatedSize allows the page to settle smoothly
                              // when conditional sections appear or disappear.
                              child: AnimatedSize(
                                duration: motionSlow,
                                curve: tokens.motionEmphasizedCurve,
                                alignment: Alignment.topCenter,
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment:
                                      CrossAxisAlignment.stretch,
                                  children: [
                                    _SlideFadeIn(
                                      child: ResultsScoreSummary(
                                        headline: headline,
                                        quizTitle: widget.args.quizTitle,
                                        percent: percent,
                                        correctCount: result.correctCount,
                                        totalCount: result.totalCount,
                                        isPassing: passing,
                                      ),
                                    ),
                                    const SizedBox(height: 24),
                                    if (strongestTags.isNotEmpty) ...[
                                      _SlideFadeIn(
                                        child: ResultsStrongestSection(
                                          tags: strongestTags,
                                        ),
                                      ),
                                      const SizedBox(height: 24),
                                    ],
                                    if (sortedMisses.isNotEmpty)
                                      _SlideFadeIn(
                                        child: ResultsNeedsReviewSection(
                                          sortedMisses: sortedMisses,
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 16),
                    PrimaryButton(
                      label: 'Try again',
                      backgroundColor: topicCardStyleFor(result.quizId).accent,
                      onPressed: _retryWithSavedSettings,
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        style: OutlinedButton.styleFrom(
                          minimumSize: const Size(48, 48),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 14,
                          ),
                        ),
                        onPressed: _openSettings,
                        icon: const Icon(Icons.settings),
                        label: const Text('Settings'),
                      ),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          minimumSize: const Size(48, 48),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 14,
                          ),
                        ),
                        onPressed: () => Navigator.of(
                          context,
                        ).pushNamedAndRemoveUntil(AppRoutes.home, (_) => false),
                        child: const Text('Home'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          if (showConfettiLayer)
            Positioned.fill(
              child: IgnorePointer(
                ignoring: true,
                child: Align(
                  alignment: Alignment.topCenter,
                  child: ConfettiWidget(
                    confettiController: _confetti,
                    blastDirectionality: BlastDirectionality.explosive,
                    blastDirection: pi / 2,
                    emissionFrequency: 0.08,
                    numberOfParticles: 18,
                    maxBlastForce: 24,
                    minBlastForce: 8,
                    gravity: 0.28,
                    shouldLoop: false,
                    colors: _confettiPalette,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// Same motion language as post-submit feedback on [QuizScreen].
class _SlideFadeIn extends StatefulWidget {
  const _SlideFadeIn({required this.child});

  final Widget child;

  @override
  State<_SlideFadeIn> createState() => _SlideFadeInState();
}

class _SlideFadeInState extends State<_SlideFadeIn>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  bool _started = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 260),
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_started) return;
    _started = true;
    if (MediaQuery.disableAnimationsOf(context)) {
      _controller.value = 1;
    } else {
      _controller.forward();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOutCubic,
        reverseCurve: Curves.easeInCubic,
      ),
      child: SlideTransition(
        position: Tween<Offset>(begin: const Offset(0, 0.035), end: Offset.zero)
            .animate(
              CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
            ),
        child: widget.child,
      ),
    );
  }
}
