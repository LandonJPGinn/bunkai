import 'package:flutter/material.dart';

import '../models/quiz_id.dart';

/// Visual tokens for the home grid poster cards. Extend [topicCardStyles] for new quizzes.
class TopicCardStyle {
  const TopicCardStyle({
    required this.kanji,
    required this.accent,
    required this.bg1,
    required this.bg2,
    required this.tiltDegrees,
  });

  /// Single decorative kanji (backdrop); not used for content.
  final String kanji;

  /// Tag pill text color and highlights.
  final Color accent;

  /// Linear gradient endpoints (HSL-inspired palette).
  final Color bg1;
  final Color bg2;

  /// Rotation for the oversized backdrop glyph.
  final double tiltDegrees;
}

Color _hsl(double h, double s, double l) {
  return HSLColor.fromAHSL(1.0, h, s / 100.0, l / 100.0).toColor();
}

/// Default style when a [QuizId] has no explicit entry.
final TopicCardStyle topicCardStyleDefault = TopicCardStyle(
  kanji: '語',
  accent: _hsl(205, 100, 62),
  bg1: _hsl(205, 92, 58),
  bg2: _hsl(250, 72, 62),
  tiltDegrees: -4,
);

/// Per-quiz styling (keyed by [QuizId] for stable lookups vs JSON titles).
final Map<QuizId, TopicCardStyle> topicCardStyles = {
  QuizId.particleForensics: TopicCardStyle(
    kanji: '助',
    accent: _hsl(8, 100, 65),
    bg1: _hsl(8, 95, 64),
    bg2: _hsl(32, 95, 60),
    tiltDegrees: -4,
  ),
  QuizId.clauseUntangler: TopicCardStyle(
    kanji: '文',
    accent: _hsl(36, 100, 58),
    bg1: _hsl(30, 94, 58),
    bg2: _hsl(48, 95, 66),
    tiltDegrees: 3,
  ),
  QuizId.omissionDetective: TopicCardStyle(
    kanji: '欠',
    accent: _hsl(24, 58, 56),
    bg1: _hsl(22, 48, 60),
    bg2: _hsl(31, 36, 74),
    tiltDegrees: -2,
  ),
  QuizId.registerRadar: TopicCardStyle(
    kanji: '敬',
    accent: _hsl(137, 34, 43),
    bg1: _hsl(130, 34, 50),
    bg2: _hsl(154, 38, 68),
    tiltDegrees: 4,
  ),
  QuizId.transitivityDuel: TopicCardStyle(
    kanji: '他',
    accent: _hsl(205, 100, 62),
    bg1: _hsl(205, 92, 58),
    bg2: _hsl(250, 72, 62),
    tiltDegrees: -3,
  ),
  QuizId.verbConjugation: TopicCardStyle(
    kanji: '活',
    accent: _hsl(286, 55, 70),
    bg1: _hsl(285, 42, 59),
    bg2: _hsl(318, 38, 68),
    tiltDegrees: 5,
  ),
};

TopicCardStyle topicCardStyleFor(QuizId id) =>
    topicCardStyles[id] ?? topicCardStyleDefault;
