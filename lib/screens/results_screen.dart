import 'package:flutter/material.dart';

import '../app/app_router.dart';
import '../data/quiz_registry.dart';
import '../app/breakpoints.dart';
import '../services/score_service.dart';
import '../widgets/app_shell.dart';
import '../widgets/primary_button.dart';
import '../widgets/results_needs_review_section.dart';
import '../widgets/results_score_summary.dart';
import '../widgets/results_strongest_section.dart';

class ResultsScreen extends StatelessWidget {
  const ResultsScreen({super.key, required this.args});

  final ResultsRouteArgs args;

  static const _score = ScoreService();

  @override
  Widget build(BuildContext context) {
    final result = args.result;
    final percent = _score.percentRounded(result);
    final misses = result.diagnosticMisses;
    final tagsInRun = result.diagnosticTagsInRun;

    final strongestTags = tagsInRun
        .where((t) => (misses[t] ?? 0) == 0)
        .toList()
      ..sort();

    final sortedMisses = misses.entries.toList()
      ..sort((a, b) {
        final c = b.value.compareTo(a.value);
        if (c != 0) return c;
        return a.key.compareTo(b.key);
      });

    final narrow =
        LayoutBreakpoints.isNarrowWidth(MediaQuery.sizeOf(context).width);
    final horizontalPadding = narrow ? 16.0 : 20.0;

    return AppShell(
      title: 'Results',
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 560),
          child: Padding(
            padding: EdgeInsets.fromLTRB(
              horizontalPadding,
              8,
              horizontalPadding,
              16,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        ResultsScoreSummary(
                          quizTitle: args.quizTitle,
                          percent: percent,
                          correctCount: result.correctCount,
                          totalCount: result.totalCount,
                        ),
                        const SizedBox(height: 24),
                        if (strongestTags.isNotEmpty) ...[
                          ResultsStrongestSection(tags: strongestTags),
                          const SizedBox(height: 24),
                        ],
                        if (sortedMisses.isNotEmpty)
                          ResultsNeedsReviewSection(
                            sortedMisses: sortedMisses,
                          ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                PrimaryButton(
                  label: 'Retry Quiz',
                  onPressed: () {
                    final full = quizById(result.quizId);
                    if (full == null) return;
                    Navigator.of(context).pushReplacementNamed(
                      AppRoutes.quiz,
                      arguments: QuizRouteArgs(quiz: full),
                    );
                  },
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
                    onPressed: () =>
                        Navigator.of(context).pushNamedAndRemoveUntil(
                      AppRoutes.home,
                      (_) => false,
                    ),
                    child: const Text('Back to Home'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
