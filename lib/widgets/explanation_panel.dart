import 'package:flutter/material.dart';

import '../app/bunkai_feedback_theme.dart';
import 'japanese_text_lookup.dart';

class ExplanationPanel extends StatelessWidget {
  const ExplanationPanel({
    super.key,
    required this.title,
    required this.body,
    this.isCorrect,
    this.showFurigana = true,
  });

  final String title;
  final String body;
  final bool? isCorrect;
  final bool showFurigana;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final feedback = context.bunkaiFeedback;

    final (Color borderColor, Color bgColor) = switch (isCorrect) {
      true => (
          feedback.correct.withValues(alpha: 0.55),
          Color.alphaBlend(
            feedback.correctContainer,
            scheme.surfaceContainerLow,
          ),
        ),
      false => (
          feedback.incorrect.withValues(alpha: 0.52),
          Color.alphaBlend(
            feedback.incorrectContainer,
            scheme.surfaceContainerLow,
          ),
        ),
      null => (
          scheme.outlineVariant.withValues(alpha: 0.45),
          scheme.surfaceContainerLow,
        ),
    };

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: scheme.onSurface,
                  letterSpacing: 0.2,
                ),
          ),
          const SizedBox(height: 8),
          JapaneseTextLookup(
            text: body,
            showFurigana: showFurigana,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: scheme.onSurfaceVariant,
                  height: 1.45,
                ),
          ),
        ],
      ),
    );
  }
}
