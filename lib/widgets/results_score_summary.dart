import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../app/bunkai_feedback_theme.dart';
import '../app/bunkai_tokens.dart';

/// Score hero card styled like graded answer / explanation panels.
class ResultsScoreSummary extends StatelessWidget {
  const ResultsScoreSummary({
    super.key,
    required this.headline,
    required this.quizTitle,
    required this.percent,
    required this.correctCount,
    required this.totalCount,
    required this.isPassing,
  });

  final String headline;
  final String quizTitle;
  final int percent;
  final int correctCount;
  final int totalCount;
  final bool isPassing;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final feedback = context.bunkaiFeedback;
    final t = context.bunkaiTokens;
    final reduceMotion = MediaQuery.of(context).disableAnimations;

    final (Color borderColor, Color bgColor) = isPassing
        ? (
            feedback.correct.withValues(alpha: 0.55),
            Color.alphaBlend(
              feedback.correctContainer,
              scheme.surfaceContainerLow,
            ),
          )
        : (
            feedback.incorrect.withValues(alpha: 0.52),
            Color.alphaBlend(
              feedback.incorrectContainer,
              scheme.surfaceContainerLow,
            ),
          );

    return ClipRRect(
      borderRadius: BorderRadius.circular(14),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 22),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: borderColor, width: 1.2),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              headline,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.02,
                    color: scheme.onSurface,
                  ),
            ),
            const SizedBox(height: 10),
            Text(
              quizTitle,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: t.textStrong,
                  ),
            ),
            const SizedBox(height: 18),
            TweenAnimationBuilder<double>(
              tween: Tween<double>(begin: 0, end: percent.toDouble()),
              duration: reduceMotion
                  ? Duration.zero
                  : const Duration(milliseconds: 720),
              curve: Curves.easeOutCubic,
              builder: (context, v, _) {
                final display = v.round().clamp(0, 100);
                return Text(
                  '$display%',
                  semanticsLabel: '$percent percent correct',
                  style: GoogleFonts.inter(
                    fontSize: 52,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -2,
                    height: 1.05,
                    color: t.textStrong,
                  ),
                );
              },
            ),
            const SizedBox(height: 8),
            Text(
              '$correctCount correct out of $totalCount',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: t.textMuted,
                    height: 1.4,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}
