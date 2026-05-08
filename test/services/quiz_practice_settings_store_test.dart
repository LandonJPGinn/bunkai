import 'package:bunkai/models/practice_options.dart';
import 'package:bunkai/models/quiz_id.dart';
import 'package:bunkai/services/quiz_practice_settings_store.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues(<String, Object>{});
  });

  test('load returns defaults when no saved settings exist', () async {
    final settings = await QuizPracticeSettingsStore.instance.load(
      QuizId.particleForensics,
    );

    expect(settings.countPreset, PracticeCountPreset.ten);
    expect(settings.jlptFilter, PracticeJlptFilter.all);
  });

  test('save and load are scoped per quiz id', () async {
    await QuizPracticeSettingsStore.instance.save(
      QuizId.particleForensics,
      const PracticeQuizSettings(
        countPreset: PracticeCountPreset.twenty,
        jlptFilter: PracticeJlptFilter.n4,
      ),
    );
    await QuizPracticeSettingsStore.instance.save(
      QuizId.verbConjugation,
      const PracticeQuizSettings(
        countPreset: PracticeCountPreset.all,
        jlptFilter: PracticeJlptFilter.n2,
      ),
    );

    final first = await QuizPracticeSettingsStore.instance.load(
      QuizId.particleForensics,
    );
    final second = await QuizPracticeSettingsStore.instance.load(
      QuizId.verbConjugation,
    );

    expect(first.countPreset, PracticeCountPreset.twenty);
    expect(first.jlptFilter, PracticeJlptFilter.n4);
    expect(second.countPreset, PracticeCountPreset.all);
    expect(second.jlptFilter, PracticeJlptFilter.n2);
  });
}
