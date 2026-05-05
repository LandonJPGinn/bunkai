import 'package:flutter/material.dart';

import 'diagnostic_tag_chip.dart';

class QuizCard extends StatelessWidget {
  const QuizCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.difficulty,
    required this.diagnosticTags,
    required this.onStart,
  });

  final String title;
  final String subtitle;
  final String difficulty;
  final List<String> diagnosticTags;
  final VoidCallback onStart;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Card(
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 6),
            Text(
              subtitle,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: scheme.onSurfaceVariant,
                    height: 1.35,
                  ),
            ),
            const SizedBox(height: 14),
            Expanded(
              child: SingleChildScrollView(
                child: Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: scheme.surfaceContainerLow,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: scheme.outlineVariant.withValues(alpha: 0.55),
                        ),
                      ),
                      child: Text(
                        difficulty,
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                              color: scheme.onSurfaceVariant,
                              letterSpacing: 0.12,
                            ),
                      ),
                    ),
                    ...diagnosticTags.map((t) => DiagnosticTagChip(label: t)),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            Align(
              alignment: Alignment.centerRight,
              child: FilledButton(
                onPressed: onStart,
                child: const Text('Start'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
