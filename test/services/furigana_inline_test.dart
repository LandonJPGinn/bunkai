import 'package:jpquizapp/services/furigana_inline.dart';
import 'package:jpquizapp/services/quiz_bank_text_normalize.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('parseFuriganaInline', () {
    test('plain string is one plain part', () {
      final p = parseFuriganaInline('食べる');
      expect(p.length, 1);
      expect(p[0], isA<PlainPart>());
      expect((p[0] as PlainPart).text, '食べる');
    });

    test('single ruby cluster', () {
      final p = parseFuriganaInline('本[ほん]');
      expect(p.length, 1);
      final r = p[0] as RubyPart;
      expect(r.base, '本');
      expect(r.reading, 'ほん');
    });

    test('plain between and after clusters', () {
      final p = parseFuriganaInline('本[ほん]を読[よ]みます');
      expect(p.length, 4);
      expect((p[0] as RubyPart).base, '本');
      expect((p[0] as RubyPart).reading, 'ほん');
      expect((p[1] as PlainPart).text, 'を');
      expect((p[2] as RubyPart).base, '読');
      expect((p[2] as RubyPart).reading, 'よ');
      expect((p[3] as PlainPart).text, 'みます');
    });

    test('multi-kanji base', () {
      final p = parseFuriganaInline('東京[とうきょう]へ');
      expect(p.length, 2);
      expect((p[0] as RubyPart).base, '東京');
      expect((p[0] as RubyPart).reading, 'とうきょう');
      expect((p[1] as PlainPart).text, 'へ');
    });

    test(
      'no kanji before bracket yields plain prefix plus literal brackets',
      () {
        final p = parseFuriganaInline('を[よ]');
        expect(p.length, 2);
        expect((p[0] as PlainPart).text, 'を');
        expect((p[1] as PlainPart).text, '[よ]');
        expect(stripInlineFuriganaMarkup('を[よ]'), 'を[よ]');
      },
    );

    test('unclosed bracket is plain rest', () {
      final p = parseFuriganaInline('本[ほん');
      expect(p.length, 1);
      expect((p[0] as PlainPart).text, '本[ほん');
    });
  });

  group('surfaceFromFuriganaParts / stripInlineFuriganaMarkup', () {
    test('strip removes readings', () {
      expect(stripInlineFuriganaMarkup('本[ほん]を読[よ]みます'), '本を読みます');
    });

    test('semantics label with showFurigana', () {
      final parts = parseFuriganaInline('本[ほん]');
      expect(semanticsFuriganaLabel(parts, showFurigana: true), '本（ほん）');
      expect(semanticsFuriganaLabel(parts, showFurigana: false), '本');
    });
  });

  group('uncoveredKanjiRunsInFuriganaInline', () {
    test('reports kanji outside ruby markup', () {
      expect(uncoveredKanjiRunsInFuriganaInline('本[ほん]を読みます'), ['読']);
    });

    test('passes fully annotated okurigana text', () {
      expect(uncoveredKanjiRunsInFuriganaInline('本[ほん]を読[よ]みます'), isEmpty);
    });
  });

  group('normalizeQuizBankText with furigana', () {
    test('strips furigana before other normalization', () {
      expect(normalizeQuizBankText('  本[ほん]を読[よ]みます  '), '本を読みます');
    });

    test('annotated and surface form normalize the same', () {
      final a = normalizeQuizBankText('本[ほん]を');
      final b = normalizeQuizBankText('本を');
      expect(a, b);
    });
  });
}
