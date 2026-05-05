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
      QuizBankLoader.instance.loadAllForTests(),
      JapaneseDictionaryService.instance.ensureLoaded(),
    ]);
  });

  tearDownAll(() {
    QuizBankLoader.instance.debugReset();
  });

  testWidgets('digit key selects answer and Enter submits', (tester) async {
    final quiz = QuizBankLoader.instance.quizFor(QuizId.transitivityDuel);
    await tester.pumpWidget(
      MaterialApp(
        home: QuizScreen(quiz: quiz),
      ),
    );
    await tester.pumpAndSettle();

    await tester.sendKeyEvent(LogicalKeyboardKey.digit1);
    await tester.pump();
    await tester.sendKeyEvent(LogicalKeyboardKey.enter);
    await tester.pump();

    expect(find.text('Correct'), findsWidgets);

    await tester.sendKeyEvent(LogicalKeyboardKey.enter);
    await tester.pumpAndSettle();

    expect(find.textContaining('intentionally open'), findsOneWidget);
  });

  testWidgets('correct answer does not auto-advance without Next', (tester) async {
    final quiz = QuizBankLoader.instance.quizFor(QuizId.transitivityDuel);
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

    expect(find.text('Correct'), findsWidgets);

    await tester.pump(const Duration(milliseconds: 2000));
    await tester.pump();

    expect(find.textContaining('intentionally open'), findsNothing);
  });

  testWidgets('wrong answer does not auto-advance', (tester) async {
    final quiz = QuizBankLoader.instance.quizFor(QuizId.transitivityDuel);
    await tester.pumpWidget(
      MaterialApp(
        home: QuizScreen(quiz: quiz),
      ),
    );
    await tester.pumpAndSettle();

    expect(
      find.textContaining('No one touched the window'),
      findsOneWidget,
    );

    await tester.sendKeyEvent(LogicalKeyboardKey.digit2);
    await tester.pump();
    await tester.sendKeyEvent(LogicalKeyboardKey.enter);
    await tester.pumpAndSettle();

    expect(find.text('Incorrect'), findsOneWidget);
    await tester.pump(const Duration(milliseconds: 2000));

    expect(
      find.textContaining('No one touched the window'),
      findsOneWidget,
    );
    expect(find.textContaining('intentionally open'), findsNothing);
  });
}
