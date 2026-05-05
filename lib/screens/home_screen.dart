import 'package:flutter/material.dart';

import '../app/app_router.dart' show AppRoutes, QuizStartRouteArgs;
import '../app/breakpoints.dart';
import '../data/quiz_registry.dart';
import '../widgets/app_shell.dart';
import '../widgets/home_hero_banner.dart';
import '../widgets/quiz_card.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final quizzes = allQuizzes();

    return AppShell(
      title: 'BunKai',
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1120),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final width = constraints.maxWidth;
              final crossCount = width >= LayoutBreakpoints.desktop
                  ? 3
                  : width >= LayoutBreakpoints.tablet
                      ? 2
                      : 1;
              final aspectRatio = switch (crossCount) {
                1 => 1.48,
                2 => 1.12,
                _ => 0.86,
              };

              return SingleChildScrollView(
                padding: const EdgeInsets.only(bottom: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const HomeHeroBanner(),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
                      child: GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate:
                            SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: crossCount,
                          mainAxisSpacing: 18,
                          crossAxisSpacing: 18,
                          childAspectRatio: aspectRatio,
                        ),
                        itemCount: quizzes.length,
                        itemBuilder: (context, index) {
                          final q = quizzes[index];
                          return QuizCard(
                            title: q.title,
                            subtitle: q.subtitle,
                            difficulty: q.difficulty,
                            diagnosticTags: q.diagnosticTags,
                            onStart: () => Navigator.of(context).pushNamed(
                                  AppRoutes.quizStart,
                                  arguments: QuizStartRouteArgs(
                                    quizId: q.id.name,
                                  ),
                                ),
                          );
                        },
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(24, 32, 24, 40),
                      child: Text(
                        'No login. No streaks. Just focused Japanese practice.',
                        textAlign: TextAlign.center,
                        style:
                            Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onSurfaceVariant
                                      .withValues(alpha: 0.9),
                                  height: 1.45,
                                ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
