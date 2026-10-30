import 'package:flutter/material.dart';
import 'package:spotter/core/date_formatter.dart';
import 'package:spotter/features/workouts/domain/entities/session_status.dart';
import 'package:spotter/features/workouts/domain/entities/workout_session.dart';

class WorkoutCard extends StatelessWidget {
  const WorkoutCard({
    super.key,
    required this.workout,
    required this.onTap,
    this.onDelete,
  });

  final WorkoutSession workout;
  final VoidCallback onTap;
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;
    final status = _statusMeta(workout.status, cs);

    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: status.background,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: status.border),
                    ),
                    child: Text(
                      status.label,
                      style: text.labelSmall!.copyWith(
                        color: status.foreground,
                      ),
                    ),
                  ),
                  const Spacer(),
                  if (onDelete != null)
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
              const SizedBox(height: 6),
              Text(workout.name, style: text.titleLarge),
              const SizedBox(height: 2),
              Text(
                _subtitle(workout),
                style: text.bodySmall!.copyWith(color: cs.onSurfaceVariant),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  _Meta(
                    icon: Icons.calendar_today_outlined,
                    value:
                        workout.status == SessionStatus.planned &&
                            workout.scheduledFor != null
                        ? DateFormatter.dateTime(workout.scheduledFor!)
                        : DateFormatter.date(
                            workout.startedAt ??
                                workout.scheduledFor ??
                                workout.createdAt,
                          ),
                  ),
                  const SizedBox(width: 16),
                  if (workout.startedAt != null)
                    _Meta(
                      icon: Icons.timer_outlined,
                      value: DateFormatter.clock(workout.startedAt!),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _subtitle(WorkoutSession workout) {
    switch (workout.status) {
      case SessionStatus.planned:
        final scheduledFor = workout.scheduledFor;
        if (scheduledFor == null) return 'Ready to plan';
        return 'Scheduled ${DateFormatter.dateTime(scheduledFor)}';
      case SessionStatus.inProgress:
        return 'In progress · tap to continue';
      case SessionStatus.paused:
        return 'Paused · tap to continue';
      case SessionStatus.finished:
        final endedAt = workout.endedAt;
        if (endedAt == null) return 'Finished';
        return 'Finished ${DateFormatter.dateTime(endedAt)}';
      case SessionStatus.cancelled:
        return 'Cancelled';
    }
  }

  _StatusMeta _statusMeta(SessionStatus status, ColorScheme cs) {
    switch (status) {
      case SessionStatus.planned:
        return _StatusMeta(
          label: 'SCHEDULED',
          foreground: cs.onSecondaryContainer,
          background: cs.secondaryContainer,
          border: cs.outlineVariant,
        );
      case SessionStatus.inProgress:
      case SessionStatus.paused:
        return _StatusMeta(
          label: status == SessionStatus.paused ? 'PAUSED' : 'LIVE',
          foreground: cs.primary,
          background: cs.primaryContainer,
          border: cs.primary,
        );
      case SessionStatus.finished:
        return _StatusMeta(
          label: 'FINISHED',
          foreground: cs.onSurfaceVariant,
          background: cs.surfaceContainer,
          border: cs.outlineVariant,
        );
      case SessionStatus.cancelled:
        return _StatusMeta(
          label: 'CANCELLED',
          foreground: cs.error,
          background: cs.surfaceContainer,
          border: cs.outlineVariant,
        );
    }
  }
}

class _StatusMeta {
  const _StatusMeta({
    required this.label,
    required this.foreground,
    required this.background,
    required this.border,
  });

  final String label;
  final Color foreground;
  final Color background;
  final Color border;
}

class _Meta extends StatelessWidget {
  const _Meta({required this.icon, required this.value});

  final IconData icon;
  final String value;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;
    return Row(
      children: [
        Icon(icon, size: 14, color: cs.onSurfaceVariant),
        const SizedBox(width: 4),
        Text(
          value,
          style: text.labelSmall!.copyWith(color: cs.onSurfaceVariant),
        ),
      ],
    );
  }
}
