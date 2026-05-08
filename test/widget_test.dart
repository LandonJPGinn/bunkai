import 'package:bunkai/app/bunkai_app.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
  });

  testWidgets('Home shows lab hero and quiz grid', (WidgetTester tester) async {
    await tester.binding.setSurfaceSize(const Size(1200, 1600));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(const BunkaiApp());
    await tester.pump();
    await tester.pumpAndSettle();

    expect(find.textContaining('Japanese Intermediate Practice'), findsWidgets);
    expect(find.text('Focus on the details most courses skip.'), findsOneWidget);
    expect(
      find.textContaining('diagnostic quizzes'),
      findsOneWidget,
    );
    expect(find.text('Particles'), findsOneWidget);
    expect(find.text('Start'), findsWidgets);
  });
}
