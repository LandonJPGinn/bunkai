import 'package:flutter/material.dart';

import '../models/practice_options.dart';
import '../widgets/primary_button.dart';

class QuizPracticeSettingsPanel extends StatelessWidget {
  const QuizPracticeSettingsPanel({
    super.key,
    required this.settings,
    required this.availableSettings,
    required this.onCountChanged,
    required this.onJlptChanged,
    required this.onConjugationChanged,
    this.canStart = true,
    this.startLabel = 'Start',
    this.onStart,
  });

  final PracticeQuizSettings settings;
  final PracticeQuizAvailableSettings availableSettings;
  final ValueChanged<PracticeCountPreset> onCountChanged;
  final ValueChanged<PracticeJlptFilter> onJlptChanged;
  final ValueChanged<Set<String>> onConjugationChanged;
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
        if (availableSettings.useConjugationFilter)
          _ConjugationSelector(
            availableTags: availableSettings.availableConjugationTags,
            selectedTags: settings.conjugationTags,
            onChanged: onConjugationChanged,
          )
        else if (availableSettings.showDifficultyControl)
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
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
                      for (final f in availableSettings.availableJlptFilters)
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
            ],
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

class _ConjugationSelector extends StatelessWidget {
  const _ConjugationSelector({
    required this.availableTags,
    required this.selectedTags,
    required this.onChanged,
  });

  final List<String> availableTags;
  final Set<String> selectedTags;
  final ValueChanged<Set<String>> onChanged;

  @override
  Widget build(BuildContext context) {
    final effective = selectedTags;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Conjugation types',
          style: Theme.of(context).textTheme.labelLarge,
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final tag in availableTags)
              FilterChip(
                label: Text(tag.conjugationMenuLabel),
                selected: effective.contains(tag),
                onSelected: (selected) {
                  final next = Set<String>.from(effective);
                  if (selected) {
                    next.add(tag);
                  } else if (next.length > 1) {
                    next.remove(tag);
                  }
                  onChanged(next);
                },
              ),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            TextButton(
              onPressed: () => onChanged(availableTags.toSet()),
              child: const Text('Select all'),
            ),
          ],
        ),
      ],
    );
  }
}
