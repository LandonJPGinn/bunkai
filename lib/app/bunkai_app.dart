import 'package:flutter/material.dart';

import 'app_router.dart';
import 'app_theme.dart';

class BunkaiApp extends StatelessWidget {
  const BunkaiApp({super.key});

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
