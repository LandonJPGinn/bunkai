import 'package:jpquizapp/models/practice_options.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('practice settings round-trip through storage map', () {
    const settings = PracticeQuizSettings(
      countPreset: PracticeCountPreset.fifty,
      jlptFilter: PracticeJlptFilter.n3N2,
      conjugationTags: {'te_form', 'nai_form'},
    );

    final map = settings.toStorageMap();
    final decoded = PracticeQuizSettings.fromStorageMap(map);

    expect(decoded.countPreset, PracticeCountPreset.fifty);
    expect(decoded.jlptFilter, PracticeJlptFilter.n3N2);
    expect(decoded.conjugationTags, {'te_form', 'nai_form'});
  });

  test('practice settings fall back to defaults on invalid values', () {
    final decoded = PracticeQuizSettings.fromStorageMap(
      const <String, Object?>{
        'countPreset': 'bad',
        'jlptFilter': 'also-bad',
      },
    );

    expect(decoded.countPreset, PracticeCountPreset.ten);
    expect(decoded.jlptFilter, PracticeJlptFilter.all);
    expect(decoded.conjugationTags, isEmpty);
  });

  test('sanitizedFor drops stale values and fills defaults', () {
    const settings = PracticeQuizSettings(
      jlptFilter: PracticeJlptFilter.n2,
      conjugationTags: {'te_form', 'missing_tag'},
    );
    const difficultyAvailable = PracticeQuizAvailableSettings(
      useConjugationFilter: false,
      availableJlptFilters: [PracticeJlptFilter.all, PracticeJlptFilter.n4],
    );
    const conjugationAvailable = PracticeQuizAvailableSettings(
      useConjugationFilter: true,
      availableConjugationTags: ['te_form', 'nai_form'],
    );

    final difficultySanitized = settings.sanitizedFor(difficultyAvailable);
    final conjugationSanitized = settings.sanitizedFor(conjugationAvailable);

    expect(difficultySanitized.jlptFilter, PracticeJlptFilter.all);
    expect(difficultySanitized.conjugationTags, isEmpty);
    expect(conjugationSanitized.conjugationTags, {'te_form'});
  });
}
