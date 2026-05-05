import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../services/furigana_inline.dart';
import '../services/japanese_dictionary_service.dart';
import '../services/japanese_tokenizer.dart';
import 'dictionary_popover.dart';

/// Renders Japanese with optional `kanji[よみ]` furigana and tap-to-lookup
/// dictionary tokens (local longest-match). Quiz data needs no word markup.
class JapaneseTextLookup extends StatelessWidget {
  const JapaneseTextLookup({
    super.key,
    required this.text,
    required this.showFurigana,
    required this.style,
    this.textAlign,
    this.maxLines,
    this.includeSemantics = true,
    this.dictionary,
  });

  final String text;
  final bool showFurigana;
  final TextStyle? style;
  final TextAlign? textAlign;
  final int? maxLines;

  /// When false, omits a [Semantics] wrapper (e.g. when an ancestor already
  /// provides the full a11y label, as in [AnswerChoiceCard]).
  final bool includeSemantics;

  final JapaneseDictionaryService? dictionary;

  @override
  Widget build(BuildContext context) {
    final dict = dictionary ?? JapaneseDictionaryService.instance;
    final tokenizer = dict.tokenizer;
    final theme = Theme.of(context);
    final baseStyle = style ?? theme.textTheme.bodyLarge;
    final readingStyle = baseStyle?.copyWith(
      fontSize: (baseStyle.fontSize ?? 16) * 0.62,
      height: 1.05,
      color: baseStyle.color?.withValues(alpha: 0.88),
    );

    final parts = parseFuriganaInline(text);
    final label = semanticsFuriganaLabel(parts, showFurigana: showFurigana);
    final children = <InlineSpan>[];

    for (final p in parts) {
      switch (p) {
        case PlainPart(text: final plain):
          children.addAll(
            _lookupSpansForPlain(
              context,
              plain,
              baseStyle,
              tokenizer,
              dict,
            ),
          );
        case RubyPart(:final base, :final reading):
          if (showFurigana && reading.isNotEmpty) {
            children.add(
              WidgetSpan(
                alignment: PlaceholderAlignment.bottom,
                child: Padding(
                  padding: const EdgeInsets.only(right: 1),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        reading,
                        style: readingStyle,
                        textAlign: TextAlign.center,
                      ),
                      Text.rich(
                        TextSpan(
                          children: _lookupSpansForPlain(
                            context,
                            base,
                            baseStyle,
                            tokenizer,
                            dict,
                          ),
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
            );
          } else {
            children.addAll(
              _lookupSpansForPlain(
                context,
                base,
                baseStyle,
                tokenizer,
                dict,
              ),
            );
          }
      }
    }

    final rich = Text.rich(
      TextSpan(children: children),
      textAlign: textAlign,
      maxLines: maxLines,
      overflow: maxLines != null ? TextOverflow.ellipsis : TextOverflow.clip,
    );

    if (!includeSemantics) return rich;
    return Semantics(label: label, child: rich);
  }
}

List<InlineSpan> _lookupSpansForPlain(
  BuildContext context,
  String s,
  TextStyle? baseStyle,
  JapaneseTokenizer tokenizer,
  JapaneseDictionaryService dict,
) {
  final segs = tokenizer.tokenize(s);
  final out = <InlineSpan>[];
  for (final seg in segs) {
    switch (seg) {
      case PlainSegment(:final text):
        if (text.isNotEmpty) {
          out.add(TextSpan(text: text, style: baseStyle));
        }
      case DictSegment(:final surface):
        out.add(
          WidgetSpan(
            alignment: PlaceholderAlignment.baseline,
            baseline: TextBaseline.alphabetic,
            child: _LookupToken(
              label: surface,
              style: baseStyle,
              onOpen: () => DictionaryPopover.show(
                context,
                entries: dict.lookupSurface(surface),
              ),
            ),
          ),
        );
      case UnknownKanjiSegment(:final text):
        out.add(
          WidgetSpan(
            alignment: PlaceholderAlignment.baseline,
            baseline: TextBaseline.alphabetic,
            child: _LookupToken(
              label: text,
              style: baseStyle,
              onOpen: () => DictionaryPopover.show(
                context,
                entries: const [],
                unknownText: text,
              ),
            ),
          ),
        );
    }
  }
  return out;
}

class _LookupToken extends StatefulWidget {
  const _LookupToken({
    required this.label,
    required this.style,
    required this.onOpen,
  });

  final String label;
  final TextStyle? style;
  final VoidCallback onOpen;

  @override
  State<_LookupToken> createState() => _LookupTokenState();
}

class _LookupTokenState extends State<_LookupToken> {
  bool _hover = false;
  bool _focused = false;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final showMark = _hover || _focused;
    final style = widget.style?.copyWith(
      decoration: showMark ? TextDecoration.underline : null,
      decorationColor: scheme.primary.withValues(alpha: 0.45),
    );

    return Focus(
      onFocusChange: (f) => setState(() => _focused = f),
      onKeyEvent: (node, event) {
        if (event is! KeyDownEvent) return KeyEventResult.ignored;
        if (event.logicalKey == LogicalKeyboardKey.enter ||
            event.logicalKey == LogicalKeyboardKey.space) {
          widget.onOpen();
          return KeyEventResult.handled;
        }
        return KeyEventResult.ignored;
      },
      child: MouseRegion(
        onEnter: (_) => setState(() => _hover = true),
        onExit: (_) => setState(() => _hover = false),
        cursor: SystemMouseCursors.click,
        child: Semantics(
          button: true,
          label: widget.label,
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: widget.onOpen,
            child: Text(widget.label, style: style),
          ),
        ),
      ),
    );
  }
}
