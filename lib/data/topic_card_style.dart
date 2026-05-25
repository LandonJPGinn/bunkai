import 'package:flutter/material.dart';

import '../app/color/oklch.dart';
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

  /// Linear gradient endpoints (OKLCH-derived palette).
  final Color bg1;
  final Color bg2;

  /// Rotation for the oversized backdrop glyph.
  final double tiltDegrees;
}

Color _oklch(double l, double c, double h) => Oklch(l, c, h).toColor();

/// Default style when a quiz id has no explicit entry.
final TopicCardStyle topicCardStyleDefault = TopicCardStyle(
  kanji: '語',
  accent: _oklch(0.7248, 0.1541, 244.30),
  bg1: _oklch(0.6952, 0.1561, 245.05),
  bg2: _oklch(0.5623, 0.2024, 285.50),
  tiltDegrees: -4,
);

/// Per-quiz styling (keyed by stable ids vs JSON titles).
final Map<String, TopicCardStyle> topicCardStyles = {
  QuizId.particleForensics: TopicCardStyle(
    kanji: '助',
    accent: _oklch(0.6985, 0.1932, 31.17),
    bg1: _oklch(0.6902, 0.1895, 31.14),
    bg2: _oklch(0.7789, 0.1549, 64.71),
    tiltDegrees: -4,
  ),
  QuizId.clauseUntangler: TopicCardStyle(
    kanji: '文',
    accent: _oklch(0.8014, 0.1626, 70.62),
    bg1: _oklch(0.7569, 0.1610, 60.02),
    bg2: _oklch(0.8917, 0.1513, 95.02),
    tiltDegrees: 3,
  ),
  QuizId.omissionDetective: TopicCardStyle(
    kanji: '欠',
    accent: _oklch(0.6777, 0.1180, 53.10),
    bg1: _oklch(0.6933, 0.0907, 50.79),
    bg2: _oklch(0.8130, 0.0427, 69.04),
    tiltDegrees: -2,
  ),
  QuizId.registerRadar: TopicCardStyle(
    kanji: '敬',
    accent: _oklch(0.6007, 0.1106, 151.04),
    bg1: _oklch(0.6685, 0.1349, 147.49),
    bg2: _oklch(0.7967, 0.0744, 165.77),
    tiltDegrees: 4,
  ),
  QuizId.transitivityDuel: TopicCardStyle(
    kanji: '他',
    accent: _oklch(0.7248, 0.1541, 244.30),
    bg1: _oklch(0.6952, 0.1561, 245.05),
    bg2: _oklch(0.5623, 0.2024, 285.50),
    tiltDegrees: -3,
  ),
  QuizId.verbConjugation: TopicCardStyle(
    kanji: '活',
    accent: _oklch(0.7226, 0.1367, 318.08),
    bg1: _oklch(0.6309, 0.1448, 317.27),
    bg2: _oklch(0.7225, 0.0941, 338.16),
    tiltDegrees: 5,
  ),
};

TopicCardStyle topicCardStyleFor(String id) =>
    topicCardStyles[id] ?? topicCardStyleDefault;
