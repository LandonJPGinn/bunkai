import 'package:flutter/material.dart';

import '../data/jlpt_question_levels.dart';
import '../models/practice_options.dart';
import '../widgets/primary_button.dart';

class QuizPracticeSettingsPanel extends StatelessWidget {
  const QuizPracticeSettingsPanel({
    super.key,
    required this.settings,
    required this.onCountChanged,
    required this.onJlptChanged,
    this.canStart = true,
    this.startLabel = 'Start',
    this.onStart,
  });

  final PracticeQuizSettings settings;
  final ValueChanged<PracticeCountPreset> onCountChanged;
  final ValueChanged<PracticeJlptFilter> onJlptChanged;
  final bool canStart;
  final String startLabel;
  final VoidCallback? onStart;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
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
          selected: {settings.countPreset},
          onSelectionChanged: (s) => onCountChanged(s.first),
        ),
        const SizedBox(height: 20),
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
              value: settings.jlptFilter,
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
                if (v != null) {
                  onJlptChanged(v);
                }
              },
            ),
          ),
        ),
        if (onStart != null) ...[
          const SizedBox(height: 24),
          PrimaryButton(
            label: startLabel,
            onPressed: canStart ? onStart : null,
          ),
        ],
      ],
    );
  }
}
