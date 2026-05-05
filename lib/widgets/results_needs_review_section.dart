import 'package:flutter/material.dart';

import '../data/diagnostic_tag_recommendations.dart';
import 'diagnostic_tag_chip.dart';

class ResultsNeedsReviewSection extends StatelessWidget {
  const ResultsNeedsReviewSection({super.key, required this.sortedMisses});

  final List<MapEntry<String, int>> sortedMisses;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Needs Review',
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                color: scheme.onSurface,
                fontWeight: FontWeight.w600,
              ),
        ),
        const SizedBox(height: 12),
        ...sortedMisses.map((e) {
          final rec = DiagnosticTagRecommendations.recommendationFor(e.key);
          return Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Wrap(
                  spacing: 8,
                  runSpacing: 6,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    DiagnosticTagChip(
                      label: DiagnosticTagRecommendations.humanizeTag(e.key),
                    ),
                    Text(
                      '${e.value} miss${e.value == 1 ? '' : 'es'}',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: scheme.onSurfaceVariant,
                          ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  rec,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        height: 1.45,
                        color: scheme.onSurface,
                      ),
                ),
              ],
            ),
          );
        }),
        const SizedBox(height: 8),
      ],
    );
  }
}
