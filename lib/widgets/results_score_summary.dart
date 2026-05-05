import 'package:flutter/material.dart';

class ResultsScoreSummary extends StatelessWidget {
  const ResultsScoreSummary({
    super.key,
    required this.quizTitle,
    required this.percent,
    required this.correctCount,
    required this.totalCount,
  });

  final String quizTitle;
  final int percent;
  final int correctCount;
  final int totalCount;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          quizTitle,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: scheme.onSurface,
              ),
        ),
        const SizedBox(height: 20),
        Text(
          '$percent%',
          semanticsLabel: '$percent percent correct',
          style: Theme.of(context).textTheme.displaySmall?.copyWith(
                fontWeight: FontWeight.w600,
                color: scheme.onSurface,
                height: 1.1,
              ),
        ),
        const SizedBox(height: 8),
        Text(
          '$correctCount correct out of $totalCount',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: scheme.onSurfaceVariant,
                height: 1.4,
              ),
        ),
      ],
    );
  }
}
