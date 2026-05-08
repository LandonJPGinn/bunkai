import 'package:flutter/material.dart';

import '../app/bunkai_tokens.dart';
import '../models/quiz_question.dart';
import 'diagnostic_tag_chip.dart';
import 'difficulty_dots.dart';
import 'explanation_panel.dart';
import 'japanese_text_lookup.dart';

/// Shown after submit: optional wrong-answer line, explanation, diagnostic tags.
class QuizLockedFeedbackContent extends StatelessWidget {
  const QuizLockedFeedbackContent({
    super.key,
    required this.question,
    required this.wrongChoiceLabel,
    this.wrongChoiceLabelEnglish,
    required this.wasCorrect,
    required this.showFurigana,
    required this.showEnglish,
  });

  final QuizQuestion question;
  final String? wrongChoiceLabel;
  final String? wrongChoiceLabelEnglish;
  final bool? wasCorrect;
  final bool showFurigana;
  final bool showEnglish;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final tokens = context.bunkaiTokens;
    final reduceMotion = MediaQuery.of(context).disableAnimations;
    final motionSlow = reduceMotion ? Duration.zero : tokens.motionSlow;
    final tags = question.diagnosticTags;
    final jlpt = question.jlptLevel;
    final score = question.difficultyScore;
    final grammar = question.grammarPoints;
    final vocab = question.vocabulary;
    final showMeta = jlpt != null || score != null;

    // AnimatedSize keeps the height transition smooth when any inner
    // content reflows (e.g. when furigana/English toggles change block
    // sizes or when the explanation panel grows).
    return AnimatedSize(
      duration: motionSlow,
      curve: tokens.motionEmphasizedCurve,
      alignment: Alignment.topCenter,
      child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (wrongChoiceLabel != null) ...[
          Wrap(
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 4,
            children: [
              Text(
                'You chose:',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      color: scheme.onSurface,
                      height: 1.35,
                      fontWeight: FontWeight.w600,
                    ),
              ),
              if (showEnglish &&
                  (wrongChoiceLabelEnglish?.trim().isNotEmpty ?? false))
                Text(
                  wrongChoiceLabelEnglish!.trim(),
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        color: scheme.onSurface,
                        height: 1.35,
                        fontWeight: FontWeight.w600,
                      ),
                )
              else
                JapaneseTextLookup(
                  text: wrongChoiceLabel!,
                  showFurigana: showFurigana,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        color: scheme.onSurface,
                        height: 1.35,
                        fontWeight: FontWeight.w600,
                      ),
                ),
            ],
          ),
          const SizedBox(height: 14),
        ],
        if (showMeta) ...[
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              if (jlpt != null) ...[
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: scheme.surfaceContainerLow,
                    borderRadius: BorderRadius.circular(999),
                    border: Border.all(
                      color: scheme.outlineVariant.withValues(alpha: 0.45),
                    ),
                  ),
                  child: Text(
                    jlpt,
                    style: Theme.of(context).textTheme.labelMedium?.copyWith(
                          color: scheme.onSurfaceVariant,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.2,
                        ),
                  ),
                ),
                if (score != null) const SizedBox(width: 12),
              ],
              if (score != null) DifficultyDots(filledCount: score),
            ],
          ),
          const SizedBox(height: 16),
        ],
        ExplanationPanel(
          title: wasCorrect == true ? 'Correct' : 'Review',
          body: question.explanation,
          bodyEnglish: question.explanationEn,
          isCorrect: wasCorrect,
          showFurigana: showFurigana,
          showEnglish: showEnglish,
        ),
        if (grammar.isNotEmpty) ...[
          const SizedBox(height: 18),
          Text(
            'Grammar focus',
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: scheme.onSurface,
                  letterSpacing: 0.15,
                ),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: grammar.map((t) => DiagnosticTagChip(label: t)).toList(),
          ),
        ],
        if (vocab.isNotEmpty) ...[
          const SizedBox(height: 18),
          Text(
            'Vocabulary',
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: scheme.onSurface,
                  letterSpacing: 0.15,
                ),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: vocab.map((t) => DiagnosticTagChip(label: t)).toList(),
          ),
        ],
        if (tags.isNotEmpty) ...[
          const SizedBox(height: 18),
          Text(
            'Practice signals',
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: scheme.onSurface,
                  letterSpacing: 0.15,
                ),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: tags.map((t) => DiagnosticTagChip(label: t)).toList(),
          ),
        ],
      ],
      ),
    );
  }
}
