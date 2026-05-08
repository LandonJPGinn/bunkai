import 'package:flutter/material.dart';

import '../app/app_router.dart';
import '../app/breakpoints.dart';
import '../data/topic_card_style.dart';
import '../app/bunkai_tokens.dart';
import '../models/practice_options.dart';
import '../models/quiz.dart';
import '../models/quiz_id.dart';
import '../services/practice_session_builder.dart';
import '../services/quiz_bank_loader.dart';
import '../services/quiz_practice_settings_store.dart';
import '../widgets/app_shell.dart' show AppShell, AppShellHeaderMode;
import '../widgets/quiz_practice_settings_panel.dart';

/// Minimal setup for a practice session (count, JLPT band). Order is randomized.
class QuizStartScreen extends StatefulWidget {
  const QuizStartScreen({super.key, required this.quizId});

  final String quizId;

  @override
  State<QuizStartScreen> createState() => _QuizStartScreenState();
}

class _QuizStartScreenState extends State<QuizStartScreen> {
  PracticeQuizSettings _settings = PracticeQuizSettings.defaults;

  @override
  void initState() {
    super.initState();
    final parsed = quizIdFromRouteName(widget.quizId);
    if (parsed == null) return;
    QuizPracticeSettingsStore.instance.load(parsed).then((saved) {
      if (!mounted) return;
      setState(() => _settings = saved);
    });
  }

  @override
  Widget build(BuildContext context) {
    final parsed = quizIdFromRouteName(widget.quizId);
    if (parsed == null) {
      return AppShell(
        headerMode: AppShellHeaderMode.compact,
        title: 'Quiz',
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text(
              'This quiz could not be loaded.',
              style: Theme.of(context).textTheme.bodyLarge,
              textAlign: TextAlign.center,
            ),
          ),
        ),
      );
    }

    final id = parsed;

    return FutureBuilder<Quiz>(
      future: QuizBankLoader.instance.ensureQuizLoaded(id),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return AppShell(
            headerMode: AppShellHeaderMode.compact,
            title: 'Quiz',
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () => Navigator.of(context).maybePop(),
            ),
            body: Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  'This quiz could not be loaded.',
                  style: Theme.of(context).textTheme.bodyLarge,
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          );
        }
        if (!snapshot.hasData) {
          return AppShell(
            headerMode: AppShellHeaderMode.compact,
            title: 'Quiz',
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () => Navigator.of(context).maybePop(),
            ),
            body: Center(
              child: SizedBox(
                width: 28,
                height: 28,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
            ),
          );
        }

        final base = snapshot.data!;
        final narrow = LayoutBreakpoints.isNarrowWidth(
          MediaQuery.sizeOf(context).width,
        );
        final horizontalPadding = narrow ? 16.0 : 20.0;
        final previewCount = filteredQuestionsForPreview(
          base,
          _settings.jlptFilter,
        ).length;
        final canStart = previewCount > 0;
        final topicStyle = topicCardStyleFor(base.id);
        final tokens = context.bunkaiTokens;

        return AppShell(
          headerMode: AppShellHeaderMode.compact,
          title: base.title,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.of(context).maybePop(),
          ),
          body: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 440),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(tokens.radiusMd),
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: tokens.surface2,
                    borderRadius: BorderRadius.circular(tokens.radiusMd),
                    border: Border.all(color: tokens.borderSoft),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Container(width: 3, color: topicStyle.accent),
                      Expanded(
                        child: SingleChildScrollView(
                          padding: EdgeInsets.fromLTRB(
                            horizontalPadding,
                            20,
                            horizontalPadding,
                            24,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              // AnimatedSize + AnimatedSwitcher so toggling the
                              // JLPT filter eases the warning row in/out
                              // instead of shoving the form down.
                              AnimatedSize(
                                duration: MediaQuery.of(context)
                                        .disableAnimations
                                    ? Duration.zero
                                    : tokens.motionSlow,
                                curve: tokens.motionEmphasizedCurve,
                                alignment: Alignment.topCenter,
                                child: AnimatedSwitcher(
                                  duration: MediaQuery.of(context)
                                          .disableAnimations
                                      ? Duration.zero
                                      : tokens.motionMedium,
                                  switchInCurve: tokens.motionStandardCurve,
                                  switchOutCurve: tokens.motionStandardCurve,
                                  transitionBuilder: (child, animation) =>
                                      FadeTransition(
                                          opacity: animation, child: child),
                                  child: !canStart
                                      ? Padding(
                                          key: const ValueKey<String>(
                                              'filter-warning'),
                                          padding: const EdgeInsets.only(
                                              bottom: 16),
                                          child: Text(
                                            'No questions for this filter.',
                                            style: Theme.of(context)
                                                .textTheme
                                                .bodySmall
                                                ?.copyWith(
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .error,
                                            ),
                                          ),
                                        )
                                      : const SizedBox(
                                          key: ValueKey<String>(
                                              'filter-warning-empty'),
                                          width: double.infinity,
                                        ),
                                ),
                              ),
                              Text(
                                base.subtitle,
                                style: Theme.of(context).textTheme.titleSmall
                                    ?.copyWith(
                                  color: Theme.of(context).colorScheme.onSurface,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                base.description,
                                style: Theme.of(context).textTheme.bodyMedium
                                    ?.copyWith(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onSurfaceVariant,
                                  height: 1.45,
                                ),
                              ),
                              const SizedBox(height: 22),
                              Align(
                                alignment: Alignment.center,
                                child: ConstrainedBox(
                                  constraints:
                                      const BoxConstraints(maxWidth: 340),
                                  child: ClipRRect(
                                    borderRadius:
                                        BorderRadius.circular(tokens.radiusMd),
                                    child: DecoratedBox(
                                      decoration: BoxDecoration(
                                        color: tokens.surface1,
                                        borderRadius: BorderRadius.circular(
                                          tokens.radiusMd,
                                        ),
                                        border: Border.all(
                                          color: tokens.borderSoft,
                                        ),
                                      ),
                                      child: Padding(
                                        padding: const EdgeInsets.fromLTRB(
                                          16,
                                          18,
                                          16,
                                          20,
                                        ),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.stretch,
                                          children: [
                                            Theme(
                                              data: Theme.of(context).copyWith(
                                                filledButtonTheme:
                                                    FilledButtonThemeData(
                                                  style:
                                                      FilledButton.styleFrom(
                                                    backgroundColor: topicStyle
                                                        .accent,
                                                  ),
                                                ),
                                              ),
                                              child: QuizPracticeSettingsPanel(
                                                settings: _settings,
                                                canStart: canStart,
                                                onCountChanged: (value) {
                                                  setState(
                                                    () => _settings = _settings
                                                        .copyWith(
                                                      countPreset: value,
                                                    ),
                                                  );
                                                },
                                                onJlptChanged: (value) {
                                                  setState(
                                                    () => _settings = _settings
                                                        .copyWith(
                                                      jlptFilter: value,
                                                    ),
                                                  );
                                                },
                                                onStart: () async {
                                                  await QuizPracticeSettingsStore
                                                      .instance
                                                      .save(id, _settings);
                                                  if (!context.mounted) return;
                                                  final session =
                                                      buildPracticeSessionQuiz(
                                                    base,
                                                    difficulty:
                                                        _settings.jlptFilter,
                                                    countPreset:
                                                        _settings.countPreset,
                                                  );
                                                  Navigator.of(
                                                    context,
                                                  ).pushNamed(
                                                    AppRoutes.quiz,
                                                    arguments: QuizRouteArgs(
                                                      quiz: session,
                                                    ),
                                                  );
                                                },
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
