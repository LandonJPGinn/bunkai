import 'package:flutter/material.dart';

import '../models/answer_choice.dart';
import 'answer_choice_card.dart';

class QuizAnswerChoices extends StatelessWidget {
  const QuizAnswerChoices({
    super.key,
    required this.choices,
    required this.correctAnswerId,
    required this.selectedAnswerId,
    required this.locked,
    required this.showOutcome,
    required this.onChoiceSelected,
    required this.showFurigana,
  });

  final List<AnswerChoice> choices;
  final String correctAnswerId;
  final String? selectedAnswerId;
  final bool locked;
  final bool showOutcome;
  final ValueChanged<String> onChoiceSelected;
  final bool showFurigana;

  @override
  Widget build(BuildContext context) {
    final n = choices.length;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (var i = 0; i < choices.length; i++)
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: AnswerChoiceCard(
              label: choices[i].label,
              selected: selectedAnswerId == choices[i].id,
              locked: locked,
              isCorrectChoice: choices[i].id == correctAnswerId,
              showOutcome: showOutcome,
              subtitle: locked ? choices[i].explanation : null,
              choiceIndex: i,
              choiceCount: n,
              showFurigana: showFurigana,
              onTap: () => onChoiceSelected(choices[i].id),
            ),
          ),
      ],
    );
  }
}
