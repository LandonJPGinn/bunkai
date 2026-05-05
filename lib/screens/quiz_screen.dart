import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../app/bunkai_feedback_theme.dart';

import '../app/app_router.dart';
import '../app/breakpoints.dart';
import '../app/bunkai_tokens.dart';
import '../data/topic_card_style.dart';
import '../models/quiz.dart';
import '../services/quiz_engine.dart';
import '../widgets/app_shell.dart';
import '../widgets/primary_button.dart';
import '../widgets/progress_header.dart';
import '../widgets/quiz_answer_choices.dart';
import '../widgets/quiz_locked_feedback_content.dart';
import '../widgets/quiz_prompt_card.dart';

class QuizScreen extends StatefulWidget {
  const QuizScreen({super.key, required this.quiz});

  /// Session quiz (full bank or practice subset from [QuizRouteArgs]).
  final Quiz quiz;

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  Quiz? _quiz;
  QuizEngine? _engine;
  final FocusNode _quizKeysFocus = FocusNode(debugLabel: 'QuizScreenKeys');
  bool _showFurigana = true;

  @override
  void initState() {
    super.initState();
    final loaded = widget.quiz;
    if (loaded.questions.isNotEmpty) {
      _quiz = loaded;
      _engine = QuizEngine(loaded);
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && _engine != null) _quizKeysFocus.requestFocus();
    });
  }

  @override
  void dispose() {
    _quizKeysFocus.dispose();
    super.dispose();
  }

  void _commitAnswer(QuizEngine engine) {
    setState(() => engine.lockAnswer());
  }

  /// Stable tear-off for [QuizAnswerChoices] — avoids new closures each rebuild.
  void _onChoiceSelected(String choiceId) {
    final engine = _engine;
    if (engine == null || engine.isLocked) return;
    setState(() => engine.selectAnswer(choiceId));
  }

  void _goResults() {
    final engine = _engine;
    final quiz = _quiz;
    if (engine == null || quiz == null) return;
    Navigator.of(context).pushReplacementNamed(
      AppRoutes.results,
      arguments: ResultsRouteArgs(
        result: engine.buildResult(),
        quizTitle: quiz.title,
      ),
    );
  }

  void _refocusKeys() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _quizKeysFocus.requestFocus();
    });
  }

  String _loadErrorMessage() {
    if (widget.quiz.questions.isEmpty) {
      return 'This session has no questions.';
    }
    return 'This quiz could not be loaded.';
  }

  int? _digitKeyToChoiceIndex(LogicalKeyboardKey key) {
    if (key == LogicalKeyboardKey.digit1 || key == LogicalKeyboardKey.numpad1) {
      return 0;
    }
    if (key == LogicalKeyboardKey.digit2 || key == LogicalKeyboardKey.numpad2) {
      return 1;
    }
    if (key == LogicalKeyboardKey.digit3 || key == LogicalKeyboardKey.numpad3) {
      return 2;
    }
    if (key == LogicalKeyboardKey.digit4 || key == LogicalKeyboardKey.numpad4) {
      return 3;
    }
    return null;
  }

  KeyEventResult _onQuizKeyEvent(FocusNode node, KeyEvent event) {
    if (event is! KeyDownEvent) return KeyEventResult.ignored;
    final engine = _engine;
    if (engine == null) return KeyEventResult.ignored;

    final logical = event.logicalKey;
    final q = engine.currentQuestion;
    final locked = engine.isLocked;

    if (!locked) {
      final idx = _digitKeyToChoiceIndex(logical);
      if (idx != null) {
        if (idx < q.choices.length) {
          setState(() => engine.selectAnswer(q.choices[idx].id));
          return KeyEventResult.handled;
        }
        return KeyEventResult.ignored;
      }
      if (logical == LogicalKeyboardKey.enter ||
          logical == LogicalKeyboardKey.numpadEnter) {
        if (engine.selectedAnswerId != null) {
          _commitAnswer(engine);
          _refocusKeys();
          return KeyEventResult.handled;
        }
        return KeyEventResult.ignored;
      }
    } else {
      if (logical == LogicalKeyboardKey.enter ||
          logical == LogicalKeyboardKey.numpadEnter) {
        if (engine.isLastQuestion) {
          _goResults();
        } else {
          setState(engine.advance);
          _refocusKeys();
        }
        return KeyEventResult.handled;
      }
    }
    return KeyEventResult.ignored;
  }

  @override
  Widget build(BuildContext context) {
    final quiz = _quiz;
    final engine = _engine;

    if (quiz == null || engine == null) {
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
              _loadErrorMessage(),
              style: Theme.of(context).textTheme.bodyLarge,
              textAlign: TextAlign.center,
            ),
          ),
        ),
      );
    }

    final q = engine.currentQuestion;
    final locked = engine.isLocked;
    final selected = engine.selectedAnswerId;
    final showOutcome = locked;

    String primaryLabel;
    VoidCallback? primaryAction;
    if (!locked) {
      primaryLabel = 'Submit';
      primaryAction = selected == null
          ? null
          : () {
              _commitAnswer(engine);
              _refocusKeys();
            };
    } else if (engine.isLastQuestion) {
      primaryLabel = 'View Results';
      primaryAction = _goResults;
    } else {
      primaryLabel = 'Next';
      primaryAction = () {
        setState(engine.advance);
        _refocusKeys();
      };
    }

    final wasCorrect = engine.lastSubmittedCorrect;

    String? wrongChoiceLabel;
    if (locked &&
        wasCorrect == false &&
        selected != null &&
        selected != q.correctAnswerId) {
      for (final c in q.choices) {
        if (c.id == selected) {
          wrongChoiceLabel = c.label;
          break;
        }
      }
    }

    final narrow = LayoutBreakpoints.isNarrowWidth(
      MediaQuery.sizeOf(context).width,
    );
    final horizontalPadding = narrow ? 16.0 : 20.0;
    final topicStyle = topicCardStyleFor(quiz.id);
    final tokens = context.bunkaiTokens;

    return AppShell(
      headerMode: AppShellHeaderMode.compact,
      title: quiz.title,
      leading: IconButton(
        icon: const Icon(Icons.close),
        onPressed: () => Navigator.of(context).pop(),
      ),
      actions: [
        Tooltip(
          message: _showFurigana ? 'Hide furigana' : 'Show furigana',
          child: Switch.adaptive(
            value: _showFurigana,
            onChanged: (v) => setState(() => _showFurigana = v),
          ),
        ),
      ],
      body: Focus(
        focusNode: _quizKeysFocus,
        autofocus: true,
        onKeyEvent: _onQuizKeyEvent,
        child: Padding(
          padding: EdgeInsets.fromLTRB(
            horizontalPadding,
            8,
            horizontalPadding,
            16,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ProgressHeader(
                current: engine.currentIndex,
                total: engine.totalQuestions,
                moduleLabel: quiz.title,
                scoreCorrect: engine.lockedCorrectCount,
                scoreAnswered: engine.lockedAnsweredCount,
                accent: topicStyle.accent,
              ),
              const SizedBox(height: 6),
              Align(
                alignment: Alignment.centerLeft,
                child: TextButton(
                  style: TextButton.styleFrom(
                    foregroundColor: tokens.textMuted,
                    padding: EdgeInsets.zero,
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Back to quizzes'),
                ),
              ),
              const SizedBox(height: 12),
              Expanded(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    return Align(
                      alignment: Alignment.topCenter,
                      child: ConstrainedBox(
                        constraints: BoxConstraints(
                          maxWidth: 720,
                          maxHeight: constraints.maxHeight,
                        ),
                        child: Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Expanded(
                                flex: 42,
                                child: LayoutBuilder(
                                  builder: (context, promptConstraints) {
                                    return SingleChildScrollView(
                                      clipBehavior: Clip.none,
                                      child: ConstrainedBox(
                                        constraints: BoxConstraints(
                                          minHeight:
                                              promptConstraints.maxHeight,
                                        ),
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.stretch,
                                          children: [
                                            QuizPromptCard(
                                              prompt: q.prompt,
                                              japanese: q.japanese,
                                              contextLine: q.context,
                                              showFurigana: _showFurigana,
                                              watermarkKanji: topicStyle.kanji,
                                            ),
                                          ],
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),
                              const SizedBox(height: 22),
                              Expanded(
                                flex: 58,
                                child: LayoutBuilder(
                                  builder: (context, answerConstraints) {
                                    return SingleChildScrollView(
                                      clipBehavior: Clip.none,
                                      child: ConstrainedBox(
                                        constraints: BoxConstraints(
                                          minHeight:
                                              answerConstraints.maxHeight,
                                        ),
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.stretch,
                                          children: [
                                            QuizAnswerChoices(
                                              choices: q.choices,
                                              correctAnswerId:
                                                  q.correctAnswerId,
                                              selectedAnswerId: selected,
                                              locked: locked,
                                              showOutcome: showOutcome,
                                              lastSubmittedCorrect:
                                                  engine.lastSubmittedCorrect,
                                              showFurigana: _showFurigana,
                                              onChoiceSelected:
                                                  _onChoiceSelected,
                                            ),
                                            if (locked) ...[
                                              const SizedBox(height: 12),
                                              _QuizFeedbackLiveBanner(
                                                wasCorrect: wasCorrect,
                                              ),
                                            ],
                                            AnimatedSwitcher(
                                              duration: const Duration(
                                                milliseconds: 260,
                                              ),
                                              switchInCurve:
                                                  Curves.easeOutCubic,
                                              switchOutCurve:
                                                  Curves.easeInCubic,
                                              transitionBuilder:
                                                  (child, animation) {
                                                    return FadeTransition(
                                                      opacity: animation,
                                                      child: SlideTransition(
                                                        position:
                                                            Tween<Offset>(
                                                              begin:
                                                                  const Offset(
                                                                    0,
                                                                    0.035,
                                                                  ),
                                                              end: Offset.zero,
                                                            ).animate(
                                                              CurvedAnimation(
                                                                parent:
                                                                    animation,
                                                                curve: Curves
                                                                    .easeOutCubic,
                                                              ),
                                                            ),
                                                        child: child,
                                                      ),
                                                    );
                                                  },
                                              child: locked
                                                  ? Padding(
                                                      key: ValueKey<int>(
                                                        engine.currentIndex,
                                                      ),
                                                      padding:
                                                          const EdgeInsets.only(
                                                            top: 4,
                                                          ),
                                                      child:
                                                          QuizLockedFeedbackContent(
                                                            question: q,
                                                            wrongChoiceLabel:
                                                                wrongChoiceLabel,
                                                            wasCorrect:
                                                                wasCorrect,
                                                            showFurigana:
                                                                _showFurigana,
                                                          ),
                                                    )
                                                  : const SizedBox(
                                                      key: ValueKey<String>(
                                                        'no-explanation',
                                                      ),
                                                      height: 0,
                                                    ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 12),
              Align(
                alignment: Alignment.center,
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 720),
                  child: PrimaryButton(
                    label: primaryLabel,
                    onPressed: primaryAction,
                    backgroundColor: primaryAction != null
                        ? topicStyle.accent
                        : null,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Compact result copy announced after submit ([Semantics.liveRegion]).
class _QuizFeedbackLiveBanner extends StatelessWidget {
  const _QuizFeedbackLiveBanner({required this.wasCorrect});

  final bool? wasCorrect;

  @override
  Widget build(BuildContext context) {
    final feedback = context.bunkaiFeedback;
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    final Widget body;
    if (wasCorrect == true) {
      body = Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.check_circle_outline, size: 20, color: feedback.correct),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Correct',
              style: textTheme.titleSmall?.copyWith(
                color: feedback.correct,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.02,
              ),
            ),
          ),
        ],
      );
    } else {
      body = Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.cancel_outlined, size: 20, color: feedback.incorrect),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Incorrect',
                  style: textTheme.titleSmall?.copyWith(
                    color: feedback.incorrect,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.02,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'The correct answer is highlighted below.',
                  style: textTheme.bodySmall?.copyWith(
                    color: scheme.onSurfaceVariant,
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
        ],
      );
    }

    return Semantics(container: true, liveRegion: true, child: body);
  }
}
