import 'package:flutter/material.dart';

import '../app/app_router.dart' show AppRoutes, QuizStartRouteArgs;
import '../app/breakpoints.dart';
import '../app/bunkai_tokens.dart';
import '../data/quiz_registry.dart';
import '../models/quiz_summary.dart';
import '../widgets/app_shell.dart' show AppShell, AppShellHeaderMode;
import '../widgets/home_hero_banner.dart';
import '../widgets/quiz_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key, this.scrollToQuizzesOnOpen = false});

  final bool scrollToQuizzesOnOpen;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ScrollController _scroll = ScrollController();
  final GlobalKey _gridKey = GlobalKey();

  /// PERF: Catalog-only future — never parses full banks for the grid.
  late final Future<List<QuizSummary>> _catalogFuture = quizSummariesForHome();

  @override
  void initState() {
    super.initState();
    if (widget.scrollToQuizzesOnOpen) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToGrid());
    }
  }

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  void _scrollToGrid() {
    final ctx = _gridKey.currentContext;
    if (ctx != null) {
      Scrollable.ensureVisible(
        ctx,
        duration: const Duration(milliseconds: 420),
        curve: Curves.easeOutCubic,
        alignment: 0.08,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = context.bunkaiTokens;

    return AppShell(
      headerMode: AppShellHeaderMode.none,
      body: FutureBuilder<List<QuizSummary>>(
        future: _catalogFuture,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  'Could not load quizzes.',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
              ),
            );
          }
          if (!snapshot.hasData) {
            return Center(
              child: SizedBox(
                width: 28,
                height: 28,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
            );
          }

          final quizzes = snapshot.data!;

          return Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: t.maxContentWidth),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final width = constraints.maxWidth;
                  final crossCount = width >= LayoutBreakpoints.desktop
                      ? 3
                      : width >= LayoutBreakpoints.tablet
                      ? 2
                      : 1;
                  final aspectRatio = switch (crossCount) {
                    1 => 1.42,
                    2 => 1.08,
                    _ => 0.82,
                  };

                  return SingleChildScrollView(
                    controller: _scroll,
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const HomeHeroBanner(),
                        Padding(
                          key: _gridKey,
                          padding: const EdgeInsets.fromLTRB(0, 8, 0, 0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Choose a training mode',
                                style: Theme.of(context).textTheme.titleLarge
                                    ?.copyWith(color: t.textStrong),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Each quiz isolates one grammar skill so mistakes '
                                'become patterns you can fix.',
                                style: Theme.of(context).textTheme.bodyMedium
                                    ?.copyWith(color: t.textMuted, height: 1.45),
                              ),
                              const SizedBox(height: 20),
                              GridView.builder(
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
                                    quizId: q.id,
                                    title: q.title,
                                    subtitle: q.subtitle,
                                    description: q.description,
                                    tags: q.diagnosticTags,
                                    difficulty: q.difficulty,
                                    onStart: () =>
                                        Navigator.of(context).pushNamed(
                                      AppRoutes.quizStart,
                                      arguments: QuizStartRouteArgs(
                                        quizId: q.id.name,
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          );
        },
      ),
    );
  }
}
