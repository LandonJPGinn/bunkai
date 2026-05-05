import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../app/app_router.dart';
import '../app/breakpoints.dart';
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
          setState(engine.lockAnswer);
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
              setState(engine.lockAnswer);
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

    final narrow =
        LayoutBreakpoints.isNarrowWidth(MediaQuery.sizeOf(context).width);
    final horizontalPadding = narrow ? 16.0 : 20.0;

    return AppShell(
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
          padding: EdgeInsets.fromLTRB(horizontalPadding, 8, horizontalPadding, 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ProgressHeader(
                current: engine.currentIndex,
                total: engine.totalQuestions,
                moduleLabel: quiz.title,
                scoreCorrect: engine.lockedCorrectCount,
                scoreAnswered: engine.lockedAnsweredCount,
              ),
              const SizedBox(height: 18),
              Expanded(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    return SingleChildScrollView(
                      child: Align(
                        alignment: Alignment.topCenter,
                        child: ConstrainedBox(
                          constraints: BoxConstraints(
                            maxWidth: 720,
                            minHeight: constraints.maxHeight,
                          ),
                          child: Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                QuizPromptCard(
                                  prompt: q.prompt,
                                  japanese: q.japanese,
                                  contextLine: q.context,
                                  showFurigana: _showFurigana,
                                ),
                                const SizedBox(height: 22),
                                QuizAnswerChoices(
                                  choices: q.choices,
                                  correctAnswerId: q.correctAnswerId,
                                  selectedAnswerId: selected,
                                  locked: locked,
                                  showOutcome: showOutcome,
                                  showFurigana: _showFurigana,
                                  onChoiceSelected: (id) => setState(
                                    () => engine.selectAnswer(id),
                                  ),
                                ),
                                AnimatedSwitcher(
                                  duration: const Duration(milliseconds: 260),
                                  switchInCurve: Curves.easeOutCubic,
                                  switchOutCurve: Curves.easeInCubic,
                                  transitionBuilder: (child, animation) {
                                    return FadeTransition(
                                      opacity: animation,
                                      child: SlideTransition(
                                        position: Tween<Offset>(
                                          begin: const Offset(0, 0.035),
                                          end: Offset.zero,
                                        ).animate(
                                          CurvedAnimation(
                                            parent: animation,
                                            curve: Curves.easeOutCubic,
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
                                              const EdgeInsets.only(top: 4),
                                          child: QuizLockedFeedbackContent(
                                            question: q,
                                            wrongChoiceLabel:
                                                wrongChoiceLabel,
                                            wasCorrect: wasCorrect,
                                            showFurigana: _showFurigana,
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
