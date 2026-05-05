import 'package:flutter/material.dart';

import '../app/bunkai_feedback_theme.dart';
import '../services/furigana_inline.dart';
import 'japanese_text_lookup.dart';

class AnswerChoiceCard extends StatelessWidget {
  const AnswerChoiceCard({
    super.key,
    required this.label,
    required this.selected,
    required this.onTap,
    this.locked = false,
    this.isCorrectChoice = false,
    this.showOutcome = false,
    this.subtitle,
    this.choiceIndex,
    this.choiceCount,
    required this.showFurigana,
  });

  final String label;
  final bool selected;
  final VoidCallback? onTap;
  final bool locked;
  final bool isCorrectChoice;
  final bool showOutcome;

  /// Shown under [label] after submit when non-null (e.g. register tags).
  final String? subtitle;

  /// 0-based index for accessibility (e.g. “Option 2 of 4”).
  final int? choiceIndex;
  final int? choiceCount;
  final bool showFurigana;

  static const _kAnimDuration = Duration(milliseconds: 220);
  static const _kAnimCurve = Curves.easeOutCubic;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final feedback = context.bunkaiFeedback;

    Color borderColor = scheme.outlineVariant.withValues(alpha: 0.45);
    Color fillColor = scheme.surfaceContainerHighest;
    double borderWidth = 1.2;
    Color? textColor;

    if (showOutcome) {
      if (isCorrectChoice) {
        borderColor = feedback.correct.withValues(alpha: 0.75);
        fillColor = Color.alphaBlend(
          feedback.correctContainer,
          scheme.surfaceContainerHighest,
        );
        textColor = scheme.onSurface;
      } else if (selected) {
        borderColor = feedback.incorrect.withValues(alpha: 0.72);
        fillColor = Color.alphaBlend(
          feedback.incorrectContainer,
          scheme.surfaceContainerHighest,
        );
        textColor = scheme.onSurface;
      } else {
        borderColor = scheme.outlineVariant.withValues(alpha: 0.22);
        fillColor = scheme.surface.withValues(alpha: 0.55);
        textColor = scheme.onSurfaceVariant.withValues(alpha: 0.65);
        borderWidth = 1;
      }
    } else if (selected) {
      borderColor = scheme.primary.withValues(alpha: 0.7);
      fillColor = scheme.primary.withValues(alpha: 0.12);
    }

    final int? idx = choiceIndex;
    final int? n = choiceCount;
    final String? hint = idx != null && n != null && n > 0
        ? 'Option ${idx + 1} of $n. Press ${idx + 1} to select.'
        : null;

    final bool showSubtitle =
        showOutcome && subtitle != null && subtitle!.isNotEmpty;
    String a11y(String s) {
      if (!s.contains('[')) return s;
      return semanticsFuriganaLabel(
        parseFuriganaInline(s),
        showFurigana: showFurigana,
      );
    }
    final String semanticsLabel = showSubtitle
        ? '${a11y(label)}. ${a11y(subtitle!)}'
        : a11y(label);

    return Semantics(
      button: true,
      enabled: !locked,
      selected: selected,
      label: semanticsLabel,
      hint: hint,
      child: ExcludeSemantics(
        child: AnimatedContainer(
          duration: _kAnimDuration,
          curve: _kAnimCurve,
          decoration: BoxDecoration(
            color: fillColor,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: borderColor, width: borderWidth),
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: locked ? null : onTap,
              borderRadius: BorderRadius.circular(16),
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: AnimatedDefaultTextStyle(
                    duration: _kAnimDuration,
                    curve: _kAnimCurve,
                    style: Theme.of(context).textTheme.titleMedium!.copyWith(
                          height: 1.35,
                          color: textColor ?? scheme.onSurface,
                        ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        JapaneseTextLookup(
                          text: label,
                          showFurigana: showFurigana,
                          includeSemantics: false,
                          style: Theme.of(context).textTheme.titleMedium!.copyWith(
                                height: 1.35,
                                color: textColor ?? scheme.onSurface,
                              ),
                        ),
                        if (showSubtitle) ...[
                          const SizedBox(height: 6),
                          JapaneseTextLookup(
                            text: subtitle!,
                            showFurigana: showFurigana,
                            includeSemantics: false,
                            style: Theme.of(context)
                                .textTheme
                                .bodySmall
                                ?.copyWith(
                                  color:
                                      textColor ?? scheme.onSurfaceVariant,
                                  height: 1.35,
                                ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
