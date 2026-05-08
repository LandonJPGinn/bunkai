import 'package:bunkai/models/practice_options.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('practice settings round-trip through storage map', () {
    const settings = PracticeQuizSettings(
      countPreset: PracticeCountPreset.fifty,
      jlptFilter: PracticeJlptFilter.n3N2,
    );

    final map = settings.toStorageMap();
    final decoded = PracticeQuizSettings.fromStorageMap(map);

    expect(decoded.countPreset, PracticeCountPreset.fifty);
    expect(decoded.jlptFilter, PracticeJlptFilter.n3N2);
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
  });
}
