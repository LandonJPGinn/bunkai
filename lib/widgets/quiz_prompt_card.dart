import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../app/bunkai_tokens.dart';
import 'japanese_text_lookup.dart';

/// Prompt, Japanese line, and optional dialogue/context line for one question.
class QuizPromptCard extends StatelessWidget {
  const QuizPromptCard({
    super.key,
    required this.prompt,
    required this.japanese,
    this.contextLine,
    required this.showFurigana,
    this.watermarkKanji,
  });

  final String prompt;
  final String japanese;
  final String? contextLine;
  final bool showFurigana;

  /// Faint decorative glyph (topic); keep behind copy.
  final String? watermarkKanji;

  @override
  Widget build(BuildContext context) {
    final t = context.bunkaiTokens;
    final wm = watermarkKanji?.trim();

    return ClipRRect(
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
                      fontSize: 132,
                      fontWeight: FontWeight.w900,
                      height: 1,
                      color: Colors.white.withValues(alpha: 0.045),
                    ),
                  ),
                ),
              ),
            ),
          Padding(
            padding: const EdgeInsets.fromLTRB(22, 22, 22, 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                JapaneseTextLookup(
                  text: prompt,
                  showFurigana: showFurigana,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    height: 1.45,
                    fontWeight: FontWeight.w500,
                    color: t.textStrong,
                  ),
                ),
                if (japanese != prompt) ...[
                  const SizedBox(height: 10),
                  JapaneseTextLookup(
                    text: japanese,
                    showFurigana: showFurigana,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      height: 1.45,
                      color: t.textMain,
                    ),
                  ),
                ],
                if (contextLine != null) ...[
                  const SizedBox(height: 8),
                  JapaneseTextLookup(
                    text: contextLine!,
                    showFurigana: showFurigana,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: t.textMuted,
                      height: 1.4,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
