import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:spotter/core/app_dialog.dart';
import 'package:spotter/core/date_formatter.dart';
import 'package:spotter/core/snack_bar_builder.dart';
import 'package:spotter/core/theme/app_theme.dart';
import 'package:spotter/features/workouts/domain/entities/exercise.dart';
import 'package:spotter/features/workouts/domain/entities/planned_exercise.dart';
import 'package:spotter/features/workouts/domain/entities/set_summary.dart';
import 'package:spotter/features/workouts/domain/entities/workout_session.dart';
import 'package:spotter/features/workouts/presentation/blocs/exercise_library_bloc/exercise_library_bloc.dart';
import 'package:spotter/features/workouts/presentation/blocs/workout_session_bloc/workout_session_bloc.dart';
import 'package:spotter/features/workouts/presentation/screens/set_form_sheet.dart';
import 'package:spotter/features/workouts/presentation/widgets/rest_timer_card.dart';
import 'package:spotter/features/workouts/presentation/widgets/section_title.dart';
import 'package:spotter/features/workouts/presentation/widgets/set_ledger.dart';
import 'package:spotter/features/workouts/presentation/widgets/stat_tile.dart';
import 'package:spotter/injection_container.dart';

class WorkoutSessionScreen extends StatefulWidget {
  const WorkoutSessionScreen({super.key});

  @override
  State<WorkoutSessionScreen> createState() => _WorkoutSessionScreenState();
}

class _WorkoutSessionScreenState extends State<WorkoutSessionScreen> {
  final Set<String> _requestedExerciseIds = {};
  WorkoutSessionState? _lastActiveState;
  bool _isPaused = false;

  void _rememberActiveState(WorkoutSessionState state) {
    if (state is WorkoutInProgress ||
        state is WorkoutResting ||
        state is WorkoutFinished) {
      _lastActiveState = state;
    }
    if (state is WorkoutInProgress) _isPaused = false;
  }

  void _requestExerciseDetails(
    BuildContext context,
    List<PlannedExercise> plannedExercises,
  ) {
    final missing = plannedExercises
        .map((e) => e.exerciseId)
        .where((id) => !_requestedExerciseIds.contains(id))
        .toList();
    if (missing.isEmpty) return;
    _requestedExerciseIds.addAll(missing);
    context.read<ExerciseLibraryBloc>().add(
      ExerciseDetailsRequested(exerciseIds: missing),
    );
  }

  Future<void> _logSet(
    BuildContext context, {
    required WorkoutSession workout,
    required PlannedExercise plannedExercise,
    required List<SetSummary> completedSets,
    required int order,
  }) async {
    final result = await showSetFormSheet(
      context,
      title: 'LOG SET $order',
      subtitle: _exerciseName(context, plannedExercise.exerciseId),
      reps: plannedExercise.targetReps,
      load: plannedExercise.targetLoad,
      timeUnderTension: 30,
      restSec: plannedExercise.restSec,
    );
    if (result == null || !context.mounted) return;

    context.read<WorkoutSessionBloc>().add(
      SetCompleted(
        workoutId: workout.workoutId,
        uid: workout.uid,
        exerciseId: plannedExercise.exerciseId,
        order: order,
        reps: result.reps,
        load: result.load,
        timeUnderTension: result.timeUnderTension,
        restSec: result.restSec,
      ),
    );
  }

  Future<void> _editSet(
    BuildContext context, {
    required WorkoutSession workout,
    required SetSummary set,
  }) async {
    final result = await showSetFormSheet(
      context,
      title: 'EDIT SET ${set.order}',
      subtitle: _exerciseName(context, set.exerciseId),
      reps: set.reps,
      load: set.load,
      timeUnderTension: set.timeUnderTension,
      restSec: set.restSec,
      confirmLabel: 'SAVE CHANGES',
    );
    if (result == null || !context.mounted) return;

    context.read<WorkoutSessionBloc>().add(
      SetUpdated(
        uid: workout.uid,
        workoutId: workout.workoutId,
        setId: set.setId,
        reps: result.reps,
        load: result.load,
        timeUnderTension: result.timeUnderTension,
        restSec: result.restSec,
      ),
    );
  }

