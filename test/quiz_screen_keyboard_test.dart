import 'package:jpquizapp/models/quiz.dart';
import 'package:jpquizapp/models/quiz_id.dart';
import 'package:jpquizapp/models/quiz_question.dart';
import 'package:jpquizapp/models/quiz_type.dart';
import 'package:jpquizapp/screens/quiz_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const quiz = Quiz(
    id: QuizId.transitivityDuel,
    title: 'Quiz',
    subtitle: 'S',
    description: 'D',
    difficulty: 'N4',
    questions: [
      QuizQuestion(
        id: 'q1',
        type: QuizType.textInput,
        prompt: 'Type',
        japanese: 'ほん___よむ',
        promptEn: 'Type',
        japaneseEn: 'Type',
        explanation: 'ex',
        explanationEn: 'ex',
        diagnosticTags: ['tag'],
        acceptedAnswers: ['を'],
      ),
      QuizQuestion(
        id: 'q2',
        type: QuizType.textInput,
        prompt: 'Type',
        japanese: 'がっこう___いく',
        promptEn: 'Type',
        japaneseEn: 'Type',
        explanation: 'ex',
        explanationEn: 'ex',
        diagnosticTags: ['tag'],
        acceptedAnswers: ['に'],
      ),
    ],
  );

  testWidgets('Enter submits typed answer', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: QuizScreen(quiz: quiz),
      ),
    );
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField), 'wo');
    await tester.pump();
    await tester.sendKeyEvent(LogicalKeyboardKey.enter);
    await tester.pumpAndSettle();

    expect(find.text('Correct'), findsWidgets);

    await tester.tap(find.text('Next'));
    await tester.pumpAndSettle();
    expect(find.text('Submit'), findsOneWidget);
  });

  testWidgets('correct answer does not auto-advance without Next', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: QuizScreen(quiz: quiz),
      ),
    );
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField), 'wo');
    await tester.pump();
    await tester.sendKeyEvent(LogicalKeyboardKey.enter);
    await tester.pumpAndSettle();

    expect(find.text('Correct'), findsWidgets);

    await tester.pump(const Duration(milliseconds: 2000));
    await tester.pump();

    expect(find.text('Next'), findsOneWidget);
  });

  testWidgets('wrong answer does not auto-advance', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: QuizScreen(quiz: quiz),
      ),
    );
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField), 'ni');
    await tester.pump();
    await tester.sendKeyEvent(LogicalKeyboardKey.enter);
    await tester.pumpAndSettle();

    expect(find.text('Incorrect'), findsOneWidget);
    await tester.pump(const Duration(milliseconds: 2000));

    expect(find.text('Next'), findsOneWidget);
    expect(find.text('Submit'), findsNothing);
  });
}
