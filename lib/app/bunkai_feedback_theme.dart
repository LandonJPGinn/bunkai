import 'package:flutter/material.dart';

/// Muted semantic colors for grading and emphasis (not Material [ColorScheme.error]).
@immutable
class BunkaiFeedbackColors extends ThemeExtension<BunkaiFeedbackColors> {
  const BunkaiFeedbackColors({
    required this.correct,
    required this.correctContainer,
    required this.incorrect,
    required this.incorrectContainer,
    required this.warning,
    required this.warningContainer,
  });

  final Color correct;
  final Color correctContainer;
  final Color incorrect;
  final Color incorrectContainer;
  final Color warning;
  final Color warningContainer;

  static const BunkaiFeedbackColors dark = BunkaiFeedbackColors(
    correct: Color(0xFF5E9B7E),
    correctContainer: Color(0x1A5E9B7E),
    incorrect: Color(0xFF7A2F36),
    incorrectContainer: Color(0x1A7A2F36),
    warning: Color(0xFFD4A84B),
    warningContainer: Color(0x26D4A84B),
  );

  @override
  BunkaiFeedbackColors copyWith({
    Color? correct,
    Color? correctContainer,
    Color? incorrect,
    Color? incorrectContainer,
    Color? warning,
    Color? warningContainer,
  }) {
    return BunkaiFeedbackColors(
      correct: correct ?? this.correct,
      correctContainer: correctContainer ?? this.correctContainer,
      incorrect: incorrect ?? this.incorrect,
      incorrectContainer: incorrectContainer ?? this.incorrectContainer,
      warning: warning ?? this.warning,
      warningContainer: warningContainer ?? this.warningContainer,
    );
  }

  @override
  BunkaiFeedbackColors lerp(ThemeExtension<BunkaiFeedbackColors>? other, double t) {
    if (other is! BunkaiFeedbackColors) return this;
    return BunkaiFeedbackColors(
      correct: Color.lerp(correct, other.correct, t)!,
      correctContainer: Color.lerp(correctContainer, other.correctContainer, t)!,
      incorrect: Color.lerp(incorrect, other.incorrect, t)!,
      incorrectContainer: Color.lerp(incorrectContainer, other.incorrectContainer, t)!,
      warning: Color.lerp(warning, other.warning, t)!,
      warningContainer: Color.lerp(warningContainer, other.warningContainer, t)!,
    );
  }
}

extension BunkaiFeedbackColorsX on BuildContext {
  BunkaiFeedbackColors get bunkaiFeedback {
    return Theme.of(this).extension<BunkaiFeedbackColors>() ??
        BunkaiFeedbackColors.dark;
  }
}
