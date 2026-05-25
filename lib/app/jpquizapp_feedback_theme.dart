import 'package:flutter/material.dart';

import 'color/oklch.dart';

/// Muted semantic colors for grading and emphasis (not Material [ColorScheme.error]).
@immutable
class JpQuizAppFeedbackColors extends ThemeExtension<JpQuizAppFeedbackColors> {
  const JpQuizAppFeedbackColors({
    required this.correct,
    required this.correctContainer,
    required this.correctGlow,
    required this.incorrect,
    required this.incorrectContainer,
    required this.warning,
    required this.warningContainer,
  });

  final Color correct;
  final Color correctContainer;

  /// OKLCH spec for the success-animation glow. By design `l > 1.0`, which the
  /// `oklch_glow.dart` primitives consume as additive light intensity. The
  /// sRGB-clamped color is still recoverable via `correctGlow.toColor()`.
  final Oklch correctGlow;

  final Color incorrect;
  final Color incorrectContainer;
  final Color warning;
  final Color warningContainer;

  /// OKLCH source-of-truth — perceptually uniform versions of the prior
  /// `hsl(146 68% 52%)` / `hsl(350 78% 62%)` / `hsl(40 92% 58%)` specs.
  /// `correctGlow` deliberately uses `l = 1.05` so success animations get a
  /// subtle additive halo on top of the clamped sRGB color.
  static final JpQuizAppFeedbackColors dark = JpQuizAppFeedbackColors(
    correct: const Oklch(0.751, 0.169, 153.6).toColor(),
    correctContainer: const Oklch(0.751, 0.169, 153.6, 0.157).toColor(),
    correctGlow: const Oklch(1.05, 0.180, 153.6),
    incorrect: const Oklch(0.663, 0.173, 10.4).toColor(),
    incorrectContainer: const Oklch(0.663, 0.173, 10.4, 0.157).toColor(),
    warning: const Oklch(0.850, 0.148, 88.8).toColor(),
    warningContainer: const Oklch(0.850, 0.148, 88.8, 0.188).toColor(),
  );

  @override
  JpQuizAppFeedbackColors copyWith({
    Color? correct,
    Color? correctContainer,
    Oklch? correctGlow,
    Color? incorrect,
    Color? incorrectContainer,
    Color? warning,
    Color? warningContainer,
  }) {
    return JpQuizAppFeedbackColors(
      correct: correct ?? this.correct,
      correctContainer: correctContainer ?? this.correctContainer,
      correctGlow: correctGlow ?? this.correctGlow,
      incorrect: incorrect ?? this.incorrect,
      incorrectContainer: incorrectContainer ?? this.incorrectContainer,
      warning: warning ?? this.warning,
      warningContainer: warningContainer ?? this.warningContainer,
    );
  }

  @override
  JpQuizAppFeedbackColors lerp(
    ThemeExtension<JpQuizAppFeedbackColors>? other,
    double t,
  ) {
    if (other is! JpQuizAppFeedbackColors) return this;
    return JpQuizAppFeedbackColors(
      correct: Color.lerp(correct, other.correct, t)!,
      correctContainer: Color.lerp(
        correctContainer,
        other.correctContainer,
        t,
      )!,
      // Keep the OKLCH spec (and its `l > 1.0` glow energy) snap-switched at
      // the midpoint so the additive overshoot doesn't accidentally blow up
      // mid-transition.
      correctGlow: t < 0.5 ? correctGlow : other.correctGlow,
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

extension JpQuizAppFeedbackColorsX on BuildContext {
  JpQuizAppFeedbackColors get jpQuizAppFeedback {
    return Theme.of(this).extension<JpQuizAppFeedbackColors>() ??
        JpQuizAppFeedbackColors.dark;
  }
}
