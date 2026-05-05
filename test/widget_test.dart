import 'package:bunkai/app/bunkai_app.dart';
import 'package:bunkai/services/quiz_bank_loader.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    await QuizBankLoader.instance.load();
  });

  tearDownAll(() {
    QuizBankLoader.instance.debugReset();
  });

  testWidgets('Home shows lab hero and quiz grid', (WidgetTester tester) async {
    await tester.binding.setSurfaceSize(const Size(1200, 1600));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(const BunkaiApp());
    await tester.pumpAndSettle();

    expect(find.text('BunKai'), findsOneWidget);
    expect(find.text('Debug your Japanese.'), findsOneWidget);
    expect(
      find.text(
        'Targeted quiz tools for the grammar mistakes normal apps ignore.',
      ),
      findsOneWidget,
    );
    expect(
      find.text('No login. No streaks. Just focused Japanese practice.'),
      findsOneWidget,
    );
    expect(find.text('Particle Forensics'), findsOneWidget);
    expect(find.text('Start'), findsWidgets);
  });
}
