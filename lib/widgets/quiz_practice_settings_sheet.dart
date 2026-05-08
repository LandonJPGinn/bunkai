import 'package:flutter/material.dart';

import '../app/bunkai_tokens.dart';
import '../models/practice_options.dart';
import '../models/quiz.dart';
import '../services/practice_session_builder.dart';
import 'quiz_practice_settings_panel.dart';

Future<PracticeQuizSettings?> showQuizPracticeSettingsSheet({
  required BuildContext context,
  required Quiz quiz,
  required PracticeQuizSettings initialSettings,
}) {
  return showModalBottomSheet<PracticeQuizSettings>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (context) {
      var settings = initialSettings;
      return SafeArea(
        top: false,
        child: Padding(
          padding: EdgeInsets.fromLTRB(
            16,
            8,
            16,
            16 + MediaQuery.viewInsetsOf(context).bottom,
          ),
          child: StatefulBuilder(
            builder: (context, setModalState) {
              final previewCount = filteredQuestionsForPreview(
                quiz,
                settings.jlptFilter,
              ).length;
              final tokens = context.bunkaiTokens;
              final reduceMotion = MediaQuery.of(context).disableAnimations;
              final motionMedium =
                  reduceMotion ? Duration.zero : tokens.motionMedium;
              final motionSlow =
                  reduceMotion ? Duration.zero : tokens.motionSlow;
              return SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'Quiz settings',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      quiz.title,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 12),
                    AnimatedSize(
                      duration: motionSlow,
                      curve: tokens.motionEmphasizedCurve,
                      alignment: Alignment.topCenter,
                      child: AnimatedSwitcher(
                        duration: motionMedium,
                        switchInCurve: tokens.motionStandardCurve,
                        switchOutCurve: tokens.motionStandardCurve,
                        transitionBuilder: (child, animation) =>
                            FadeTransition(opacity: animation, child: child),
                        child: previewCount == 0
                            ? Padding(
                                key: const ValueKey<String>('preview-warning'),
                                padding: const EdgeInsets.only(bottom: 16),
                                child: Text(
                                  'No questions for this filter.',
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodySmall
                                      ?.copyWith(
                                    color:
                                        Theme.of(context).colorScheme.error,
                                  ),
                                ),
                              )
                            : const SizedBox(
                                key: ValueKey<String>('preview-warning-empty'),
                                width: double.infinity,
                              ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.fromLTRB(16, 18, 16, 20),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.surfaceContainerLow,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: Theme.of(context).colorScheme.outlineVariant,
                        ),
                      ),
                      child: QuizPracticeSettingsPanel(
                        settings: settings,
                        onCountChanged: (value) {
                          setModalState(
                            () => settings = settings.copyWith(
                              countPreset: value,
                            ),
                          );
                        },
                        onJlptChanged: (value) {
                          setModalState(
                            () => settings = settings.copyWith(
                              jlptFilter: value,
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 14),
                    FilledButton(
                      onPressed: () => Navigator.of(context).pop(settings),
                      child: const Text('Save settings'),
                    ),
                    const SizedBox(height: 8),
                    TextButton(
                      onPressed: () => Navigator.of(context).maybePop(),
                      child: const Text('Cancel'),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      );
    },
  );
}
