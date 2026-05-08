import 'package:bunkai/models/dictionary_entry.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('DictionaryEntry.fromJson', () {
    test('parses valid entry', () {
      final entry = DictionaryEntry.fromJson({
        'surface': '日本',
        'reading': 'にほん',
        'partOfSpeech': 'noun',
        'definitions': ['Japan'],
      });
      expect(entry.surface, '日本');
      expect(entry.reading, 'にほん');
      expect(entry.definitions, ['Japan']);
    });

    test('rejects empty reading', () {
      expect(
        () => DictionaryEntry.fromJson({
          'surface': '日本',
          'reading': '   ',
          'partOfSpeech': 'noun',
          'definitions': ['Japan'],
        }),
        throwsA(isA<FormatException>()),
      );
    });

    test('rejects blank-only definitions', () {
      expect(
        () => DictionaryEntry.fromJson({
          'surface': '日本',
          'reading': 'にほん',
          'partOfSpeech': 'noun',
          'definitions': ['  '],
        }),
        throwsA(isA<FormatException>()),
      );
    });
  });
}
