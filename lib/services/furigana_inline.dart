// Inline furigana: `kanjiCluster[よみ]` — cluster is consecutive CJK ideographs
// before `[`. Unmatched `[` or missing `]` is treated as literal from `[` onward.

/// One span of plain text or a ruby pair (base is always non-empty for [RubyPart]).
sealed class FuriganaPart {
  const FuriganaPart();
}

final class PlainPart extends FuriganaPart {
  const PlainPart(this.text);
  final String text;
}

final class RubyPart extends FuriganaPart {
  const RubyPart({required this.base, required this.reading});
  final String base;
  final String reading;
}

bool isCjkIdeographRune(int r) {
  if (r >= 0x4E00 && r <= 0x9FFF) return true;
  if (r >= 0x3400 && r <= 0x4DBF) return true;
  if (r >= 0xF900 && r <= 0xFAFF) return true;
  if (r == 0x3005 || r == 0x3007) return true;
  if (r >= 0x20000 && r <= 0x2A6DF) return true;
  if (r >= 0x2A700 && r <= 0x2B73F) return true;
  if (r >= 0x2B740 && r <= 0x2B81F) return true;
  if (r >= 0x2B820 && r <= 0x2CEAF) return true;
  if (r >= 0x2CEB0 && r <= 0x2EBEF) return true;
  return false;
}

List<int> _runesOf(String s) => s.runes.toList();

String _stringFromRunes(List<int> runes, int start, int end) {
  if (start >= end) return '';
  return String.fromCharCodes(runes.sublist(start, end));
}

/// Parses [input] into ordered plain / ruby parts for rendering or surface extraction.
List<FuriganaPart> parseFuriganaInline(String input) {
  final runes = _runesOf(input);
  final out = <FuriganaPart>[];
  var i = 0;
  while (i < runes.length) {
    final open = runes.indexOf(0x5B, i); // '['
    if (open == -1) {
      final tail = _stringFromRunes(runes, i, runes.length);
      if (tail.isNotEmpty) out.add(PlainPart(tail));
      break;
    }
    final close = runes.indexOf(0x5D, open + 1); // ']'
    if (close == -1) {
      final tail = _stringFromRunes(runes, i, runes.length);
      if (tail.isNotEmpty) out.add(PlainPart(tail));
      break;
    }
    var baseStart = open;
    while (baseStart > i && isCjkIdeographRune(runes[baseStart - 1])) {
      baseStart--;
    }
    final base = _stringFromRunes(runes, baseStart, open);
    final reading = _stringFromRunes(runes, open + 1, close);
    if (baseStart > i) {
      out.add(PlainPart(_stringFromRunes(runes, i, baseStart)));
    }
    if (base.isEmpty) {
      out.add(PlainPart(_stringFromRunes(runes, open, close + 1)));
    } else {
      out.add(RubyPart(base: base, reading: reading));
    }
    i = close + 1;
  }
  return out;
}

/// Surface text: readings and brackets removed; same visible line as furigana-off.
String surfaceFromFuriganaParts(List<FuriganaPart> parts) {
  final buf = StringBuffer();
  for (final p in parts) {
    switch (p) {
      case PlainPart(:final text):
        buf.write(text);
      case RubyPart(:final base):
        buf.write(base);
    }
  }
  return buf.toString();
}

/// Strips optional `kanji[reading]` markup for duplicate detection / plain comparison.
String stripInlineFuriganaMarkup(String input) {
  if (!input.contains('[')) return input;
  return surfaceFromFuriganaParts(parseFuriganaInline(input));
}

/// Full phrase for semantics / screen readers (readings in parentheses after base).
String semanticsFuriganaLabel(List<FuriganaPart> parts, {required bool showFurigana}) {
  final buf = StringBuffer();
  for (final p in parts) {
    switch (p) {
      case PlainPart(:final text):
        buf.write(text);
      case RubyPart(:final base, :final reading):
        buf.write(base);
        if (showFurigana && reading.isNotEmpty) {
          buf.write('（$reading）');
        }
    }
  }
  return buf.toString();
}
