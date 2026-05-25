import 'package:jpquizapp/services/japanese_tokenizer.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late JapaneseTokenizer tok;

  setUp(() {
    tok = JapaneseTokenizer.fromSurfaces({'食べる', '本', 'を', '先生', 'である'});
  });

  test('longest match prefers longer dictionary string', () {
    final t = JapaneseTokenizer.fromSurfaces({'食べ', '食べる'});
    final s = t.tokenize('食べる');
    expect(s.length, 1);
    expect(s.first, isA<DictSegment>());
    expect((s.first as DictSegment).surface, '食べる');
  });

  test('preserves spaces and newlines as plain', () {
    final s = tok.tokenize('本 を');
    expect(s[0], isA<DictSegment>());
    expect((s[0] as DictSegment).surface, '本');
    expect(s[1], isA<PlainSegment>());
    expect((s[1] as PlainSegment).text, ' ');
    expect(s[2], isA<DictSegment>());
    expect((s[2] as DictSegment).surface, 'を');
  });

  test('ascii punctuation is plain', () {
    final s = tok.tokenize('Hi.');
    expect(s.length, 2);
    expect((s[0] as PlainSegment).text, 'Hi');
    expect((s[1] as PlainSegment).text, '.');
  });

  test('unknown kanji emits unknown segment', () {
    final s = tok.tokenize('貘');
    expect(s.length, 1);
    expect(s.first, isA<UnknownKanjiSegment>());
  });
}
