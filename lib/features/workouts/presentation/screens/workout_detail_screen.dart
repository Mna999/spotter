import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:spotter/core/app_dialog.dart';
import 'package:spotter/core/date_formatter.dart';
import 'package:spotter/core/route/routing.dart';
import 'package:spotter/core/snack_bar_builder.dart';
import 'package:spotter/features/workouts/domain/entities/exercise.dart';
import 'package:spotter/features/workouts/domain/entities/planned_exercise.dart';
import 'package:spotter/features/workouts/domain/entities/session_status.dart';
import 'package:spotter/features/workouts/domain/entities/set_summary.dart';
import 'package:spotter/features/workouts/domain/entities/workout_session.dart';
import 'package:spotter/features/workouts/presentation/blocs/exercise_library_bloc/exercise_library_bloc.dart';
import 'package:spotter/features/workouts/presentation/blocs/workout_session_bloc/workout_session_bloc.dart';
import 'package:spotter/features/workouts/presentation/screens/coach_model_screen.dart';
import 'package:spotter/features/workouts/presentation/screens/exercise_picker_screen.dart';
import 'package:spotter/features/workouts/presentation/screens/planned_exercise_form_sheet.dart';
import 'package:spotter/features/workouts/presentation/screens/set_form_sheet.dart';
import 'package:spotter/features/workouts/presentation/screens/workout_form_sheet.dart';
import 'package:spotter/features/workouts/presentation/screens/workout_session_screen.dart';
import 'package:spotter/features/workouts/presentation/widgets/planned_exercise_card.dart';
import 'package:spotter/features/workouts/presentation/widgets/section_title.dart';
import 'package:spotter/features/workouts/presentation/widgets/set_ledger.dart';
import 'package:spotter/features/workouts/presentation/widgets/stat_tile.dart';
import 'package:spotter/injection_container.dart';

class WorkoutDetailScreen extends StatefulWidget {
  const WorkoutDetailScreen({
    super.key,
    required this.uid,
    required this.workoutId,
  });

  final String uid;
  final String workoutId;

  @override
  State<WorkoutDetailScreen> createState() => _WorkoutDetailScreenState();
}

class _WorkoutDetailScreenState extends State<WorkoutDetailScreen> {
  final Set<String> _requestedExerciseIds = {};
  WorkoutSessionState? _lastDetailState;

  @override
  void initState() {
    super.initState();
    context.read<WorkoutSessionBloc>().add(
      LoadWorkoutPlan(uid: widget.uid, workoutId: widget.workoutId),
    );
  }

  void _rememberState(WorkoutSessionState state) {
    if (state is WorkoutPlanned ||
        state is WorkoutInProgress ||
        state is WorkoutFinished ||
        state is WorkoutEmpty) {
      _lastDetailState = state;
    }
  }

  /// Ignores list-level states (e.g. the dashboard reloading its history) so
  /// this screen keeps showing the workout it was opened for.
  WorkoutSessionState _stateForView(WorkoutSessionState state) {
    if (state is WorkoutsLoaded ||
        state is WorkoutLoaded ||
        state is WorkoutInitial) {
      return _lastDetailState ?? state;
    }
    return state;
  }

  void _reload(BuildContext context) {
    _requestedExerciseIds.clear();
    context.read<WorkoutSessionBloc>().add(
      LoadWorkoutPlan(uid: widget.uid, workoutId: widget.workoutId),
    );
  }

  void _requestExerciseDetails(
    BuildContext context,
    List<PlannedExercise> plannedExercises,
  ) {
    _requestExerciseIds(context, plannedExercises.map((e) => e.exerciseId));
  }

  void _requestExerciseIds(BuildContext context, Iterable<String> exerciseIds) {
    final missing = exerciseIds
        .where((id) => !_requestedExerciseIds.contains(id))
        .toSet()
        .toList();
    if (missing.isEmpty) return;
    _requestedExerciseIds.addAll(missing);
    context.read<ExerciseLibraryBloc>().add(
      ExerciseDetailsRequested(exerciseIds: missing),
    );
  }

