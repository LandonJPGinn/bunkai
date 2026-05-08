import 'package:bunkai/utils/quiz_instruction_text.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('normalizeQuizInstructions strips common question prefixes', () {
    expect(
      normalizeQuizInstructions(
        'Q1: Choose the best particle for the blank.',
      ),
      'Choose the best particle for the blank.',
    );
    expect(
      normalizeQuizInstructions(
        'Question 14: Choose the best particle for the blank.',
      ),
      'Choose the best particle for the blank.',
    );
    expect(
      normalizeQuizInstructions(
        'Question No. 17: Choose the best particle for the blank.',
      ),
      'Choose the best particle for the blank.',
    );
    expect(
      normalizeQuizInstructions(
        'Vol.11: Choose the best particle for the blank.',
      ),
      'Choose the best particle for the blank.',
    );
    expect(
      normalizeQuizInstructions(
        'The 28th question: Choose the best particle for the blank.',
      ),
      'Choose the best particle for the blank.',
    );
  });
}
