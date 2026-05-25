import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jpquizapp/services/japanese_dictionary_service.dart';
import 'package:jpquizapp/widgets/diagnostic_tag_chip.dart';

void main() {
  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    await JapaneseDictionaryService.instance.load();
  });

  testWidgets('strips inline furigana when furigana is hidden', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: DiagnosticTagChip(label: '昨日[きのう]', showFurigana: false),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('昨日'), findsOneWidget);
    expect(find.textContaining('[きのう]'), findsNothing);
  });

  testWidgets('renders inline furigana when furigana is shown', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: DiagnosticTagChip(label: '昨日[きのう]', showFurigana: true),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('きのう'), findsOneWidget);
    expect(find.text('昨日'), findsOneWidget);
  });
}
