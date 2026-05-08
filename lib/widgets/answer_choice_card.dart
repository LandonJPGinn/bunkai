import 'package:flutter/material.dart';

import '../app/bunkai_feedback_theme.dart';
import '../app/bunkai_tokens.dart';
import '../services/furigana_inline.dart';
import 'correct_answer_celebration.dart';
import 'japanese_text_lookup.dart';

class AnswerChoiceCard extends StatelessWidget {
  const AnswerChoiceCard({
    super.key,
    required this.label,
    required this.labelEnglish,
    required this.selected,
    required this.onTap,
    this.locked = false,
    this.isCorrectChoice = false,
    this.showOutcome = false,
    this.celebrate = false,
    this.subtitle,
    this.subtitleEnglish,
    this.choiceIndex,
    this.choiceCount,
    required this.showFurigana,
    required this.showEnglish,
  });

  /// Japanese (or furigana-marked) surface for the option row.
  final String label;

  /// English gloss; when non-empty with [showEnglish], label renders as Latin text.
  final String labelEnglish;
  final bool selected;
  final VoidCallback? onTap;
  final bool locked;
  final bool isCorrectChoice;
  final bool showOutcome;

  /// Success celebration (selected correct submit only).
  final bool celebrate;

  /// Shown under [label] after submit when non-null (e.g. register tags).
  final String? subtitle;

  /// English counterpart to [subtitle].
  final String? subtitleEnglish;

  /// 0-based index for accessibility (e.g. “Option 2 of 4”).
  final int? choiceIndex;
  final int? choiceCount;
  final bool showFurigana;
  final bool showEnglish;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final feedback = context.bunkaiFeedback;
    final tokens = context.bunkaiTokens;
    final reduceMotion = MediaQuery.of(context).disableAnimations;
    final animDuration =
        reduceMotion ? Duration.zero : tokens.motionMedium;
    final animSlow = reduceMotion ? Duration.zero : tokens.motionSlow;
    final animCurve = tokens.motionStandardCurve;
    final animEmphasized = tokens.motionEmphasizedCurve;

    Color borderColor = scheme.outlineVariant.withValues(alpha: 0.45);
    Color fillColor = scheme.surfaceContainerHighest;
    const double borderWidth = 1.2;
    Color? textColor;

    if (showOutcome && !celebrate) {
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
      }
    } else if (selected && !celebrate) {
      borderColor = scheme.primary.withValues(alpha: 0.7);
      fillColor = scheme.primary.withValues(alpha: 0.12);
    }

    if (celebrate) {
      textColor = scheme.onSurface;
    }

    final int? idx = choiceIndex;
    final int? n = choiceCount;
    final String? hint = idx != null && n != null && n > 0
        ? 'Option ${idx + 1} of $n. Press ${idx + 1} to select.'
        : null;

    final bool showSubtitle =
        showOutcome && subtitle != null && subtitle!.isNotEmpty;
    final useEnLabel =
        showEnglish && labelEnglish.trim().isNotEmpty;
    final useEnSubtitle = showSubtitle &&
        showEnglish &&
        (subtitleEnglish?.trim().isNotEmpty ?? false);

    String a11yJp(String s) {
      if (!s.contains('[')) return s;
      return semanticsFuriganaLabel(
        parseFuriganaInline(s),
        showFurigana: showFurigana,
      );
    }
    final primaryA11y = useEnLabel ? labelEnglish.trim() : a11yJp(label);
    final subA11y =
        showSubtitle ? (useEnSubtitle ? subtitleEnglish!.trim() : a11yJp(subtitle!)) : '';
    final String semanticsLabel =
        showSubtitle ? '$primaryA11y. $subA11y' : primaryA11y;

    final titleStyle = Theme.of(context).textTheme.titleMedium!.copyWith(
          height: 1.35,
          color: textColor ?? scheme.onSurface,
        );
    final subtitleStyle = Theme.of(context).textTheme.bodySmall!.copyWith(
          color: textColor ?? scheme.onSurfaceVariant,
          height: 1.35,
        );

    final Widget subtitleWidget = showSubtitle
        ? Padding(
            key: ValueKey<String>(
              useEnSubtitle ? 'sub-en' : 'sub-jp:${subtitle ?? ''}',
            ),
            padding: const EdgeInsets.only(top: 6),
            child: useEnSubtitle
                ? Text(subtitleEnglish!.trim(), style: subtitleStyle)
                : JapaneseTextLookup(
                    text: subtitle!,
                    showFurigana: showFurigana,
                    includeSemantics: false,
                    style: subtitleStyle,
                  ),
          )
        : const SizedBox.shrink(key: ValueKey<String>('sub-empty'));

    final leading = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        useEnLabel
            ? Text(labelEnglish.trim(), style: titleStyle)
            : JapaneseTextLookup(
                text: label,
                showFurigana: showFurigana,
                includeSemantics: false,
                style: titleStyle,
              ),
        // AnimatedSize smooths the per-card height delta when the subtitle
        // appears post-submit, so each row doesn't pop into place.
        AnimatedSize(
          duration: animSlow,
          curve: animEmphasized,
          alignment: Alignment.topLeft,
          child: AnimatedSwitcher(
            duration: animDuration,
            switchInCurve: animCurve,
            switchOutCurve: animCurve,
            transitionBuilder: (child, animation) =>
                FadeTransition(opacity: animation, child: child),
            child: subtitleWidget,
          ),
        ),
      ],
    );

    final Widget celebrateBody = CorrectAnswerCelebrationFrame(
      key: const ValueKey<String>('answer-celebrate'),
      reduceMotion: reduceMotion,
      feedback: feedback,
      scheme: scheme,
      onTap: locked ? null : onTap,
      leading: leading,
    );
    final Widget staticBody = AnimatedContainer(
      key: const ValueKey<String>('answer-static'),
      duration: animDuration,
      curve: animCurve,
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
                duration: animDuration,
                curve: animCurve,
                style: Theme.of(context).textTheme.titleMedium!.copyWith(
                      height: 1.35,
                      color: textColor ?? scheme.onSurface,
                    ),
                child: leading,
              ),
            ),
          ),
        ),
      ),
    );

    // AnimatedSwitcher cross-fades the celebration into the static
    // representation when the user moves to the next question, so the
    // celebration doesn't pop away.
    final Widget body = AnimatedSwitcher(
      duration: animDuration,
      switchInCurve: animCurve,
      switchOutCurve: animCurve,
      transitionBuilder: (child, animation) =>
          FadeTransition(opacity: animation, child: child),
      child: celebrate ? celebrateBody : staticBody,
    );

    return Semantics(
      button: true,
      enabled: !locked,
      selected: selected,
      label: semanticsLabel,
      hint: hint,
      child: ExcludeSemantics(
        child: body,
      ),
    );
  }
}
