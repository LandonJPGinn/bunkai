import 'package:flutter/material.dart';

import 'app/font_bootstrap.dart';
import 'app/jpquizapp_app.dart';

/// PERF: Quiz banks and lexicon load lazily after first frame — never block
/// [runApp] on JSON parsing (see [QuizBankLoader], [JapaneseDictionaryService]).
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await preloadAppFonts();
  runApp(const JpQuizApp());
}
