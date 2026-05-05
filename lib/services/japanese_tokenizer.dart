import 'furigana_inline.dart';

/// Segment kinds produced by [JapaneseTokenizer.tokenize].
sealed class TokenSegment {
  const TokenSegment();
}

/// Printable text with no interaction (spaces, newlines, Latin, punctuation,
/// kana runs not in dictionary).
final class PlainSegment extends TokenSegment {
  const PlainSegment(this.text);
  final String text;
}

/// Clickable token backed by the dictionary.
final class DictSegment extends TokenSegment {
  const DictSegment(this.surface);
  final String surface;
}

/// Single ideograph or sequence not in dictionary (optional fallback UI).
final class UnknownKanjiSegment extends TokenSegment {
  const UnknownKanjiSegment(this.text);
  final String text;
}

/// Longest-match tokenizer using only dictionary surfaces.
///
/// Swappable later for Kuromoji/Sudachi/MeCab without changing quiz widgets.
class JapaneseTokenizer {
  JapaneseTokenizer({
    required Set<String> dictionarySurfaces,
    required int maxSurfaceLength,
  })  : _dict = dictionarySurfaces,
        _maxLen = maxSurfaceLength;

  final Set<String> _dict;
  final int _maxLen;

  factory JapaneseTokenizer.fromSurfaces(Iterable<String> surfaces) {
    var maxLen = 1;
    final set = <String>{};
    for (final s in surfaces) {
      if (s.isEmpty) continue;
      set.add(s);
      if (s.length > maxLen) maxLen = s.length;
    }
    return JapaneseTokenizer(dictionarySurfaces: set, maxSurfaceLength: maxLen);
  }

  /// Greedy longest match from each cursor position. Does not parse furigana
  /// markup — pass strings already split into plain/ruby bases elsewhere.
  List<TokenSegment> tokenize(String input) {
    if (input.isEmpty) return const [];

    final runes = input.runes.toList();
    final out = <TokenSegment>[];
    var i = 0;

    while (i < runes.length) {
      final r = runes[i];

      if (_isWhitespaceRune(r)) {
        var j = i;
        while (j < runes.length && _isWhitespaceRune(runes[j])) {
          j++;
        }
        out.add(PlainSegment(String.fromCharCodes(runes.sublist(i, j))));
        i = j;
        continue;
      }

      if (_isLatinOrDigitRune(r)) {
        var j = i;
        while (j < runes.length && _isLatinOrDigitRune(runes[j])) {
          j++;
        }
        out.add(PlainSegment(String.fromCharCodes(runes.sublist(i, j))));
        i = j;
        continue;
      }

      if (_isAsciiPunctuation(r)) {
        out.add(PlainSegment(String.fromCharCodes([r])));
        i++;
        continue;
      }

      if (_isPunctuationOrSymbol(r)) {
        out.add(PlainSegment(String.fromCharCodes([r])));
        i++;
        continue;
      }

      if (_isJapaneseScriptRune(r)) {
        final sliceEnd = (i + _maxLen).clamp(0, runes.length);
        var matched = false;
        for (var len = sliceEnd - i; len >= 1; len--) {
          final end = i + len;
          if (end > runes.length) continue;
          final candidate = String.fromCharCodes(runes.sublist(i, end));
          if (_dict.contains(candidate)) {
            out.add(DictSegment(candidate));
            i = end;
            matched = true;
            break;
          }
        }
        if (matched) continue;

        if (isCjkIdeographRune(r)) {
          out.add(UnknownKanjiSegment(String.fromCharCodes([r])));
          i++;
          continue;
        }

        var j = i + 1;
        while (j < runes.length &&
            _isKanaRune(runes[j]) &&
            !_isWhitespaceRune(runes[j])) {
          j++;
        }
        out.add(PlainSegment(String.fromCharCodes(runes.sublist(i, j))));
        i = j;
        continue;
      }

      out.add(PlainSegment(String.fromCharCodes([r])));
      i++;
    }

    return out;
  }
}

bool _isWhitespaceRune(int r) {
  if (r == 0x20 || r == 0x09 || r == 0x0A || r == 0x0D) return true;
  return r == 0x3000;
}

bool _isLatinOrDigitRune(int r) {
  if (r >= 0x30 && r <= 0x39) return true;
  if (r >= 0x41 && r <= 0x5A) return true;
  if (r >= 0x61 && r <= 0x7A) return true;
  return false;
}

bool _isAsciiPunctuation(int r) {
  if (r < 0x20 || r > 0x7E) return false;
  if (_isLatinOrDigitRune(r) || r == 0x20) return false;
  return true;
}

bool _isKanaRune(int r) {
  if (r >= 0x3040 && r <= 0x309F) return true;
  if (r >= 0x30A0 && r <= 0x30FF) return true;
  return false;
}

bool _isJapaneseScriptRune(int r) {
  return isCjkIdeographRune(r) || _isKanaRune(r);
}

bool _isPunctuationOrSymbol(int r) {
  if (r >= 0x3000 && r <= 0x303F) return true;
  if (r >= 0xFF01 && r <= 0xFF0F) return true;
  if (r >= 0xFF1A && r <= 0xFF20) return true;
  if (r == 0x3001 ||
      r == 0x3002 ||
      r == 0xFF0C ||
      r == 0xFF0E ||
      r == 0x30FB) {
    return true;
  }
  if (r == 0x201C ||
      r == 0x201D ||
      r == 0x2018 ||
      r == 0x2019 ||
      r == 0x300C ||
      r == 0x300D ||
      r == 0x300E ||
      r == 0x300F) {
    return true;
  }
  return false;
}
