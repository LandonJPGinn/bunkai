import 'package:flutter/material.dart';

import '../app/bunkai_feedback_theme.dart';
import 'japanese_text_lookup.dart';
class ExplanationPanel extends StatelessWidget {
  const ExplanationPanel({
    super.key,
    required this.title,
    required this.body,
    required this.bodyEnglish,
    this.isCorrect,
    this.showFurigana = true,
    this.showEnglish = false,
  });

  final String title;
  final String body;
  final String bodyEnglish;
  final bool? isCorrect;
  final bool showFurigana;
  final bool showEnglish;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final feedback = context.bunkaiFeedback;
    final en = bodyEnglish.trim();
    final hasEn = en.isNotEmpty;

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
          if (showEnglish && hasEn) ...[
            Text(
              en,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: scheme.onSurfaceVariant,
                    height: 1.45,
                  ),
            ),
          ] else if (showEnglish) ...[
            JapaneseTextLookup(
              text: body,
              showFurigana: showFurigana,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: scheme.onSurfaceVariant,
                    height: 1.45,
                  ),
            ),
          ] else ...[
            JapaneseTextLookup(
              text: body,
              showFurigana: showFurigana,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: scheme.onSurfaceVariant,
                    height: 1.45,
                  ),
            ),
            if (hasEn) ...[
              const SizedBox(height: 10),
              Text(
                en,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: scheme.onSurfaceVariant.withValues(alpha: 0.88),
                      height: 1.45,
                    ),
              ),
            ],
          ],
        ],
      ),
    );
  }
}