  void _undoSet(BuildContext context, WorkoutSession workout, SetSummary set) {
    showAppDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Undo set?'),
        content: Text(
          'Set ${set.order} (${_trim(set.load)} kg × ${set.reps}) will be '
          'removed, and the session goes back to that set so you can log it '
          'again.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              context.read<WorkoutSessionBloc>().add(
                SetDeleted(
                  uid: workout.uid,
                  workoutId: workout.workoutId,
                  setId: set.setId,
                ),
              );
            },
            child: const Text('Undo'),
          ),
        ],
      ),
    );
  }

  void _finishWorkout(BuildContext context) {
    showAppDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Finish workout?'),
        content: const Text(
          'The session will be closed and your logged sets are saved.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Keep training'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              context.read<WorkoutSessionBloc>().add(
                const WorkoutFinishRequested(),
              );
            },
            child: const Text('Finish'),
          ),
        ],
      ),
    );
  }

  void _cancelWorkout(BuildContext context) {
    showAppDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Discard workout?'),
        content: const Text(
          'The workout is closed. Logged sets stay saved in its history.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Keep training'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              context.read<WorkoutSessionBloc>().add(
                const WorkoutCancelled(reason: 'Abandoned by user'),
              );
              Navigator.pop(context);
            },
            child: const Text('Discard'),
          ),
        ],
      ),
    );
  }

  void _togglePause(BuildContext context) {
    final bloc = context.read<WorkoutSessionBloc>();
    setState(() => _isPaused = !_isPaused);
    if (_isPaused) {
      bloc.add(const WorkoutPaused());
    } else {
      bloc.add(const WorkoutPauseResumed());
    }
  }

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;

    return BlocProvider(
      create: (_) => sl<ExerciseLibraryBloc>(),
      child: BlocConsumer<WorkoutSessionBloc, WorkoutSessionState>(
        listener: (context, state) {
          _rememberActiveState(state);
          if (state is WorkoutError) {
            SnackBarBuilder.showSnackBar(context, state.message, true, cs);
          }
          if (state is WorkoutInProgress) {
            _requestExerciseDetails(context, state.plannedExercises);
          }
          if (state is WorkoutResting) {
            _requestExerciseDetails(context, state.plannedExercises);
          }
        },
        builder: (context, state) {
          final stateForView = _stateForView(state);
          final isLive =
              stateForView is WorkoutInProgress ||
              stateForView is WorkoutResting;

          return Scaffold(
            appBar: AppBar(
              title: Text(
                _workoutOf(stateForView)?.name ?? 'Routine Session',
                style: text.headlineMedium,
              ),
              leading: IconButton(
                onPressed: isLive ? () => _cancelWorkout(context) : null,
                tooltip: 'Discard workout',
                icon: const Icon(Icons.close),
              ),
              actions: [
                if (isLive) ...[
                  IconButton(
                    onPressed: () => _togglePause(context),
                    tooltip: _isPaused
                        ? 'Resume rest timer'
                        : 'Pause rest timer',
                    icon: Icon(_isPaused ? Icons.play_arrow : Icons.pause),
                  ),
                  IconButton(
                    onPressed: () => _finishWorkout(context),
                    tooltip: 'Finish workout',
                    icon: const Icon(Icons.stop_circle_outlined),
                  ),
                ],
              ],
            ),
            body: switch (stateForView) {
              WorkoutInProgress(
                :final workout,
                :final plannedExercises,
                :final completedSets,
                :final currentIndex,
                :final currentSetNumber,
              ) =>
                _liveView(
                  context,
                  workout: workout,
                  plannedExercises: plannedExercises,
                  completedSets: completedSets,
                  currentIndex: currentIndex,
                  currentSetNumber: currentSetNumber,
                  restRemaining: null,
                  lastSet: null,
                ),
              WorkoutResting(
                :final workout,
                :final plannedExercises,
                :final completedSets,
                :final currentIndex,
                :final currentSetNumber,
                :final restRemaining,
                :final lastSet,
              ) =>
                _liveView(
                  context,
                  workout: workout,
                  plannedExercises: plannedExercises,
                  completedSets: completedSets,
                  currentIndex: currentIndex,
                  currentSetNumber: currentSetNumber,
                  restRemaining: restRemaining,
                  lastSet: lastSet,
                ),
              WorkoutFinished(
                :final workout,
                :final completedSets,
                :final duration,
              ) =>
                _finishedView(
                  context,
                  workout: workout,
                  completedSets: completedSets,
                  duration: duration,
                ),
              WorkoutError(:final message) => _errorView(context, message),
              WorkoutEmpty() => _errorView(
                context,
                'This workout is no longer available.',
              ),
              _ => const Center(child: CircularProgressIndicator()),
            },
          );
        },
      ),
    );
  }

  WorkoutSessionState _stateForView(WorkoutSessionState state) {
    if (state is WorkoutLoading ||
        state is WorkoutInitial ||
        state is WorkoutsLoaded ||
        state is WorkoutLoaded) {
      return _lastActiveState ?? state;
    }
    return state;
  }

  Widget _liveView(
    BuildContext context, {
    required WorkoutSession workout,
    required List<PlannedExercise> plannedExercises,
    required List<SetSummary> completedSets,
    required int currentIndex,
    required int currentSetNumber,
    required Duration? restRemaining,
    required SetSummary? lastSet,
  }) {
    final text = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;
    final warning = context.appColors.warning;
    final libraryState = context.watch<ExerciseLibraryBloc>().state;
    final exerciseMap = libraryState is ExerciseDetailsLoaded
        ? libraryState.exercises
        : const <String, Exercise>{};

    if (plannedExercises.isEmpty) {
      return _errorView(
        context,
        'This workout has no planned exercises. Add exercises from the plan '
        'screen and try again.',
      );
    }

    final safeIndex = currentIndex.clamp(0, plannedExercises.length - 1);
    final current = plannedExercises[safeIndex];
    final setsForCurrent =
        completedSets
            .where((s) => s.plannedExerciseId == current.plannedExerciseId)
            .toList()
          ..sort((a, b) => a.order.compareTo(b.order));
    final targetRows = math.max(current.targetSets, setsForCurrent.length);
    final nextOrder = setsForCurrent.isEmpty
        ? 1
        : setsForCurrent.map((s) => s.order).reduce(math.max) + 1;
    final volume = completedSets.fold<double>(
      0,
      (sum, s) => sum + s.load * s.reps,
    );

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: _isPaused ? warning : cs.primary,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      _isPaused ? 'PAUSED' : 'LIVE WORKOUT',
                      style: text.labelSmall!.copyWith(
                        color: _isPaused ? warning : cs.primary,
                        letterSpacing: 1.2,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      DateFormatter.clock(
                        workout.startedAt ?? workout.createdAt,
                      ),
                      style: text.labelSmall!.copyWith(
                        color: cs.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(workout.name, style: text.headlineMedium),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: StatTile(
                        label: 'Exercises',
                        value: '${plannedExercises.length}',
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: StatTile(
                        label: 'Sets',
                        value: '${completedSets.length}',
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: StatTile(
                        label: 'Volume',
                        value: DateFormatter.thousands(volume),
                        unit: 'kg',
                        accent: cs.primary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        if (restRemaining != null) ...[
          const SizedBox(height: 12),
          RestTimerCard(
            remaining: restRemaining,
            total: Duration(seconds: lastSet?.restSec ?? current.restSec),
            onSkip: _isPaused
                ? () {}
                : () => context.read<WorkoutSessionBloc>().add(
                    const RestSkipped(),
                  ),
            upNext:
                'Set ${math.min(currentSetNumber, current.targetSets)} of '
                '${current.targetSets} · '
                '${_nameOf(exerciseMap, current.exerciseId)}',
          ),
        ],
        const SizedBox(height: 16),
        SectionTitle(
          title: 'CURRENT EXERCISE',
          trailing:
              'Set ${math.min(currentSetNumber, current.targetSets)} '
              'of ${current.targetSets}',
        ),
        const SizedBox(height: 8),
        Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(color: cs.primary, width: 1.5),
          ),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
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
                    Expanded(
                      child: Text(
                        'CURRENT EXERCISE',
                        style: text.labelSmall!.copyWith(
                          color: cs.primary,
                          letterSpacing: 1.1,
                        ),
                      ),
                    ),
                    Text(
                      'REST ${current.restSec}s',
                      style: text.labelSmall!.copyWith(
                        color: cs.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  _nameOf(exerciseMap, current.exerciseId),
                  style: text.headlineMedium,
                ),
                const SizedBox(height: 12),
                SetLedger(
                  sets: setsForCurrent,
                  targetSets: targetRows,
                  targetReps: current.targetReps,
                  targetLoad: current.targetLoad,
                  onEdit: (set) =>
                      _editSet(context, workout: workout, set: set),
                  onDelete: (set) => _undoSet(context, workout, set),
                ),
                const SizedBox(height: 4),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed: _isPaused
                        ? null
                        : () => _logSet(
                            context,
                            workout: workout,
                            plannedExercise: current,
                            completedSets: completedSets,
                            order: nextOrder,
                          ),
                    icon: const Icon(Icons.add_task),
                    label: Text('LOG SET $nextOrder'),
                  ),
                ),
                if (completedSets.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: _isPaused
                          ? null
                          : () =>
                                _undoSet(context, workout, completedSets.last),
                      icon: const Icon(Icons.undo),
                      label: const Text('UNDO LAST SET'),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        SectionTitle(
          title: 'EXERCISE PROGRAMME',
          trailing: 'Target: ${plannedExercises.length} exercises',
        ),
        const SizedBox(height: 8),
        for (var i = 0; i < plannedExercises.length; i++)
          if (i != safeIndex)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: _UpNextCard(
                plannedExercise: plannedExercises[i],
                index: i,
                name: _nameOf(exerciseMap, plannedExercises[i].exerciseId),
                sets: completedSets
                    .where(
                      (s) =>
                          s.plannedExerciseId ==
                          plannedExercises[i].plannedExerciseId,
                    )
                    .toList(),
                onEdit: (set) => _editSet(context, workout: workout, set: set),
                onUndo: (set) => _undoSet(context, workout, set),
              ),
            ),
        const SizedBox(height: 8),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: () => _finishWorkout(context),
            icon: const Icon(Icons.stop_circle_outlined),
            label: const Text('FINISH WORKOUT'),
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _finishedView(
    BuildContext context, {
    required WorkoutSession workout,
    required List<SetSummary> completedSets,
    required Duration duration,
  }) {
    final text = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;
    final libraryState = context.watch<ExerciseLibraryBloc>().state;
    final exerciseMap = libraryState is ExerciseDetailsLoaded
        ? libraryState.exercises
        : const <String, Exercise>{};

    final totalReps = completedSets.fold<int>(0, (sum, s) => sum + s.reps);
    final volume = completedSets.fold<double>(
      0,
      (sum, s) => sum + s.load * s.reps,
    );
    final grouped = <String, List<SetSummary>>{};
    for (final set in completedSets) {
      grouped.putIfAbsent(set.plannedExerciseId, () => []).add(set);
    }

    return ListView(
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
                    Icon(Icons.check_circle, color: cs.primary, size: 18),
                    const SizedBox(width: 6),
                    Text(
                      'WORKOUT COMPLETE',
                      style: text.labelSmall!.copyWith(
                        color: cs.primary,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(workout.name, style: text.headlineMedium),
                const SizedBox(height: 14),
                Row(
                  children: [
                    Expanded(
                      child: StatTile(
                        label: 'Duration',
                        value: DateFormatter.shortDuration(duration),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: StatTile(
                        label: 'Sets',
                        value: '${completedSets.length}',
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: StatTile(label: 'Reps', value: '$totalReps'),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: StatTile(
                        label: 'Volume',
                        value: DateFormatter.thousands(volume),
                        unit: 'kg',
                        accent: cs.primary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        const SectionTitle(title: 'SET HISTORY'),
        const SizedBox(height: 8),
        if (completedSets.isEmpty)
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                'No sets were logged for this workout.',
                style: text.bodySmall!.copyWith(color: cs.onSurfaceVariant),
              ),
            ),
          )
        else
          for (final entry in grouped.entries)
            Card(
              margin: const EdgeInsets.only(bottom: 10),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _nameOf(exerciseMap, entry.value.first.exerciseId),
                      style: text.titleLarge,
                    ),
                    const SizedBox(height: 8),
                    SetLedger(
                      sets: entry.value,
                      targetSets: entry.value.length,
                      targetReps: entry.value.first.reps,
                      targetLoad: entry.value.first.load,
                      onEdit: (set) =>
                          _editSet(context, workout: workout, set: set),
                      onDelete: (set) => _undoSet(context, workout, set),
                    ),
                  ],
                ),
              ),
            ),
        const SizedBox(height: 8),
        SizedBox(
          width: double.infinity,
          child: FilledButton(
            onPressed: () =>
                Navigator.of(context).popUntil((route) => route.isFirst),
            child: const Text('DONE'),
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _errorView(BuildContext context, String message) {
    final text = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline, size: 44, color: cs.error),
            const SizedBox(height: 12),
            Text('Session unavailable', style: text.titleLarge),
            const SizedBox(height: 6),
            Text(
              message,
              textAlign: TextAlign.center,
              style: text.bodySmall!.copyWith(color: cs.error),
            ),
            const SizedBox(height: 16),
            OutlinedButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('GO BACK'),
            ),
          ],
        ),
      ),
    );
  }

  String _exerciseName(BuildContext context, String exerciseId) {
    final state = context.read<ExerciseLibraryBloc>().state;
    if (state is ExerciseDetailsLoaded) {
      return state.exercises[exerciseId]?.nameEn ?? 'Exercise';
    }
    return 'Exercise';
  }

  WorkoutSession? _workoutOf(WorkoutSessionState state) {
    switch (state) {
      case WorkoutInProgress(:final workout):
        return workout;
      case WorkoutResting(:final workout):
        return workout;
      case WorkoutFinished(:final workout):
        return workout;
      default:
        return null;
    }
  }

  String _nameOf(Map<String, Exercise> exerciseMap, String exerciseId) {
    return exerciseMap[exerciseId]?.nameEn ?? 'Exercise';
  }

  String _trim(double value) {
    if (value == value.roundToDouble()) return value.toStringAsFixed(0);
    return value.toStringAsFixed(1);
  }
}

/// A planned exercise in the programme list. Any exercise that already has
/// logged sets can be expanded to edit or undo those sets without leaving the
/// current exercise.
class _UpNextCard extends StatefulWidget {
  const _UpNextCard({
    required this.plannedExercise,
    required this.index,
    required this.name,
    required this.sets,
    required this.onEdit,
    required this.onUndo,
  });

  final PlannedExercise plannedExercise;
  final int index;
  final String name;
  final List<SetSummary> sets;
  final ValueChanged<SetSummary> onEdit;
  final ValueChanged<SetSummary> onUndo;

  @override
  State<_UpNextCard> createState() => _UpNextCardState();
}

class _UpNextCardState extends State<_UpNextCard> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;
    final hasSets = widget.sets.isNotEmpty;

    return Card(
      child: Column(
        children: [
          InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: hasSets
                ? () => setState(() => _expanded = !_expanded)
                : null,
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  Container(
                    width: 30,
                    height: 30,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: cs.surfaceContainer,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '${widget.index + 1}',
                      style: text.labelLarge!.copyWith(
                        color: cs.onSurfaceVariant,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: text.bodyLarge,
                        ),
                        Text(
                          '${widget.sets.length} of '
                          '${widget.plannedExercise.targetSets} sets logged',
                          style: text.labelSmall!.copyWith(
                            color: cs.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    '${widget.plannedExercise.targetSets} × '
                    '${widget.plannedExercise.targetReps}',
                    style: text.labelMedium!.copyWith(color: cs.secondary),
                  ),
                  if (hasSets) ...[
                    const SizedBox(width: 6),
                    Icon(
                      _expanded ? Icons.expand_less : Icons.expand_more,
                      size: 18,
                      color: cs.onSurfaceVariant,
                    ),
                  ],
                ],
              ),
            ),
          ),
          if (_expanded && hasSets)
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
              child: SetLedger(
                sets: widget.sets,
                targetSets: widget.sets.length,
                targetReps: widget.plannedExercise.targetReps,
                targetLoad: widget.plannedExercise.targetLoad,
                onEdit: widget.onEdit,
                onDelete: widget.onUndo,
              ),
            ),
        ],
      ),
    );
  }
}
