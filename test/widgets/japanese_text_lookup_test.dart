import 'package:jpquizapp/services/japanese_dictionary_service.dart';
import 'package:jpquizapp/widgets/japanese_text_lookup.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    await JapaneseDictionaryService.instance.load();
  });

  testWidgets('renders base text when furigana is off', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: JapaneseTextLookup(
            text: '本[ほん]を',
            showFurigana: false,
            style: TextStyle(fontSize: 20),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('本'), findsOneWidget);
    expect(find.text('を'), findsOneWidget);
  });

  testWidgets('inline ruby does not duplicate lexicon reading above base',
      (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: JapaneseTextLookup(
            text: '本[ほん]を',
            showFurigana: true,
            style: TextStyle(fontSize: 20),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('ほん'), findsOneWidget);
    expect(find.text('本'), findsOneWidget);
    expect(find.text('を'), findsOneWidget);
  });

  testWidgets('shows lexicon reading above kanji dictionary token when furigana on',
      (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: JapaneseTextLookup(
            text: '食べる',
            showFurigana: true,
            style: TextStyle(fontSize: 20),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('たべる'), findsOneWidget);
    expect(find.text('食べる'), findsOneWidget);
  });

  testWidgets('hides lexicon reading for dictionary token when furigana off',
      (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: JapaneseTextLookup(
            text: '食べる',
            showFurigana: false,
            style: TextStyle(fontSize: 20),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('たべる'), findsNothing);
    expect(find.text('食べる'), findsOneWidget);
  });

  testWidgets('does not stack reading above kana-only dictionary surface',
      (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: JapaneseTextLookup(
            text: 'を',
            showFurigana: true,
            style: TextStyle(fontSize: 20),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('を'), findsOneWidget);
  });

  testWidgets('tapping a dictionary token shows a dialog on wide layout',
      (tester) async {
    await tester.pumpWidget(
      const MediaQuery(
        data: MediaQueryData(size: Size(900, 600)),
        child: MaterialApp(
          home: Scaffold(
            body: Center(
              child: JapaneseTextLookup(
                text: '食べる',
                showFurigana: true,
                style: TextStyle(fontSize: 20),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('食べる'));
    await tester.pumpAndSettle();
    expect(find.textContaining('to eat'), findsOneWidget);
    await tester.tap(find.byIcon(Icons.close));
    await tester.pumpAndSettle();
  });
}
