import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../app/jpquizapp_feedback_theme.dart';

import '../app/app_router.dart';
import '../app/breakpoints.dart';
import '../app/jpquizapp_tokens.dart';
import '../data/topic_card_style.dart';
import '../models/quiz.dart';
import '../services/romaji_to_hiragana_converter.dart';
import '../services/quiz_engine.dart';
import '../widgets/app_shell.dart';
import '../widgets/primary_button.dart';
import '../widgets/progress_header.dart';
import '../widgets/quiz_locked_feedback_content.dart';
import '../widgets/quiz_prompt_card.dart';
import '../widgets/quiz_text_answer_input.dart';

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
  final FocusNode _answerFocus = FocusNode(debugLabel: 'QuizScreenAnswer');
  final TextEditingController _answerController = TextEditingController();
  bool _showFurigana = true;
  bool _showEnglish = false;
  bool _syncingAnswer = false;

  @override
  void initState() {
    super.initState();
    final loaded = widget.quiz;
    if (loaded.questions.isNotEmpty) {
      _quiz = loaded;
      _engine = QuizEngine(loaded);
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && _engine != null) {
        _quizKeysFocus.requestFocus();
        if (!_isPhoneLayout()) {
          _answerFocus.requestFocus();
        }
      }
    });
    _answerController.addListener(_onAnswerChanged);
  }

  @override
  void dispose() {
    _answerController.removeListener(_onAnswerChanged);
    _answerController.dispose();
    _answerFocus.dispose();
    _quizKeysFocus.dispose();
    super.dispose();
  }

  void _onAnswerChanged() {
    if (_syncingAnswer) return;
    final engine = _engine;
    if (engine == null || engine.isLocked) return;
    final converted = RomajiToHiraganaConverter.convert(
      _answerController.value,
    );
    if (converted != _answerController.value) {
      _syncingAnswer = true;
      _answerController.value = converted;
      _syncingAnswer = false;
    }
    setState(() {
      engine.setDraftAnswer(_answerController.text);
    });
  }

  void _commitAnswer(QuizEngine engine) {
    setState(() => engine.lockAnswer());
  }

  void _advanceQuestion(QuizEngine engine) {
    setState(() {
      engine.advance();
      _syncingAnswer = true;
      _answerController.clear();
      _syncingAnswer = false;
    });
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
      if (mounted) {
        _quizKeysFocus.requestFocus();
        if (!_isPhoneLayout()) {
          _answerFocus.requestFocus();
        }
      }
    });
  }

  bool _isPhoneLayout() =>
      LayoutBreakpoints.isPhoneWidth(MediaQuery.sizeOf(context).width);

  String _loadErrorMessage() {
    if (widget.quiz.questions.isEmpty) {
      return 'This session has no questions.';
    }
    return 'This quiz could not be loaded.';
  }

  KeyEventResult _onQuizKeyEvent(FocusNode node, KeyEvent event) {
    if (event is! KeyDownEvent) return KeyEventResult.ignored;
    final engine = _engine;
    if (engine == null) return KeyEventResult.ignored;

    final logical = event.logicalKey;
    final locked = engine.isLocked;

    if (!locked) {
      if (logical == LogicalKeyboardKey.enter ||
          logical == LogicalKeyboardKey.numpadEnter) {
        if (engine.draftAnswer.trim().isNotEmpty) {
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
          _advanceQuestion(engine);
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
    final draft = engine.draftAnswer;

    String primaryLabel;
    VoidCallback? primaryAction;
    if (!locked) {
      primaryLabel = 'Submit';
      primaryAction = draft.trim().isEmpty
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
        _advanceQuestion(engine);
        _refocusKeys();
      };
    }

    final wasCorrect = engine.lastSubmittedCorrect;

    final wrongChoiceLabel = locked && wasCorrect == false
        ? engine.submittedAnswer
        : null;

    final width = MediaQuery.sizeOf(context).width;
    final phone = LayoutBreakpoints.isPhoneWidth(width);
    final narrow = LayoutBreakpoints.isNarrowWidth(width);
    final horizontalPadding = phone
        ? 4.0
        : narrow
        ? 16.0
        : 20.0;
    final topicStyle = topicCardStyleFor(quiz.id);
    final tokens = context.jpQuizAppTokens;
    final reduceMotion = MediaQuery.of(context).disableAnimations;
    final motionMedium = reduceMotion ? Duration.zero : tokens.motionMedium;
    final motionSlow = reduceMotion ? Duration.zero : tokens.motionSlow;
    final motionCurve = tokens.motionStandardCurve;
    final motionEmphasized = tokens.motionEmphasizedCurve;

    return AppShell(
      headerMode: AppShellHeaderMode.compact,
      title: quiz.title,
      leading: IconButton(
        icon: const Icon(Icons.close),
        onPressed: () => Navigator.of(context).pop(),
      ),
      actions: [
        if (phone)
          PopupMenuButton<String>(
            tooltip: 'Display options',
            icon: const Icon(Icons.tune),
            onSelected: (value) {
              setState(() {
                if (value == 'furigana') {
                  _showFurigana = !_showFurigana;
                } else if (value == 'english') {
                  _showEnglish = !_showEnglish;
                }
              });
            },
            itemBuilder: (context) => [
              CheckedPopupMenuItem<String>(
                value: 'furigana',
                checked: _showFurigana,
                child: const Text('Furigana'),
              ),
              CheckedPopupMenuItem<String>(
                value: 'english',
                checked: _showEnglish,
                child: const Text('English'),
              ),
            ],
          )
        else
          Padding(
            padding: const EdgeInsets.only(right: 4),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Tooltip(
                  message: _showFurigana ? 'Hide furigana' : 'Show furigana',
                  child: Switch.adaptive(
                    value: _showFurigana,
                    onChanged: (v) => setState(() => _showFurigana = v),
                  ),
                ),
                Tooltip(
                  message: _showEnglish ? 'Show Japanese cues' : 'Show English',
                  child: Switch.adaptive(
                    value: _showEnglish,
                    onChanged: (v) => setState(() => _showEnglish = v),
                  ),
                ),
              ],
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
          child: phone
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Expanded(
                      child: SingleChildScrollView(
                        keyboardDismissBehavior:
                            ScrollViewKeyboardDismissBehavior.onDrag,
                        clipBehavior: Clip.none,
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Align(
                          alignment: Alignment.topCenter,
                          child: ConstrainedBox(
                            constraints: const BoxConstraints(maxWidth: 720),
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
                                      tapTargetSize:
                                          MaterialTapTargetSize.shrinkWrap,
                                    ),
                                    onPressed: () =>
                                        Navigator.of(context).pop(),
                                    child: const Text('Back to quizzes'),
                                  ),
                                ),
                                const SizedBox(height: 14),
                                QuizPromptCard(
                                  japanese: q.japanese,
                                  promptEn: q.promptEn,
                                  japaneseEn: q.japaneseEn,
                                  contextLine: q.context,
                                  contextLineEn: q.contextEn,
                                  showFurigana: _showFurigana,
                                  showEnglish: _showEnglish,
                                  watermarkKanji: topicStyle.kanji,
                                ),
                                const SizedBox(height: 16),
                                QuizTextAnswerInput(
                                  controller: _answerController,
                                  focusNode: _answerFocus,
                                  locked: locked,
                                  wasCorrect: engine.lastSubmittedCorrect,
                                  onSubmitted: primaryAction,
                                ),
                                AnimatedSize(
                                  duration: motionSlow,
                                  curve: motionEmphasized,
                                  alignment: Alignment.topCenter,
                                  child: AnimatedSwitcher(
                                    duration: motionSlow,
                                    switchInCurve: motionCurve,
                                    switchOutCurve: motionCurve,
                                    transitionBuilder: (child, animation) =>
                                        FadeTransition(
                                          opacity: animation,
                                          child: child,
                                        ),
                                    child: locked
                                        ? Padding(
                                            key: const ValueKey<String>(
                                              'live-banner',
                                            ),
                                            padding: const EdgeInsets.only(
                                              top: 12,
                                            ),
                                            child: _QuizFeedbackLiveBanner(
                                              wasCorrect: wasCorrect,
                                            ),
                                          )
                                        : const SizedBox(
                                            key: ValueKey<String>(
                                              'live-banner-empty',
                                            ),
                                            width: double.infinity,
                                          ),
                                  ),
                                ),
                                AnimatedSize(
                                  duration: motionSlow,
                                  curve: motionEmphasized,
                                  alignment: Alignment.topCenter,
                                  child: AnimatedSwitcher(
                                    duration: motionMedium,
                                    switchInCurve: motionCurve,
                                    switchOutCurve: motionCurve,
                                    transitionBuilder: (child, animation) {
                                      return FadeTransition(
                                        opacity: animation,
                                        child: SlideTransition(
                                          position:
                                              Tween<Offset>(
                                                begin: const Offset(0, 0.035),
                                                end: Offset.zero,
                                              ).animate(
                                                CurvedAnimation(
                                                  parent: animation,
                                                  curve: motionCurve,
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
                                            padding: const EdgeInsets.only(
                                              top: 4,
                                            ),
                                            child: QuizLockedFeedbackContent(
                                              question: q,
                                              wrongChoiceLabel:
                                                  wrongChoiceLabel,
                                              wasCorrect: wasCorrect,
                                              showFurigana: _showFurigana,
                                              showEnglish: _showEnglish,
                                            ),
                                          )
                                        : const SizedBox(
                                            key: ValueKey<String>(
                                              'no-explanation',
                                            ),
                                            width: double.infinity,
                                          ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
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
                )
              : Column(
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
                          final reduceMotion = MediaQuery.of(
                            context,
                          ).disableAnimations;
                          final motionMedium = reduceMotion
                              ? Duration.zero
                              : tokens.motionMedium;
                          final motionSlow = reduceMotion
                              ? Duration.zero
                              : tokens.motionSlow;
                          final motionCurve = tokens.motionStandardCurve;
                          final motionEmphasized = tokens.motionEmphasizedCurve;
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
                                  crossAxisAlignment:
                                      CrossAxisAlignment.stretch,
                                  children: [
                                    Expanded(
                                      flex: 46,
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
                                                // Top-anchored so any height changes
                                                // grow downward instead of recentering
                                                // sibling content.
                                                mainAxisAlignment:
                                                    MainAxisAlignment.start,
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.stretch,
                                                children: [
                                                  QuizPromptCard(
                                                    japanese: q.japanese,
                                                    promptEn: q.promptEn,
                                                    japaneseEn: q.japaneseEn,
                                                    contextLine: q.context,
                                                    contextLineEn: q.contextEn,
                                                    showFurigana: _showFurigana,
                                                    showEnglish: _showEnglish,
                                                    watermarkKanji:
                                                        topicStyle.kanji,
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
                                      flex: 54,
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
                                                    MainAxisAlignment.start,
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.stretch,
                                                children: [
                                                  QuizTextAnswerInput(
                                                    controller:
                                                        _answerController,
                                                    focusNode: _answerFocus,
                                                    locked: locked,
                                                    wasCorrect: engine
                                                        .lastSubmittedCorrect,
                                                    onSubmitted: primaryAction,
                                                  ),
                                                  // Live banner slot is always
                                                  // mounted and animated, so the
                                                  // submit/next button never jumps
                                                  // when the user locks an answer.
                                                  AnimatedSize(
                                                    duration: motionSlow,
                                                    curve: motionEmphasized,
                                                    alignment:
                                                        Alignment.topCenter,
                                                    child: AnimatedSwitcher(
                                                      duration: motionSlow,
                                                      switchInCurve:
                                                          motionCurve,
                                                      switchOutCurve:
                                                          motionCurve,
                                                      transitionBuilder:
                                                          (child, animation) =>
                                                              FadeTransition(
                                                                opacity:
                                                                    animation,
                                                                child: child,
                                                              ),
                                                      child: locked
                                                          ? Padding(
                                                              key:
                                                                  const ValueKey<
                                                                    String
                                                                  >(
                                                                    'live-banner',
                                                                  ),
                                                              padding:
                                                                  const EdgeInsets.only(
                                                                    top: 12,
                                                                  ),
                                                              child: _QuizFeedbackLiveBanner(
                                                                wasCorrect:
                                                                    wasCorrect,
                                                              ),
                                                            )
                                                          : const SizedBox(
                                                              key: ValueKey<String>(
                                                                'live-banner-empty',
                                                              ),
                                                              width: double
                                                                  .infinity,
                                                            ),
                                                    ),
                                                  ),
                                                  // AnimatedSize ensures the height
                                                  // delta tweens; the inner
                                                  // AnimatedSwitcher fades content.
                                                  AnimatedSize(
                                                    duration: motionSlow,
                                                    curve: motionEmphasized,
                                                    alignment:
                                                        Alignment.topCenter,
                                                    child: AnimatedSwitcher(
                                                      duration: motionMedium,
                                                      switchInCurve:
                                                          motionCurve,
                                                      switchOutCurve:
                                                          motionCurve,
                                                      transitionBuilder: (child, animation) {
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
                                                                  end: Offset
                                                                      .zero,
                                                                ).animate(
                                                                  CurvedAnimation(
                                                                    parent:
                                                                        animation,
                                                                    curve:
                                                                        motionCurve,
                                                                  ),
                                                                ),
                                                            child: child,
                                                          ),
                                                        );
                                                      },
                                                      child: locked
                                                          ? Padding(
                                                              key: ValueKey<int>(
                                                                engine
                                                                    .currentIndex,
                                                              ),
                                                              padding:
                                                                  const EdgeInsets.only(
                                                                    top: 4,
                                                                  ),
                                                              child: QuizLockedFeedbackContent(
                                                                question: q,
                                                                wrongChoiceLabel:
                                                                    wrongChoiceLabel,
                                                                wasCorrect:
                                                                    wasCorrect,
                                                                showFurigana:
                                                                    _showFurigana,
                                                                showEnglish:
                                                                    _showEnglish,
                                                              ),
                                                            )
                                                          : const SizedBox(
                                                              key: ValueKey<String>(
                                                                'no-explanation',
                                                              ),
                                                              width: double
                                                                  .infinity,
                                                            ),
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
    final feedback = context.jpQuizAppFeedback;
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
                  'Review the expected form below.',
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
