import 'package:flutter/material.dart';

import '../app/breakpoints.dart';
import '../app/jpquizapp_tokens.dart';

class HomeHeroBanner extends StatelessWidget {
  const HomeHeroBanner({super.key});

  @override
  Widget build(BuildContext context) {
    final t = context.jpQuizAppTokens;
    final scheme = Theme.of(context).colorScheme;

    return LayoutBuilder(
      builder: (context, constraints) {
        final phone = constraints.maxWidth < LayoutBreakpoints.phone;
        final narrow = constraints.maxWidth < LayoutBreakpoints.tablet;
        final horizontal = phone
            ? 16.0
            : narrow
            ? 20.0
            : 28.0;
        final vertical = phone
            ? 20.0
            : narrow
            ? 24.0
            : 32.0;

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
                    fontSize: phone
                        ? 26
                        : narrow
                        ? 28
                        : 34,
                    color: t.textStrong,
                    height: 1.1,
                  ),
                ),
                SizedBox(height: phone ? 10 : 12),
                Text(
                  'Get past that frustrating intermediate plateau with diagnostic quizzes on Japanese grammar—'
                  'particles, clauses, register, argument structure, and verb '
                  'forms—with tap-to-define vocabulary and clear explanations '
                  'after each answer. Pick a topic below to practice.',
                  style:
                      (phone
                              ? Theme.of(context).textTheme.bodyMedium
                              : Theme.of(context).textTheme.bodyLarge)
                          ?.copyWith(
                            color: t.textMuted,
                            height: phone ? 1.48 : 1.55,
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
