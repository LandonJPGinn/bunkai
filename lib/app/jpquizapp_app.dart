import 'package:flutter/material.dart';

import '../services/japanese_dictionary_service.dart';
import 'app_router.dart';
import 'app_theme.dart';

class JpQuizApp extends StatefulWidget {
  const JpQuizApp({super.key});

  @override
  State<JpQuizApp> createState() => _JpQuizAppState();
}

class _JpQuizAppState extends State<JpQuizApp> {
  @override
  void initState() {
    super.initState();
    // PERF: Warm lexicon after paint — dictionary lookups ready without blocking startup.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      JapaneseDictionaryService.instance.ensureLoaded();
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'jpquizapp',
      debugShowCheckedModeBanner: false,
      theme: buildJpQuizAppDarkTheme(),
      darkTheme: buildJpQuizAppDarkTheme(),
      themeMode: ThemeMode.dark,
      onGenerateRoute: AppRouter.onGenerateRoute,
    );
  }
}
