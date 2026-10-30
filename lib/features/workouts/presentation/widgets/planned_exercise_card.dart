import 'package:flutter/material.dart';
import 'package:spotter/features/workouts/domain/entities/exercise.dart';
import 'package:spotter/features/workouts/domain/entities/planned_exercise.dart';

class PlannedExerciseCard extends StatelessWidget {
  const PlannedExerciseCard({
    super.key,
    required this.plannedExercise,
    required this.index,
    this.exercise,
    this.onCoachTap,
    this.onEdit,
    this.onDelete,
    this.isCurrent = false,
    this.isReadOnly = false,
  });

  final PlannedExercise plannedExercise;
  final int index;
  final Exercise? exercise;
  final VoidCallback? onCoachTap;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final bool isCurrent;
  final bool isReadOnly;

  bool get hasCoachModel {
    final repThresholds = exercise?.repThresholds;
    final cues = exercise?.cues;
    return repThresholds != null &&
        repThresholds.isNotEmpty &&
        cues != null &&
        cues.isNotEmpty;
  }

  String get exerciseName {
    final name = exercise?.nameEn;
    if (name != null && name.trim().isNotEmpty) return name;
    return 'Exercise';
  }

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;

    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: isCurrent ? cs.primary : cs.outlineVariant,
          width: isCurrent ? 1.5 : 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 32,
                  height: 32,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: isCurrent ? cs.primary : cs.surfaceContainer,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '${index + 1}',
                    style: text.titleLarge!.copyWith(
                      color: isCurrent ? cs.onPrimary : cs.onSurfaceVariant,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (isCurrent)
                        Row(
                          children: [
                            Container(
                              width: 6,
                              height: 6,
                              decoration: BoxDecoration(
                                color: cs.primary,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              'CURRENT EXERCISE',
                              style: text.labelSmall!.copyWith(
                                color: cs.primary,
                                letterSpacing: 1.1,
                              ),
                            ),
                          ],
                        ),
                      Text(
                        exerciseName,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: text.titleLarge,
                      ),
                      if (exercise != null &&
                          exercise!.nameAr.trim().isNotEmpty)
                        Text(
                          exercise!.nameAr,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: text.bodySmall!.copyWith(
                            color: cs.onSurfaceVariant,
                          ),
                        ),
                    ],
                  ),
                ),
                if (!isReadOnly)
                  IconButton(
                    onPressed: onDelete,
                    visualDensity: VisualDensity.compact,
                    icon: Icon(
                      Icons.delete_outline,
                      size: 20,
                      color: cs.onSurfaceVariant,
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 10),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: cs.surfaceContainer,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  _Target(
                    label: 'SETS',
                    value: '${plannedExercise.targetSets}',
                  ),
                  _Target(
                    label: 'REPS',
                    value: '${plannedExercise.targetReps}',
                  ),
                  _Target(
                    label: 'LOAD',
                    value: '${_trim(plannedExercise.targetLoad)} kg',
                  ),
                  _Target(label: 'REST', value: '${plannedExercise.restSec}s'),
                  if (plannedExercise.targetTempo.trim().isNotEmpty)
                    _Target(label: 'TEMPO', value: plannedExercise.targetTempo),
                ],
              ),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                if (hasCoachModel)
                  Expanded(
                    child: FilledButton.icon(
                      onPressed: onCoachTap,
                      style: FilledButton.styleFrom(
                        minimumSize: const Size(0, 40),
                        backgroundColor: cs.primaryContainer,
                        foregroundColor: cs.primary,
                      ),
                      icon: const Icon(Icons.center_focus_strong, size: 18),
                      label: const Text('USE COACH MODEL'),
                    ),
                  )
                else
                  const Spacer(),
                if (!isReadOnly) ...[
                  if (hasCoachModel) const SizedBox(width: 8),
                  OutlinedButton.icon(
                    onPressed: onEdit,
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size(0, 40),
                    ),
                    icon: const Icon(Icons.edit_outlined, size: 18),
                    label: const Text('Edit'),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _trim(double value) {
    if (value == value.roundToDouble()) return value.toStringAsFixed(0);
    return value.toStringAsFixed(1);
  }
}

class _Target extends StatelessWidget {
  const _Target({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: text.labelSmall!.copyWith(color: cs.onSurfaceVariant),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: text.bodyMedium!.copyWith(
              color: cs.onSurface,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
