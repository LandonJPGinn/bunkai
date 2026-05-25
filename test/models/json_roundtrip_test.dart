import 'package:jpquizapp/data/quiz_registry.dart';
import 'package:jpquizapp/models/quiz_pack.dart';
import 'package:jpquizapp/services/quiz_bank_loader.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    await QuizBankLoader.instance.loadAllForTests();
  });

  tearDownAll(() {
    QuizBankLoader.instance.debugReset();
  });

  test('QuizPack JSON round-trip preserves structure', () {
    final pack = coreJpQuizAppPack();
    final map = pack.toMap();
    final restored = QuizPack.fromMap(map);

    expect(restored.id, pack.id);
    expect(restored.title, pack.title);
    expect(restored.quizzes.length, pack.quizzes.length);
    expect(
      restored.quizzes.first.questions.first.id,
      pack.quizzes.first.questions.first.id,
    );
    expect(
      restored.quizzes.last.questions.last.correctAnswerId,
      pack.quizzes.last.questions.last.correctAnswerId,
    );
  });
}
