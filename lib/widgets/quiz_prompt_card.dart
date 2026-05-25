import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../app/breakpoints.dart';
import '../app/jpquizapp_tokens.dart';
import '../app/color/oklch.dart';
import '../utils/quiz_instruction_text.dart';
import 'japanese_text_lookup.dart';

/// English instructions, primary Japanese question line, and optional context.
class QuizPromptCard extends StatelessWidget {
  const QuizPromptCard({
    super.key,
    required this.japanese,
    required this.promptEn,
    required this.japaneseEn,
    this.contextLine,
    this.contextLineEn,
    required this.showFurigana,
    this.showEnglish = false,
    this.watermarkKanji,
  });

  final String japanese;
  final String promptEn;
  final String japaneseEn;
  final String? contextLine;
  final String? contextLineEn;
  final bool showFurigana;
  final bool showEnglish;

  /// Faint decorative glyph (topic); keep behind copy.
  final String? watermarkKanji;

  @override
  Widget build(BuildContext context) {
    final t = context.jpQuizAppTokens;
    final wm = watermarkKanji?.trim();
    final instructions = normalizeQuizInstructions(promptEn);
    final phone = LayoutBreakpoints.isPhoneWidth(
      MediaQuery.sizeOf(context).width,
    );

    final questionStyle = Theme.of(context).textTheme.headlineSmall?.copyWith(
      fontSize: phone ? 21 : null,
      height: phone ? 1.38 : 1.45,
      fontWeight: FontWeight.w600,
      color: t.textStrong,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (instructions.isNotEmpty) ...[
          _InstructionStrip(text: instructions),
          SizedBox(height: phone ? 10 : 14),
        ],
        ClipRRect(
          borderRadius: BorderRadius.circular(t.radiusMd),
          child: Stack(
            clipBehavior: Clip.hardEdge,
            children: [
              Positioned.fill(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: t.surface1,
                    borderRadius: BorderRadius.circular(t.radiusMd),
                    border: Border.all(color: t.borderSoft),
                  ),
                ),
              ),
              if (wm != null && wm.isNotEmpty)
                Positioned(
                  right: -16,
                  bottom: -28,
                  child: IgnorePointer(
                    child: Transform.rotate(
                      angle: -8 * math.pi / 180,
                      child: Text(
                        wm,
                        style: GoogleFonts.notoSansJp(
                          fontSize: phone ? 104 : 132,
                          fontWeight: FontWeight.w900,
                          height: 1,
                          color: whiteAlpha(0.045),
                        ),
                      ),
                    ),
                  ),
                ),
              Padding(
                padding: phone
                    ? const EdgeInsets.fromLTRB(16, 18, 16, 18)
                    : const EdgeInsets.fromLTRB(22, 26, 22, 22),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _questionLine(
                      context: context,
                      jp: japanese,
                      en: japaneseEn,
                      showEnglish: showEnglish,
                      showFurigana: showFurigana,
                      style: questionStyle,
                    ),
                    if (contextLine != null) ...[
                      const SizedBox(height: 12),
                      _contextLine(
                        context: context,
                        jp: contextLine!,
                        en: contextLineEn ?? '',
                        showEnglish: showEnglish,
                        showFurigana: showFurigana,
                        mutedColor: t.textMuted,
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _InstructionStrip extends StatelessWidget {
  const _InstructionStrip({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    final t = context.jpQuizAppTokens;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(Icons.menu_book_outlined, size: 18, color: t.textMuted),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            text,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: t.textMuted,
              height: 1.45,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }
}

Widget _questionLine({
  required BuildContext context,
  required String jp,
  required String en,
  required bool showEnglish,
  required bool showFurigana,
  required TextStyle? style,
}) {
  if (showEnglish && en.trim().isNotEmpty) {
    return Text(en, style: style);
  }
  return JapaneseTextLookup(text: jp, showFurigana: showFurigana, style: style);
}

Widget _contextLine({
  required BuildContext context,
  required String jp,
  required String en,
  required bool showEnglish,
  required bool showFurigana,
  required Color mutedColor,
}) {
  final style = Theme.of(
    context,
  ).textTheme.bodyMedium?.copyWith(color: mutedColor, height: 1.4);
  if (showEnglish && en.trim().isNotEmpty) {
    return Text(en, style: style);
  }
  return JapaneseTextLookup(text: jp, showFurigana: showFurigana, style: style);
}
