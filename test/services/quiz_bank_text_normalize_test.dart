import 'package:jpquizapp/services/quiz_bank_text_normalize.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('normalizeQuizBankText', () {
    test('trims and collapses ASCII whitespace', () {
      expect(normalizeQuizBankText('  a   b  '), 'a b');
    });

    test('treats ideographic space as whitespace', () {
      expect(
        normalizeQuizBankText(
          '駅\u3000\u3000友だち',
        ),
        '駅 友だち',
      );
    });

    test('maps fullwidth ASCII punctuation to halfwidth', () {
      expect(
        normalizeQuizBankText('，。！？：；'),
        ',.!?:;',
      );
    });

    test('maps ideographic comma and full stop to ASCII', () {
      expect(
        normalizeQuizBankText('春\u3001夏\u3002'),
        '春,夏.',
      );
    });

    test('fullwidth vs halfwidth forms compare equal after normalize', () {
      final a = '駅\u3000友だちに会いました。';
      final b = '駅 友だちに会いました.'; // halfwidth period
      expect(normalizeQuizBankText(a), normalizeQuizBankText(b));
    });

    test('empty and whitespace-only', () {
      expect(normalizeQuizBankText(''), '');
      expect(normalizeQuizBankText('   '), '');
      expect(normalizeQuizBankText('\u3000'), '');
    });

    test('leaves kana and kanji unchanged except spacing', () {
      expect(
        normalizeQuizBankText('  食べる  '),
        '食べる',
      );
    });
  });
}
