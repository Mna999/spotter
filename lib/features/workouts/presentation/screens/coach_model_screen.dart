import 'package:flutter/material.dart';
import 'package:spotter/features/workouts/domain/entities/cue_text.dart';
import 'package:spotter/features/workouts/domain/entities/exercise.dart';
import 'package:spotter/features/workouts/presentation/widgets/section_title.dart';

class CoachModelScreen extends StatelessWidget {
  const CoachModelScreen({super.key, required this.exercise});

  final Exercise exercise;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;
    final cues = exercise.cues ?? const <String, CueText>{};
    final thresholds = exercise.repThresholds ?? const <String, dynamic>{};
    final rules = exercise.rules ?? const <Map<String, dynamic>>[];

    return Scaffold(
      appBar: AppBar(title: Text('Coach Model', style: text.headlineMedium)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: cs.primary,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'COACH MODEL READY',
                        style: text.labelSmall!.copyWith(
                          color: cs.primary,
                          letterSpacing: 1.2,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(exercise.nameEn, style: text.headlineMedium),
                  if (exercise.nameAr.trim().isNotEmpty)
                    Text(
                      exercise.nameAr,
                      style: text.bodySmall!.copyWith(
                        color: cs.onSurfaceVariant,
                      ),
                    ),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      Expanded(
                        child: _CountTile(
                          label: 'CUES',
                          value: '${cues.length}',
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _CountTile(
                          label: 'THRESHOLDS',
                          value: '${thresholds.length}',
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _CountTile(
                          label: 'RULES',
                          value: '${rules.length}',
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          const SectionTitle(title: 'FORM CUES'),
          const SizedBox(height: 8),
          if (cues.isEmpty)
            _empty(text, cs, 'No cues were configured for this exercise.')
          else
            for (final entry in cues.entries)
              Card(
                margin: const EdgeInsets.only(bottom: 8),
                child: ListTile(
                  leading: Icon(
                    Icons.record_voice_over_outlined,
                    color: cs.primary,
                  ),
                  title: Text(
                    entry.value.en.trim().isEmpty ? entry.key : entry.value.en,
                    style: text.bodyLarge,
                  ),
                  subtitle: entry.value.ar.trim().isEmpty
                      ? Text(
                          entry.key.toUpperCase(),
                          style: text.labelSmall!.copyWith(
                            color: cs.onSurfaceVariant,
                          ),
                        )
                      : Text(
                          entry.value.ar,
                          style: text.bodySmall!.copyWith(
                            color: cs.onSurfaceVariant,
                          ),
                        ),
                ),
              ),
          const SizedBox(height: 16),
          const SectionTitle(title: 'REP THRESHOLDS'),
          const SizedBox(height: 8),
          if (thresholds.isEmpty)
            _empty(text, cs, 'No rep thresholds were configured.')
          else
            Card(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  children: [
                    for (final entry in thresholds.entries)
                      _ThresholdEntry(name: entry.key, value: entry.value),
                  ],
                ),
              ),
            ),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Row(
                children: [
                  Icon(Icons.videocam_outlined, color: cs.onSurfaceVariant),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'This model powers the live camera coaching HUD. Start a set '
                      'from the workout tracker to use it in a session.',
                      style: text.bodySmall!.copyWith(
                        color: cs.onSurfaceVariant,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _empty(TextTheme text, ColorScheme cs, String message) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Text(
          message,
          style: text.bodySmall!.copyWith(color: cs.onSurfaceVariant),
        ),
      ),
    );
  }
}

/// Renders one rep-threshold entry. Scalar values sit on the right of their
/// label; maps/lists are expanded into indented sub-entries so long values
/// (e.g. depth classes) wrap instead of overflowing the row.
class _ThresholdEntry extends StatelessWidget {
  const _ThresholdEntry({
    required this.name,
    required this.value,
    this.depth = 0,
  });

  final String name;
  final dynamic value;
  final int depth;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;
    final indent = depth * 12.0;

    if (value is Map) {
      final map = value as Map;
      if (map.isEmpty) return _row(text, cs, indent, '—');
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.only(left: indent, top: 6, bottom: 2),
            child: Text(
              _humanize(name),
              style: text.labelSmall!.copyWith(
                color: cs.onSurfaceVariant,
                letterSpacing: 0.6,
              ),
            ),
          ),
          for (final entry in map.entries)
            _ThresholdEntry(
              name: '${entry.key}',
              value: entry.value,
              depth: depth + 1,
            ),
        ],
      );
    }

    if (value is List) {
      return _row(
        text,
        cs,
        indent,
        value.isEmpty ? '—' : value.map(_formatValue).join(', '),
      );
    }

    return _row(text, cs, indent, _formatValue(value));
  }

  Widget _row(TextTheme text, ColorScheme cs, double indent, String display) {
    return Padding(
      padding: EdgeInsets.only(left: indent, top: 4, bottom: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 4,
            child: Text(
              _humanize(name),
              style: text.labelSmall!.copyWith(color: cs.onSurfaceVariant),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            flex: 5,
            child: Text(
              display,
              textAlign: TextAlign.right,
              style: text.bodyMedium!.copyWith(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  static String _formatValue(dynamic value) {
    if (value == null) return '—';
    if (value is bool) return value ? 'yes' : 'no';
    return '$value';
  }

  /// `depthClasses` -> `DEPTH CLASSES`, `maxKneeAngleDeg` -> `MAX KNEE ANGLE DEG`
  static String _humanize(String key) {
    final spaced = key
        .replaceAllMapped(
          RegExp(r'([a-z0-9])([A-Z])'),
          (match) => '${match[1]} ${match[2]}',
        )
        .replaceAll('_', ' ');
    return spaced.toUpperCase();
  }
}

class _CountTile extends StatelessWidget {
  const _CountTile({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: cs.surfaceContainer,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: text.labelSmall!.copyWith(color: cs.onSurfaceVariant),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: text.titleLarge!.copyWith(fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}
