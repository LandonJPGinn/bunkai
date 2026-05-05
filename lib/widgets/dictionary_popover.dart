import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../app/breakpoints.dart';
import '../models/dictionary_entry.dart';

/// Shared body for modal dictionary lookup (bottom sheet on narrow, dialog on wide).
class DictionaryLookupContent extends StatelessWidget {
  const DictionaryLookupContent({
    super.key,
    required this.entries,
    this.unknownText,
    required this.onClose,
  });

  final List<DictionaryEntry> entries;
  final String? unknownText;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return CallbackShortcuts(
      bindings: {
        const SingleActivator(LogicalKeyboardKey.escape): onClose,
      },
      child: Focus(
        autofocus: true,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 12, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      entries.isNotEmpty
                          ? entries.first.surface
                          : (unknownText ?? 'Lookup'),
                      style: textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  IconButton(
                    tooltip: 'Close',
                    onPressed: onClose,
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
              if (entries.isEmpty && unknownText != null) ...[
                const SizedBox(height: 8),
                Text(
                  'No dictionary entry for this text yet.',
                  style: textTheme.bodyMedium?.copyWith(
                    color: scheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  unknownText!,
                  style: textTheme.titleMedium,
                ),
              ],
              if (entries.isNotEmpty) ...[
                const SizedBox(height: 6),
                Text(
                  entries.map((e) => e.reading).join(' · '),
                  style: textTheme.titleSmall?.copyWith(
                    color: scheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 12),
                for (var i = 0; i < entries.length; i++) ...[
                  if (entries.length > 1)
                    Padding(
                      padding: EdgeInsets.only(bottom: i == 0 ? 4 : 8),
                      child: Text(
                        'Sense ${i + 1}',
                        style: textTheme.labelMedium?.copyWith(
                          color: scheme.primary,
                        ),
                      ),
                    ),
                  Text(
                    entries[i].partOfSpeech,
                    style: textTheme.labelLarge,
                  ),
                  const SizedBox(height: 4),
                  ...entries[i].definitions.map(
                    (d) => Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: Text(
                        '• $d',
                        style: textTheme.bodyMedium?.copyWith(height: 1.4),
                      ),
                    ),
                  ),
                  if (entries[i].jlptLevel != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 6),
                      child: Text(
                        'JLPT: ${entries[i].jlptLevel}',
                        style: textTheme.bodySmall?.copyWith(
                          color: scheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                  if (entries[i].tags.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Wrap(
                        spacing: 6,
                        runSpacing: 6,
                        children: [
                          for (final t in entries[i].tags)
                            Chip(
                              label: Text(t),
                              visualDensity: VisualDensity.compact,
                              padding: EdgeInsets.zero,
                              labelPadding:
                                  const EdgeInsets.symmetric(horizontal: 8),
                            ),
                        ],
                      ),
                    ),
                  if (i < entries.length - 1) const Divider(height: 24),
                ],
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// Opens lookup UI: bottom sheet on narrow screens, dialog on wide.
abstract final class DictionaryPopover {
  static Future<void> show(
    BuildContext context, {
    required List<DictionaryEntry> entries,
    String? unknownText,
  }) {
    void close() {
      Navigator.of(context).pop();
    }

    final child = DictionaryLookupContent(
      entries: entries,
      unknownText: unknownText,
      onClose: close,
    );

    final narrow =
        LayoutBreakpoints.isNarrowWidth(MediaQuery.sizeOf(context).width);

    if (narrow) {
      return showModalBottomSheet<void>(
        context: context,
        isScrollControlled: true,
        showDragHandle: true,
        useSafeArea: true,
        builder: (ctx) {
          return SafeArea(
            child: SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.only(
                  bottom: MediaQuery.viewInsetsOf(ctx).bottom + 8,
                ),
                child: child,
              ),
            ),
          );
        },
      );
    }

    return showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (ctx) {
        return Dialog(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 400),
            child: SingleChildScrollView(child: child),
          ),
        );
      },
    );
  }
}
