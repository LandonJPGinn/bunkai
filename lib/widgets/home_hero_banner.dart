import 'package:flutter/material.dart';

import '../app/breakpoints.dart';
import '../app/bunkai_tokens.dart';

class HomeHeroBanner extends StatelessWidget {
  const HomeHeroBanner({super.key});

  @override
  Widget build(BuildContext context) {
    final t = context.bunkaiTokens;
    final scheme = Theme.of(context).colorScheme;

    return LayoutBuilder(
      builder: (context, constraints) {
        final narrow = constraints.maxWidth < LayoutBreakpoints.tablet;
        final horizontal = narrow ? 20.0 : 28.0;
        final vertical = narrow ? 24.0 : 32.0;

        return Padding(
          padding: const EdgeInsets.fromLTRB(0, 4, 0, 8),
          child: Container(
            width: double.infinity,
            padding: EdgeInsets.fromLTRB(
              horizontal,
              vertical,
              horizontal,
              vertical,
            ),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(t.radiusLg),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  t.accent.withValues(alpha: 0.10),
                  scheme.primary.withValues(alpha: 0.08),
                  t.surface3.withValues(alpha: 0.55),
                ],
                stops: const [0.0, 0.45, 1.0],
              ),
              border: Border.all(color: t.borderSoft),
              boxShadow: t.shadowSoft,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Japanese Intermediate Practice',
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.6,
                        color: t.textMuted,
                      ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Focus on the details most courses skip.',
                  style: Theme.of(context).textTheme.displaySmall?.copyWith(
                    fontSize: narrow ? 28 : 34,
                    color: t.textStrong,
                    height: 1.1,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Get past that frustrating intermediate plateau with diagnostic quizzes on Japanese grammar—'
                  'particles, clauses, register, argument structure, and verb '
                  'forms—with tap-to-define vocabulary and clear explanations '
                  'after each answer. Pick a topic below to practice.',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: t.textMuted,
                    height: 1.55,
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
