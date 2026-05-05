import 'package:flutter/material.dart';

import 'app/bunkai_app.dart';
import 'services/japanese_dictionary_service.dart';
import 'services/quiz_bank_loader.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Future.wait([
    QuizBankLoader.instance.load(),
    JapaneseDictionaryService.instance.load(),
  ]);
  runApp(const BunkaiApp());
}
