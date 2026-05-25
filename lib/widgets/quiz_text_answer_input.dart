import 'package:flutter/material.dart';

import '../app/jpquizapp_feedback_theme.dart';
import '../app/jpquizapp_tokens.dart';

class QuizTextAnswerInput extends StatelessWidget {
  const QuizTextAnswerInput({
    super.key,
    required this.controller,
    required this.focusNode,
    required this.locked,
    required this.wasCorrect,
    this.onSubmitted,
  });

  final TextEditingController controller;
  final FocusNode focusNode;
  final bool locked;
  final bool? wasCorrect;
  final VoidCallback? onSubmitted;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final feedback = context.jpQuizAppFeedback;
    final tokens = context.jpQuizAppTokens;

    var borderColor = scheme.outlineVariant.withValues(alpha: 0.45);
    var fillColor = scheme.surfaceContainerHighest;
    if (locked) {
      if (wasCorrect == true) {
        borderColor = feedback.correct.withValues(alpha: 0.75);
        fillColor = Color.alphaBlend(
          feedback.correctContainer,
          scheme.surfaceContainerHighest,
        );
      } else {
        borderColor = feedback.incorrect.withValues(alpha: 0.72);
        fillColor = Color.alphaBlend(
          feedback.incorrectContainer,
          scheme.surfaceContainerHighest,
        );
      }
    }

    return AnimatedContainer(
      duration: MediaQuery.of(context).disableAnimations
          ? Duration.zero
          : tokens.motionMedium,
      curve: tokens.motionStandardCurve,
      decoration: BoxDecoration(
        color: fillColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor, width: 1.2),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Type your answer',
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  color: scheme.onSurfaceVariant,
                  fontWeight: FontWeight.w600,
                ),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: controller,
            focusNode: focusNode,
            enabled: !locked,
            textInputAction: TextInputAction.done,
            onSubmitted: (_) => onSubmitted?.call(),
            decoration: InputDecoration(
              hintText: 'Type romaji (auto-converts to hiragana)',
              isDense: true,
              filled: true,
              fillColor: scheme.surface,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
