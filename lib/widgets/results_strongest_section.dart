import 'package:flutter/material.dart';

import '../data/diagnostic_tag_recommendations.dart';
import 'diagnostic_tag_chip.dart';

class ResultsStrongestSection extends StatelessWidget {
  const ResultsStrongestSection({super.key, required this.tags});

  final List<String> tags;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Strongest Area',
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                color: scheme.onSurface,
                fontWeight: FontWeight.w600,
              ),
        ),
        const SizedBox(height: 8),
        Text(
          'No misses on these skills in this run.',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: scheme.onSurfaceVariant,
                height: 1.4,
              ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: tags
              .map(
                (t) => DiagnosticTagChip(
                  label: DiagnosticTagRecommendations.humanizeTag(t),
                ),
              )
              .toList(),
        ),
      ],
    );
  }
}
