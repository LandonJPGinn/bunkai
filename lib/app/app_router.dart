import 'package:flutter/material.dart';

import '../models/quiz.dart';
import '../models/quiz_result.dart';
import '../screens/home_screen.dart';
import '../screens/quiz_screen.dart';
import '../screens/quiz_start_screen.dart';
import '../screens/results_screen.dart';

class AppRoutes {
  AppRoutes._();

  static const String home = '/';
  static const String quizStart = '/quiz/start';
  static const String quiz = '/quiz';
  static const String results = '/results';
}

/// Route to [QuizStartScreen]: [QuizId.name] (e.g. `particleForensics`).
class QuizStartRouteArgs {
  const QuizStartRouteArgs({required this.quizId});

  final String quizId;
}

/// Route to [QuizScreen]: the exact [Quiz] to run (full bank or session subset).
class QuizRouteArgs {
  const QuizRouteArgs({required this.quiz});

  final Quiz quiz;
}

class ResultsRouteArgs {
  const ResultsRouteArgs({
    required this.result,
    required this.quizTitle,
  });

  final QuizResult result;
  final String quizTitle;
}

class AppRouter {
  AppRouter._();

  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case AppRoutes.home:
        return MaterialPageRoute<void>(
          settings: settings,
          builder: (_) => const HomeScreen(),
        );
      case AppRoutes.quizStart:
        final startArgs = settings.arguments;
        if (startArgs is! QuizStartRouteArgs || startArgs.quizId.isEmpty) {
          return MaterialPageRoute<void>(
            settings: settings,
            builder: (_) => const _InvalidRouteScreen(
              message: 'Missing quiz setup.',
            ),
          );
        }
        return MaterialPageRoute<void>(
          settings: settings,
          builder: (_) => QuizStartScreen(quizId: startArgs.quizId),
        );
      case AppRoutes.quiz:
        final quizArgs = settings.arguments;
        if (quizArgs is! QuizRouteArgs) {
          return MaterialPageRoute<void>(
            settings: settings,
            builder: (_) => const _InvalidRouteScreen(message: 'Missing quiz.'),
          );
        }
        return MaterialPageRoute<void>(
          settings: settings,
          builder: (_) => QuizScreen(quiz: quizArgs.quiz),
        );
      case AppRoutes.results:
        final args = settings.arguments;
        if (args is! ResultsRouteArgs) {
          return MaterialPageRoute<void>(
            settings: settings,
            builder: (_) => const _InvalidRouteScreen(message: 'Missing results.'),
          );
        }
        return MaterialPageRoute<void>(
          settings: settings,
          builder: (_) => ResultsScreen(args: args),
        );
      default:
        return MaterialPageRoute<void>(
          settings: settings,
          builder: (_) => const _InvalidRouteScreen(message: 'Unknown route.'),
        );
    }
  }
}

class _InvalidRouteScreen extends StatelessWidget {
  const _InvalidRouteScreen({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('BunKai')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(message, textAlign: TextAlign.center),
              const SizedBox(height: 16),
              FilledButton(
                onPressed: () =>
                    Navigator.of(context).pushNamedAndRemoveUntil(
                  AppRoutes.home,
                  (_) => false,
                ),
                child: const Text('Home'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
