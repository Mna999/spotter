import 'package:flutter/material.dart';
import 'package:spotter/features/workouts/domain/entities/set_summary.dart';

class SetLedger extends StatelessWidget {
  const SetLedger({
    super.key,
    required this.sets,
    required this.targetSets,
    required this.targetReps,
    required this.targetLoad,
    this.onEdit,
    this.onDelete,
    this.isReadOnly = false,
  });

  final List<SetSummary> sets;
  final int targetSets;
  final int targetReps;
  final double targetLoad;
  final ValueChanged<SetSummary>? onEdit;
  final ValueChanged<SetSummary>? onDelete;
  final bool isReadOnly;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          child: Row(
            children: [
              _header(text, cs, 'SET', flex: 2),
              _header(text, cs, 'LOAD'),
              _header(text, cs, 'REPS'),
              _header(text, cs, 'TUT', flex: 2),
              const SizedBox(width: 44),
            ],
          ),
        ),
        for (var i = 0; i < targetSets; i++)
          _SetRow(
            index: i,
            set: i < sets.length ? sets[i] : null,
            targetReps: targetReps,
            targetLoad: targetLoad,
            onEdit: onEdit,
            onDelete: onDelete,
            isReadOnly: isReadOnly,
          ),
      ],
    );
  }

  Widget _header(TextTheme text, ColorScheme cs, String label, {int flex = 2}) {
    return Expanded(
      flex: flex,
      child: Text(
        label,
        style: text.labelSmall!.copyWith(color: cs.onSurfaceVariant),
      ),
    );
  }
}

class _SetRow extends StatelessWidget {
  const _SetRow({
    required this.index,
    required this.set,
    required this.targetReps,
    required this.targetLoad,
    this.onEdit,
    this.onDelete,
    this.isReadOnly = false,
  });

  final int index;
  final SetSummary? set;
  final int targetReps;
  final double targetLoad;
  final ValueChanged<SetSummary>? onEdit;
  final ValueChanged<SetSummary>? onDelete;
  final bool isReadOnly;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;
    final hasSet = set != null;
    final foreground = hasSet ? cs.onSurface : cs.onSurfaceVariant;

    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: hasSet ? cs.surfaceContainer : cs.surfaceContainerLow,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: hasSet ? cs.outlineVariant : cs.surfaceContainer,
        ),
      ),
      child: Row(
        children: [
          _cell(
            text,
            cs,
            (index + 1).toString().padLeft(2, '0'),
            flex: 2,
            color: hasSet ? cs.secondary : cs.onSurfaceVariant,
            weight: FontWeight.bold,
          ),
          _cell(
            text,
            cs,
            hasSet ? _trim(set!.load) : _trim(targetLoad),
            color: foreground,
          ),
          _cell(
            text,
            cs,
            hasSet ? '${set!.reps}' : '$targetReps',
            color: foreground,
          ),
          _cell(
            text,
            cs,
            hasSet ? '${set!.timeUnderTension}' : '—',
            flex: 2,
            color: foreground,
          ),
          SizedBox(
            width: 44,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                if (hasSet && !isReadOnly) ...[
                  _action(
                    icon: Icons.edit_outlined,
                    color: cs.primary,
                    tooltip: 'Edit set',
                    onTap: () => onEdit?.call(set!),
                  ),
                  _action(
                    icon: Icons.undo,
                    color: cs.onSurfaceVariant,
                    tooltip: 'Undo set',
                    onTap: () => onDelete?.call(set!),
                  ),
                ] else
                  Icon(
                    hasSet ? Icons.check_circle : Icons.radio_button_unchecked,
                    size: 20,
                    color: hasSet ? cs.primary : cs.outlineVariant,
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _cell(
    TextTheme text,
    ColorScheme cs,
    String value, {
    int flex = 2,
    Color? color,
    FontWeight weight = FontWeight.w600,
  }) {
    return Expanded(
      flex: flex,
      child: Text(
        value,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: text.bodyMedium!.copyWith(
          color: color ?? cs.onSurface,
          fontWeight: weight,
        ),
      ),
    );
  }

  Widget _action({
    required IconData icon,
    required Color color,
    required String tooltip,
    required VoidCallback onTap,
  }) {
    return Tooltip(
      message: tooltip,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.all(2),
          child: Icon(icon, size: 17, color: color),
        ),
      ),
    );
  }

  String _trim(double value) {
    if (value == value.roundToDouble()) return value.toStringAsFixed(0);
    return value.toStringAsFixed(1);
  }
}
