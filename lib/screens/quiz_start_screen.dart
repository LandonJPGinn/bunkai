import 'package:flutter/material.dart';

import '../app/app_router.dart';
import '../app/breakpoints.dart';
import '../data/jlpt_question_levels.dart';
import '../data/quiz_registry.dart';
import '../models/practice_options.dart';
import '../models/quiz_id.dart';
import '../services/practice_session_builder.dart';
import '../widgets/app_shell.dart';
import '../widgets/primary_button.dart';

/// Minimal setup for a practice session (count, JLPT band, ordered vs random).
class QuizStartScreen extends StatefulWidget {
  const QuizStartScreen({super.key, required this.quizId});

  final String quizId;

  @override
  State<QuizStartScreen> createState() => _QuizStartScreenState();
}

class _QuizStartScreenState extends State<QuizStartScreen> {
  PracticeCountPreset _count = PracticeCountPreset.ten;
  PracticeJlptFilter _jlpt = PracticeJlptFilter.all;
  PracticeOrderMode _mode = PracticeOrderMode.ordered;

  @override
  Widget build(BuildContext context) {
    final parsed = quizIdFromRouteName(widget.quizId);
    final base = parsed == null ? null : quizById(parsed);

    if (base == null) {
      return AppShell(
        title: 'Quiz',
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text(
              'This quiz could not be loaded.',
              style: Theme.of(context).textTheme.bodyLarge,
              textAlign: TextAlign.center,
            ),
          ),
        ),
      );
    }

    final narrow =
        LayoutBreakpoints.isNarrowWidth(MediaQuery.sizeOf(context).width);
    final horizontalPadding = narrow ? 16.0 : 20.0;
    final previewCount =
        filteredQuestionsForPreview(base, _jlpt).length;
    final canStart = previewCount > 0;

    return AppShell(
      title: base.title,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back),
        onPressed: () => Navigator.of(context).maybePop(),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: SingleChildScrollView(
            padding: EdgeInsets.fromLTRB(
              horizontalPadding,
              12,
              horizontalPadding,
              24,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (!canStart)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: Text(
                      'No questions for this filter.',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Theme.of(context).colorScheme.error,
                          ),
                    ),
                  ),
                Text(
                  'Question count',
                  style: Theme.of(context).textTheme.labelLarge,
                ),
                const SizedBox(height: 8),
                SegmentedButton<PracticeCountPreset>(
                  segments: const [
                    ButtonSegment<PracticeCountPreset>(
                      value: PracticeCountPreset.ten,
                      label: Text('10'),
                    ),
                    ButtonSegment<PracticeCountPreset>(
                      value: PracticeCountPreset.twenty,
                      label: Text('20'),
                    ),
                    ButtonSegment<PracticeCountPreset>(
                      value: PracticeCountPreset.fifty,
                      label: Text('50'),
                    ),
                    ButtonSegment<PracticeCountPreset>(
                      value: PracticeCountPreset.all,
                      label: Text('All'),
                    ),
                  ],
                  selected: {_count},
                  onSelectionChanged: (s) {
                    setState(() => _count = s.first);
                  },
                ),
                const SizedBox(height: 22),
                Text(
                  'Difficulty',
                  style: Theme.of(context).textTheme.labelLarge,
                ),
                const SizedBox(height: 8),
                InputDecorator(
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    isDense: true,
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<PracticeJlptFilter>(
                      isExpanded: true,
                      value: _jlpt,
                      items: [
                        for (final f in PracticeJlptFilter.values)
                          if (f == PracticeJlptFilter.all ||
                              (f.bandString != null &&
                                  kJlptQuestionLevels.contains(f.bandString!)))
                            DropdownMenuItem<PracticeJlptFilter>(
                              value: f,
                              child: Text(f.menuLabel),
                            ),
                      ],
                      onChanged: (v) {
                        if (v != null) setState(() => _jlpt = v);
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 22),
                Text(
                  'Mode',
                  style: Theme.of(context).textTheme.labelLarge,
                ),
                const SizedBox(height: 8),
                SegmentedButton<PracticeOrderMode>(
                  segments: const [
                    ButtonSegment<PracticeOrderMode>(
                      value: PracticeOrderMode.ordered,
                      label: Text('Ordered'),
                    ),
                    ButtonSegment<PracticeOrderMode>(
                      value: PracticeOrderMode.random,
                      label: Text('Random'),
                    ),
                  ],
                  selected: {_mode},
                  onSelectionChanged: (s) {
                    setState(() => _mode = s.first);
                  },
                ),
                const SizedBox(height: 28),
                PrimaryButton(
                  label: 'Start',
                  onPressed: canStart
                      ? () {
                          final session = buildPracticeSessionQuiz(
                            base,
                            difficulty: _jlpt,
                            countPreset: _count,
                            mode: _mode,
                          );
                          Navigator.of(context).pushNamed(
                            AppRoutes.quiz,
                            arguments: QuizRouteArgs(quiz: session),
                          );
                        }
                      : null,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
