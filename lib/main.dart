import 'package:flutter/material.dart';
import 'package:flutter_web_plugins/url_strategy.dart';

import 'app/jpquizapp_app.dart';

/// PERF: Quiz banks and lexicon load lazily after first frame — never block
/// [runApp] on JSON parsing (see [QuizBankLoader], [JapaneseDictionaryService]).
void main() {
  WidgetsFlutterBinding.ensureInitialized();
  usePathUrlStrategy();
  runApp(const JpQuizApp());
}
