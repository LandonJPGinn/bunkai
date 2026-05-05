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

  /// Spec: success hsl(146 68% 52%), danger hsl(350 78% 62%), warning hsl(40 92% 58%).
  static const BunkaiFeedbackColors dark = BunkaiFeedbackColors(
    correct: Color(0xFF3DCC7A),
    correctContainer: Color(0x283DCC7A),
    incorrect: Color(0xFFE85D7A),
    incorrectContainer: Color(0x28E85D7A),
    warning: Color(0xFFF5C84A),
    warningContainer: Color(0x30F5C84A),
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
  BunkaiFeedbackColors lerp(
    ThemeExtension<BunkaiFeedbackColors>? other,
    double t,
  ) {
    if (other is! BunkaiFeedbackColors) return this;
    return BunkaiFeedbackColors(
      correct: Color.lerp(correct, other.correct, t)!,
      correctContainer: Color.lerp(
        correctContainer,
        other.correctContainer,
        t,
      )!,
      incorrect: Color.lerp(incorrect, other.incorrect, t)!,
      incorrectContainer: Color.lerp(
        incorrectContainer,
        other.incorrectContainer,
        t,
      )!,
      warning: Color.lerp(warning, other.warning, t)!,
      warningContainer: Color.lerp(
        warningContainer,
        other.warningContainer,
        t,
      )!,
    );
  }
}

extension BunkaiFeedbackColorsX on BuildContext {
  BunkaiFeedbackColors get bunkaiFeedback {
    return Theme.of(this).extension<BunkaiFeedbackColors>() ??
        BunkaiFeedbackColors.dark;
  }
}
