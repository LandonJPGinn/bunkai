import 'furigana_inline.dart';

/// Lightweight normalization for comparing quiz bank strings without NLP.
///
/// Strips optional inline `kanji[reading]` furigana markup first, then trims,
/// collapses whitespace (including U+3000), maps fullwidth ASCII-range
/// characters to halfwidth, and maps a few common CJK punctuation variants to
/// ASCII where unlikely to change meaning for duplicate detection.
String normalizeQuizBankText(String input) {
  final buf = StringBuffer();
  for (final unit in stripInlineFuriganaMarkup(input).runes) {
    if (unit >= 0xFF01 && unit <= 0xFF5E) {
      buf.writeCharCode(unit - 0xFEE0);
    } else if (unit == 0x3000) {
      buf.write(' ');
    } else if (unit == 0x3001) {
      // Ideographic comma → ASCII comma
      buf.write(',');
    } else if (unit == 0x3002) {
      // Ideographic full stop → ASCII period
      buf.write('.');
    } else {
      buf.writeCharCode(unit);
    }
  }
  var s = buf.toString().trim();
  if (s.isEmpty) return '';
  s = s.replaceAll(RegExp(r'\s+'), ' ');
  return s;
}
