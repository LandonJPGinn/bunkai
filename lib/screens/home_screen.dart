import 'package:flutter/material.dart';

import '../app/app_router.dart' show AppRoutes, QuizRouteArgs;
import '../app/breakpoints.dart';
import '../app/jpquizapp_tokens.dart';
import '../app/home_scroll_behavior.dart';
import '../data/quiz_registry.dart';
import '../models/practice_options.dart';
import '../models/quiz_summary.dart';
import '../services/practice_session_builder.dart';
import '../services/quiz_bank_loader.dart';
import '../services/quiz_practice_settings_store.dart';
import '../widgets/app_shell.dart' show AppShell, AppShellHeaderMode;
import '../widgets/home_hero_banner.dart';
import '../widgets/quiz_card.dart';
import '../widgets/quiz_practice_settings_sheet.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key, this.scrollToQuizzesOnOpen = false});

  final bool scrollToQuizzesOnOpen;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ScrollController _scroll = ScrollController();
  final GlobalKey _gridKey = GlobalKey();

  /// Catalog only; fonts and large quiz banks must not block the home paint.
  late final Future<List<QuizSummary>> _homeReady = quizSummariesForHome();

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

  Future<void> _startQuiz(
    QuizSummary summary,
    PracticeQuizSettings settings,
  ) async {
    try {
      final base = await QuizBankLoader.instance.ensureQuizLoaded(summary.id);
      if (!mounted) return;
      final normalized = settings.sanitizedFor(
        derivePracticeAvailableSettings(base),
      );
      final session = buildPracticeSessionQuiz(base, settings: normalized);
      Navigator.of(
        context,
      ).pushNamed(AppRoutes.quiz, arguments: QuizRouteArgs(quiz: session));
    } catch (error, stackTrace) {
      debugPrint('HomeScreen: could not start quiz "${summary.id}": $error');
      debugPrintStack(
        label: 'HomeScreen start quiz failure stack',
        stackTrace: stackTrace,
      );
      if (!mounted) return;
      ScaffoldMessenger.maybeOf(
        context,
      )?.showSnackBar(const SnackBar(content: Text('Could not start quiz.')));
    }
  }

  Future<void> _openSettings(
    QuizSummary summary,
    PracticeQuizSettings current,
  ) async {
    try {
      final base = await QuizBankLoader.instance.ensureQuizLoaded(summary.id);
      if (!mounted) return;
      final updated = await showQuizPracticeSettingsSheet(
        context: context,
        quiz: base,
        initialSettings: current,
      );
      if (updated == null) return;
      await QuizPracticeSettingsStore.instance.save(summary.id, updated);
      if (!mounted) return;
      setState(() {});
    } catch (error, stackTrace) {
      debugPrint(
        'HomeScreen: could not open quiz settings for "${summary.id}": $error',
      );
      debugPrintStack(
        label: 'HomeScreen open settings failure stack',
        stackTrace: stackTrace,
      );
      if (!mounted) return;
      ScaffoldMessenger.maybeOf(context)?.showSnackBar(
        const SnackBar(content: Text('Could not open quiz settings.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = context.jpQuizAppTokens;

    return AppShell(
      headerMode: AppShellHeaderMode.none,
      body: FutureBuilder<List<QuizSummary>>(
        future: _homeReady,
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
            return _HomeLoadingBody(tokens: t);
          }

          final quizzes = snapshot.data!;

          return Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: t.maxContentWidth),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final width = constraints.maxWidth;
                  final phone = LayoutBreakpoints.isPhoneWidth(width);
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
                  final cardExtent = phone
                      ? (width * 0.82).clamp(286.0, 336.0).toDouble()
                      : null;

                  return ScrollConfiguration(
                    behavior: const HomeScrollBehavior(),
                    child: SingleChildScrollView(
                      controller: _scroll,
                      padding: EdgeInsets.only(bottom: phone ? 16 : 8),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const HomeHeroBanner(),
                          Padding(
                            key: _gridKey,
                            padding: EdgeInsets.fromLTRB(
                              0,
                              phone ? 4 : 8,
                              0,
                              0,
                            ),
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
                                      ?.copyWith(
                                        color: t.textMuted,
                                        height: 1.45,
                                      ),
                                ),
                                SizedBox(height: phone ? 16 : 20),
                                GridView.builder(
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  gridDelegate:
                                      SliverGridDelegateWithFixedCrossAxisCount(
                                        crossAxisCount: crossCount,
                                        mainAxisSpacing: phone ? 14 : 18,
                                        crossAxisSpacing: 18,
                                        childAspectRatio: aspectRatio,
                                        mainAxisExtent: cardExtent,
                                      ),
                                  itemCount: quizzes.length,
                                  itemBuilder: (context, index) {
                                    final q = quizzes[index];
                                    return FutureBuilder<PracticeQuizSettings>(
                                      future: QuizPracticeSettingsStore.instance
                                          .load(q.id),
                                      builder: (context, settingsSnapshot) {
                                        final settings =
                                            settingsSnapshot.data ??
                                            PracticeQuizSettings.defaults;
                                        return QuizCard(
                                          quizId: q.id,
                                          title: q.title,
                                          subtitle: q.subtitle,
                                          description: q.description,
                                          tags: q.diagnosticTags,
                                          difficulty: q.difficulty,
                                          selectedDifficulty:
                                              settings.summaryLabel,
                                          questionCountLabel:
                                              settings.countLabel,
                                          onStart: () =>
                                              _startQuiz(q, settings),
                                          onOpenSettings: () =>
                                              _openSettings(q, settings),
                                        );
                                      },
                                    );
                                  },
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
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

class _HomeLoadingBody extends StatelessWidget {
  const _HomeLoadingBody({required this.tokens});

  final JpQuizAppTokens tokens;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: 44,
              height: 44,
              child: CircularProgressIndicator(
                strokeWidth: 5,
                color: scheme.primary,
              ),
            ),
            const SizedBox(height: 28),
            Text(
              'Loading language bank..',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: tokens.textMuted,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
