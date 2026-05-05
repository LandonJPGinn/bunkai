import 'package:flutter/material.dart';

import '../app/breakpoints.dart';

class HomeHeroBanner extends StatelessWidget {
  const HomeHeroBanner({super.key});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return LayoutBuilder(
      builder: (context, constraints) {
        final narrow = constraints.maxWidth < LayoutBreakpoints.tablet;
        final horizontal = narrow ? 20.0 : 28.0;
        final vertical = narrow ? 28.0 : 36.0;

        return Padding(
          padding: const EdgeInsets.fromLTRB(24, 12, 24, 8),
          child: Container(
            width: double.infinity,
            padding: EdgeInsets.fromLTRB(
              horizontal,
              vertical,
              horizontal,
              vertical,
            ),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(22),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  scheme.secondary.withValues(alpha: 0.10),
                  scheme.primary.withValues(alpha: 0.06),
                  scheme.surfaceContainerHighest.withValues(alpha: 0.35),
                ],
                stops: const [0.0, 0.55, 1.0],
              ),
              border: Border.all(
                color: scheme.outlineVariant.withValues(alpha: 0.4),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Debug your Japanese.',
                  style: Theme.of(context).textTheme.displaySmall?.copyWith(
                        fontSize: narrow ? 26 : 32,
                        color: scheme.onSurface,
                      ),
                ),
                const SizedBox(height: 14),
                Text(
                  'Targeted quiz tools for the grammar mistakes normal apps ignore.',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: scheme.onSurfaceVariant,
                        height: 1.5,
                      ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