  Future<void> _startWorkout(
    BuildContext context, {
    required WorkoutSession workout,
    required List<PlannedExercise> plannedExercises,
    required List<SetSummary> completedSets,
    required int currentIndex,
    required int currentSetNumber,
  }) async {
    final bloc = context.read<WorkoutSessionBloc>();
    if (workout.status == SessionStatus.planned) {
      bloc.add(
        WorkoutStarted(
          workoutSession: workout,
          plannedExercises: plannedExercises,
          completedSets: completedSets,
          currentIndex: currentIndex,
          currentSetNumber: currentSetNumber,
        ),
      );
    } else {
      bloc.add(
        WorkoutResumed(
          workoutSession: workout,
          plannedExercises: plannedExercises,
          completedSets: completedSets,
          currentIndex: currentIndex,
          currentSetNumber: currentSetNumber,
        ),
      );
    }

    await Routing.routePush(const WorkoutSessionScreen(), context);
    if (!context.mounted) return;
    _reload(context);
  }

  Future<void> _addExercise(
    BuildContext context,
    List<PlannedExercise> plannedExercises,
  ) async {
    final exercise = await Routing.routePush<Exercise>(
      const ExercisePickerScreen(),
      context,
    );
    if (exercise == null || !context.mounted) return;

    final result = await showPlannedExerciseSheet(
      context,
      exerciseName: exercise.nameEn,
    );
    if (result == null || !context.mounted) return;

    context.read<WorkoutSessionBloc>().add(
      PlannedExerciseAdded(
        uid: widget.uid,
        workoutId: widget.workoutId,
        exerciseId: exercise.exerciseId,
        order: plannedExercises.length + 1,
        targetSets: result.targetSets,
        targetReps: result.targetReps,
        targetLoad: result.targetLoad,
        targetTempo: result.targetTempo,
        restSec: result.restSec,
      ),
    );
  }

  Future<void> _editExercise(
    BuildContext context,
    PlannedExercise plannedExercise,
    Exercise? exercise,
  ) async {
    final result = await showPlannedExerciseSheet(
      context,
      exerciseName: exercise?.nameEn ?? 'Exercise',
      existing: plannedExercise,
    );
    if (result == null || !context.mounted) return;

    context.read<WorkoutSessionBloc>().add(
      PlannedExerciseUpdated(
        plannedExercise: plannedExercise.copyWith(
          targetSets: result.targetSets,
          targetReps: result.targetReps,
          targetLoad: result.targetLoad,
          targetTempo: result.targetTempo,
          restSec: result.restSec,
        ),
      ),
    );
  }

