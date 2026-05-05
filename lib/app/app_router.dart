import 'package:flutter/material.dart';

import '../models/quiz.dart';
import '../models/quiz_result.dart';
import '../screens/home_screen.dart';
import '../screens/quiz_screen.dart' deferred as quiz_screen_lib;
import '../screens/quiz_start_screen.dart' deferred as quiz_start_lib;
import '../screens/results_screen.dart' deferred as results_lib;
import '../widgets/app_shell.dart';

// PERF: Deferred quiz/results/start libraries shrink initial JS parse; route names
// and argument types stay stable — do not regress eager imports for those contracts.

class AppRoutes {
  AppRoutes._();

  static const String home = '/';
  static const String quizStart = '/quiz/start';
  static const String quiz = '/quiz';
  static const String results = '/results';
}

/// Optional [ModalRoute.settings.arguments] for [AppRoutes.home].
class HomeRouteArgs {
  const HomeRouteArgs({this.scrollToQuizzes = false});

  final bool scrollToQuizzes;
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
  const ResultsRouteArgs({required this.result, required this.quizTitle});

  final QuizResult result;
  final String quizTitle;
}

class AppRouter {
  AppRouter._();

  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case AppRoutes.home:
        final homeArgs = settings.arguments;
        final scrollToQuizzes =
            homeArgs is HomeRouteArgs && homeArgs.scrollToQuizzes;
        return MaterialPageRoute<void>(
          settings: settings,
          builder: (_) => HomeScreen(scrollToQuizzesOnOpen: scrollToQuizzes),
        );
      case AppRoutes.quizStart:
        final startArgs = settings.arguments;
        if (startArgs is! QuizStartRouteArgs || startArgs.quizId.isEmpty) {
          return MaterialPageRoute<void>(
            settings: settings,
            builder: (_) =>
                const _InvalidRouteScreen(message: 'Missing quiz setup.'),
          );
        }
        return MaterialPageRoute<void>(
          settings: settings,
          builder: (_) => FutureBuilder<void>(
            future: quiz_start_lib.loadLibrary(),
            builder: (context, snapshot) {
              if (snapshot.connectionState != ConnectionState.done) {
                return const _DeferredRouteShell(title: 'Quiz');
              }
              return quiz_start_lib.QuizStartScreen(quizId: startArgs.quizId);
            },
          ),
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
          builder: (_) => FutureBuilder<void>(
            future: quiz_screen_lib.loadLibrary(),
            builder: (context, snapshot) {
              if (snapshot.connectionState != ConnectionState.done) {
                return const _DeferredRouteShell(title: 'Quiz');
              }
              return quiz_screen_lib.QuizScreen(quiz: quizArgs.quiz);
            },
          ),
        );
      case AppRoutes.results:
        final args = settings.arguments;
        if (args is! ResultsRouteArgs) {
          return MaterialPageRoute<void>(
            settings: settings,
            builder: (_) =>
                const _InvalidRouteScreen(message: 'Missing results.'),
          );
        }
        return MaterialPageRoute<void>(
          settings: settings,
          builder: (_) => FutureBuilder<void>(
            future: results_lib.loadLibrary(),
            builder: (context, snapshot) {
              if (snapshot.connectionState != ConnectionState.done) {
                return const _DeferredRouteShell(title: 'Results');
              }
              return results_lib.ResultsScreen(args: args);
            },
          ),
        );
      default:
        return MaterialPageRoute<void>(
          settings: settings,
          builder: (_) => const _InvalidRouteScreen(message: 'Unknown route.'),
        );
    }
  }
}

/// Lightweight shell while a deferred route library downloads/parses (Web).
class _DeferredRouteShell extends StatelessWidget {
  const _DeferredRouteShell({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return AppShell(
      headerMode: AppShellHeaderMode.compact,
      title: title,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back),
        onPressed: () => Navigator.of(context).maybePop(),
      ),
      body: Center(
        child: SizedBox(
          width: 28,
          height: 28,
          child: CircularProgressIndicator(
            strokeWidth: 2.5,
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
      ),
    );
  }
}

class _InvalidRouteScreen extends StatelessWidget {
  const _InvalidRouteScreen({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return AppShell(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                message,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              const SizedBox(height: 16),
              FilledButton(
                onPressed: () => Navigator.of(
                  context,
                ).pushNamedAndRemoveUntil(AppRoutes.home, (_) => false),
                child: const Text('Home'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
