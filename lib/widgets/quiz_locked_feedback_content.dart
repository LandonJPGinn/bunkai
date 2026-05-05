import 'package:flutter/material.dart';

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
    required this.wasCorrect,
    required this.showFurigana,
  });

  final QuizQuestion question;
  final String? wrongChoiceLabel;
  final bool? wasCorrect;
  final bool showFurigana;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final tags = question.diagnosticTags;
    final jlpt = question.jlptLevel;
    final score = question.difficultyScore;
    final grammar = question.grammarPoints;
    final vocab = question.vocabulary;
    final showMeta = jlpt != null || score != null;

    return Column(
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
          isCorrect: wasCorrect,
          showFurigana: showFurigana,
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
    );
  }
}
