import 'package:bunkai/data/quiz_registry.dart';
import 'package:bunkai/models/quiz_id.dart';
import 'package:bunkai/screens/quiz_screen.dart';
import 'package:bunkai/services/japanese_dictionary_service.dart';
import 'package:bunkai/services/quiz_bank_loader.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    await Future.wait([
      QuizBankLoader.instance.load(),
      JapaneseDictionaryService.instance.load(),
    ]);
  });

  tearDownAll(() {
    QuizBankLoader.instance.debugReset();
  });

  testWidgets('digit key selects answer and Enter submits', (tester) async {
    final quiz = quizById(QuizId.transitivityDuel)!;
    await tester.pumpWidget(
      MaterialApp(
        home: QuizScreen(quiz: quiz),
      ),
    );
    await tester.pumpAndSettle();

    await tester.sendKeyEvent(LogicalKeyboardKey.digit1);
    await tester.pump();
    await tester.sendKeyEvent(LogicalKeyboardKey.enter);
    await tester.pumpAndSettle();

    expect(find.text('Correct'), findsOneWidget);
  });
}
