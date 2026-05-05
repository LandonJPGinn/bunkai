import 'package:flutter/material.dart';

import '../services/japanese_dictionary_service.dart';
import 'app_router.dart';
import 'app_theme.dart';

class BunkaiApp extends StatefulWidget {
  const BunkaiApp({super.key});

  @override
  State<BunkaiApp> createState() => _BunkaiAppState();
}

class _BunkaiAppState extends State<BunkaiApp> {
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
      title: 'BunKai',
      debugShowCheckedModeBanner: false,
      theme: buildBunkaiDarkTheme(),
      darkTheme: buildBunkaiDarkTheme(),
      themeMode: ThemeMode.dark,
      initialRoute: AppRoutes.home,
      onGenerateRoute: AppRouter.onGenerateRoute,
    );
  }
}