  Future<void> _editSet(
    BuildContext context, {
    required WorkoutSession workout,
    required SetSummary set,
    required String exerciseName,
  }) async {
    final result = await showSetFormSheet(
      context,
      title: 'EDIT SET ${set.order}',
      subtitle: exerciseName,
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
          'removed from this workout.',
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

  WorkoutSession? _workoutOf(WorkoutSessionState state) {
    switch (state) {
      case WorkoutPlanned(:final workout):
        return workout;
      case WorkoutInProgress(:final workout):
        return workout;
      case WorkoutResting(:final workout):
        return workout;
      case WorkoutFinished(:final workout):
        return workout;
      case WorkoutLoaded(:final workoutSession):
        return workoutSession;
      default:
        return null;
    }
  }

  Future<void> _editWorkout(
    BuildContext context,
    WorkoutSession workout,
  ) async {
    final result = await showWorkoutFormSheet(
      context,
      title: 'EDIT WORKOUT',
      confirmLabel: 'SAVE CHANGES',
      name: workout.name,
      scheduledFor:
          workout.scheduledFor ?? workout.startedAt ?? workout.createdAt,
    );
    if (result == null || !context.mounted) return;

    context.read<WorkoutSessionBloc>().add(
      WorkoutEdited(
        uid: workout.uid,
        workoutId: workout.workoutId,
        name: result.name,
        scheduledFor: result.scheduledFor,
      ),
    );
  }

  void _deleteExercise(PlannedExercise plannedExercise) {
    showAppDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Remove exercise?'),
        content: const Text(
          'This removes the exercise and its targets from the plan.',
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
                PlannedExerciseRemoved(
                  uid: widget.uid,
                  workoutId: widget.workoutId,
                  plannedExerciseId: plannedExercise.plannedExerciseId,
                ),
              );
            },
            child: const Text('Remove'),
          ),
        ],
      ),
    );
  }

  void _deleteWorkout() {
    showAppDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete workout?'),
        content: const Text(
          'This permanently deletes the workout and its sets.',
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
                WorkoutDeleted(uid: widget.uid, workoutId: widget.workoutId),
              );
              Navigator.pop(context);
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;

    return BlocProvider(
      create: (_) => sl<ExerciseLibraryBloc>(),
      child: BlocConsumer<WorkoutSessionBloc, WorkoutSessionState>(
        listener: (context, state) {
          _rememberState(state);
          if (state is WorkoutError) {
            SnackBarBuilder.showSnackBar(context, state.message, true, cs);
          }
          if (state is WorkoutPlanned) {
            _requestExerciseDetails(context, state.plannedExercises);
          }
          if (state is WorkoutInProgress) {
            _requestExerciseDetails(context, state.plannedExercises);
          }
          if (state is WorkoutFinished) {
            _requestExerciseIds(
              context,
              state.completedSets.map((set) => set.exerciseId),
            );
          }
        },
        builder: (context, state) {
          final viewState = _stateForView(state);
          final workout = _workoutOf(viewState);
          return Scaffold(
            appBar: AppBar(
              title: Text(
                workout?.name ?? 'Workout Plan',
                style: text.headlineMedium,
              ),
              actions: [
                if (workout != null)
                  IconButton(
                    onPressed: () => _editWorkout(context, workout),
                    tooltip: 'Rename or reschedule',
                    icon: const Icon(Icons.edit_outlined),
                  ),
                IconButton(
                  onPressed: _deleteWorkout,
                  tooltip: 'Delete workout',
                  icon: const Icon(Icons.delete_outline),
                ),
              ],
            ),
            body: switch (viewState) {
              WorkoutLoading() => const Center(
                child: CircularProgressIndicator(),
              ),
              WorkoutError(:final message) => _errorView(
                context,
                text,
                cs,
                message,
              ),
              WorkoutEmpty() => _emptyView(context, text, cs),
              WorkoutPlanned(:final workout, :final plannedExercises) =>
                _planView(
                  context,
                  workout: workout,
                  plannedExercises: plannedExercises,
                  completedSets: const [],
                  currentIndex: -1,
                ),
              WorkoutInProgress(
                :final workout,
                :final plannedExercises,
                :final completedSets,
                :final currentIndex,
                :final currentSetNumber,
              ) =>
                _planView(
                  context,
                  workout: workout,
                  plannedExercises: plannedExercises,
                  completedSets: completedSets,
                  currentIndex: currentIndex,
                  currentSetNumber: currentSetNumber,
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
              _ => const Center(child: CircularProgressIndicator()),
            },
          );
        },
      ),
    );
  }

  Widget _planView(
    BuildContext context, {
    required WorkoutSession workout,
    required List<PlannedExercise> plannedExercises,
    required List<SetSummary> completedSets,
    required int currentIndex,
    int currentSetNumber = 1,
  }) {
    final text = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;
    final libraryState = context.watch<ExerciseLibraryBloc>().state;
    final exerciseMap = libraryState is ExerciseDetailsLoaded
        ? libraryState.exercises
        : const <String, Exercise>{};
    final isInProgress =
        completedSets.isNotEmpty ||
        workout.status == SessionStatus.inProgress ||
        workout.status == SessionStatus.paused;

    final totalSets = plannedExercises.fold(0, (sum, e) => sum + e.targetSets);
    final volume = completedSets.fold<double>(
      0,
      (sum, s) => sum + s.load * s.reps,
    );

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
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: isInProgress ? cs.primary : cs.secondary,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      isInProgress ? 'LIVE WORKOUT' : 'SCHEDULED ROUTINE',
                      style: text.labelSmall!.copyWith(
                        color: isInProgress ? cs.primary : cs.onSurfaceVariant,
                        letterSpacing: 1.2,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      workout.scheduledFor != null && !isInProgress
                          ? DateFormatter.dateTime(workout.scheduledFor!)
                          : DateFormatter.date(
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
                        value: '${completedSets.length}/$totalSets',
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
                const SizedBox(height: 14),
                if (plannedExercises.isEmpty)
                  Text(
                    'Add exercises to build this routine before starting.',
                    style: text.bodySmall!.copyWith(color: cs.onSurfaceVariant),
                  )
                else
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton.icon(
                      onPressed: () => _startWorkout(
                        context,
                        workout: workout,
                        plannedExercises: plannedExercises,
                        completedSets: completedSets,
                        currentIndex: isInProgress ? currentIndex : 0,
                        currentSetNumber: isInProgress ? currentSetNumber : 1,
                      ),
                      icon: Icon(
                        isInProgress ? Icons.play_arrow : Icons.fitness_center,
                      ),
                      label: Text(
                        isInProgress ? 'RESUME WORKOUT' : 'START WORKOUT',
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
        if (isInProgress && completedSets.isNotEmpty) ...[
          const SizedBox(height: 16),
          const SectionTitle(title: 'COMPLETED SETS'),
          const SizedBox(height: 8),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                children: [
                  for (final set in completedSets)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              'Set ${set.order}',
                              style: text.bodyMedium,
                            ),
                          ),
                          Text(
                            '${_trim(set.load)} kg × ${set.reps}',
                            style: text.bodyMedium!.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
        const SizedBox(height: 16),
        SectionTitle(
          title: 'EXERCISE PROGRAMME',
          trailing: 'Target: ${plannedExercises.length} exercises',
        ),
        const SizedBox(height: 8),
        if (plannedExercises.isEmpty)
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  Icon(
                    Icons.fitness_center,
                    size: 36,
                    color: cs.onSurfaceVariant,
                  ),
                  const SizedBox(height: 10),
                  Text('No exercises yet', style: text.titleLarge),
                  const SizedBox(height: 4),
                  Text(
                    'Search the library and add your first movement.',
                    textAlign: TextAlign.center,
                    style: text.bodySmall!.copyWith(color: cs.onSurfaceVariant),
                  ),
                ],
              ),
            ),
          )
        else
          for (var i = 0; i < plannedExercises.length; i++)
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: PlannedExerciseCard(
                plannedExercise: plannedExercises[i],
                index: i,
                exercise: exerciseMap[plannedExercises[i].exerciseId],
                isCurrent: isInProgress && i == currentIndex,
                onCoachTap: () {
                  final exercise = exerciseMap[plannedExercises[i].exerciseId];
                  if (exercise == null) return;
                  Routing.routePush(
                    CoachModelScreen(exercise: exercise),
                    context,
                  );
                },
                onEdit: () => _editExercise(
                  context,
                  plannedExercises[i],
                  exerciseMap[plannedExercises[i].exerciseId],
                ),
                onDelete: () => _deleteExercise(plannedExercises[i]),
              ),
            ),
        const SizedBox(height: 4),
        OutlinedButton.icon(
          onPressed: () => _addExercise(context, plannedExercises),
          icon: const Icon(Icons.add),
          label: const Text('ADD EXERCISE'),
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
                const SizedBox(height: 2),
                Text(
                  DateFormatter.date(workout.startedAt ?? workout.createdAt),
                  style: text.bodySmall!.copyWith(color: cs.onSurfaceVariant),
                ),
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
                      exerciseMap[entry.value.first.exerciseId]?.nameEn ??
                          'Exercise',
                      style: text.titleLarge,
                    ),
                    const SizedBox(height: 8),
                    SetLedger(
                      sets: entry.value,
                      targetSets: entry.value.length,
                      targetReps: entry.value.first.reps,
                      targetLoad: entry.value.first.load,
                      onEdit: (set) => _editSet(
                        context,
                        workout: workout,
                        set: set,
                        exerciseName:
                            exerciseMap[set.exerciseId]?.nameEn ?? 'Exercise',
                      ),
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
            onPressed: () => Navigator.pop(context),
            child: const Text('BACK TO WORKOUTS'),
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _emptyView(BuildContext context, TextTheme text, ColorScheme cs) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.event_busy, size: 44, color: cs.onSurfaceVariant),
            const SizedBox(height: 12),
            Text('Workout not found', style: text.titleLarge),
            const SizedBox(height: 6),
            Text(
              'It may have been deleted or it never finished syncing.',
              textAlign: TextAlign.center,
              style: text.bodySmall!.copyWith(color: cs.onSurfaceVariant),
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

  Widget _errorView(
    BuildContext context,
    TextTheme text,
    ColorScheme cs,
    String message,
  ) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline, size: 44, color: cs.error),
            const SizedBox(height: 12),
            Text('Could not load workout', style: text.titleLarge),
            const SizedBox(height: 6),
            Text(
              message,
              textAlign: TextAlign.center,
              style: text.bodySmall!.copyWith(color: cs.error),
            ),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: () => _reload(context),
              child: const Text('RETRY'),
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
