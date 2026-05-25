import 'package:jpquizapp/services/romaji_to_hiragana_converter.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TextEditingValue value(String text) => TextEditingValue(
        text: text,
        selection: TextSelection.collapsed(offset: text.length),
      );

  group('RomajiToHiraganaConverter', () {
    test('converts basic vowels', () {
      final result = RomajiToHiraganaConverter.convert(value('a'));
      expect(result.text, 'あ');
    });

    test('converts digraphs and keeps cursor', () {
      final result = RomajiToHiraganaConverter.convert(value('kya'));
      expect(result.text, 'きゃ');
      expect(result.selection.baseOffset, 2);
    });

    test('handles nn to ん', () {
      final result = RomajiToHiraganaConverter.convert(value('nn'));
      expect(result.text, 'ん');
    });

    test('handles doubled consonants as small tsu state', () {
      final result = RomajiToHiraganaConverter.convert(value('kk'));
      expect(result.text, 'っk');
    });
  });
}
