import 'package:flutter/material.dart';

import 'japanese_text_lookup.dart';

/// Prompt, Japanese line, and optional dialogue/context line for one question.
class QuizPromptCard extends StatelessWidget {
  const QuizPromptCard({
    super.key,
    required this.prompt,
    required this.japanese,
    this.contextLine,
    required this.showFurigana,
  });

  final String prompt;
  final String japanese;
  final String? contextLine;
  final bool showFurigana;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHigh.withValues(alpha: 0.65),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: scheme.outlineVariant.withValues(alpha: 0.45),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(22, 22, 22, 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            JapaneseTextLookup(
              text: prompt,
              showFurigana: showFurigana,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    height: 1.45,
                    fontWeight: FontWeight.w500,
                  ),
            ),
            if (japanese != prompt) ...[
              const SizedBox(height: 10),
              JapaneseTextLookup(
                text: japanese,
                showFurigana: showFurigana,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      height: 1.45,
                    ),
              ),
            ],
            if (contextLine != null) ...[
              const SizedBox(height: 8),
              JapaneseTextLookup(
                text: contextLine!,
                showFurigana: showFurigana,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: scheme.onSurfaceVariant,
                      height: 1.4,
                    ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
