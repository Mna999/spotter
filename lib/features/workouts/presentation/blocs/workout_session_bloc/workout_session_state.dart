part of 'workout_session_bloc.dart';

sealed class WorkoutSessionState extends Equatable {
  const WorkoutSessionState();

  @override
  List<Object?> get props => [];
}

final class WorkoutInitial extends WorkoutSessionState {
  const WorkoutInitial();
}

final class WorkoutEmpty extends WorkoutSessionState {
  const WorkoutEmpty();
}

final class WorkoutPlanned extends WorkoutSessionState {
  final WorkoutSession workout;
  final List<PlannedExercise> plannedExercises;

  const WorkoutPlanned({required this.workout, required this.plannedExercises});

  @override
  List<Object> get props => [workout, plannedExercises];
}

final class WorkoutLoading extends WorkoutSessionState {
  final String? workoutId;

  const WorkoutLoading({this.workoutId});

  @override
  List<Object> get props => [workoutId ?? ''];
}

final class WorkoutLoaded extends WorkoutSessionState {
  final WorkoutSession workoutSession;
  const WorkoutLoaded({required this.workoutSession});
  @override
  List<Object> get props => [workoutSession];
}

final class WorkoutsLoaded extends WorkoutSessionState {
  final List<WorkoutSession> workoutSessions;
  const WorkoutsLoaded({required this.workoutSessions});
  @override
  List<Object> get props => [workoutSessions];
}

final class WorkoutInProgress extends WorkoutSessionState {
  final WorkoutSession workout;
  final List<PlannedExercise> plannedExercises;
  final List<SetSummary> completedSets;
  final int currentIndex;
  final int currentSetNumber;

  const WorkoutInProgress({
    required this.workout,
    required this.plannedExercises,
    required this.completedSets,
    required this.currentIndex,
    required this.currentSetNumber,
  });

  PlannedExercise? get currentExercise =>
      plannedExercises.isNotEmpty && currentIndex < plannedExercises.length
      ? plannedExercises[currentIndex]
      : null;

  int get totalSetsTarget =>
      plannedExercises.fold(0, (sum, e) => sum + e.targetSets);

  @override
  List<Object> get props => [
    workout,
    plannedExercises,
    completedSets,
    currentIndex,
    currentSetNumber,
  ];
}

final class WorkoutResting extends WorkoutSessionState {
  final WorkoutSession workout;
  final List<PlannedExercise> plannedExercises;
  final List<SetSummary> completedSets;
  final int currentIndex;
  final int currentSetNumber;
  final Duration restRemaining;
  final SetSummary? lastSet;

  const WorkoutResting({
    required this.workout,
    required this.plannedExercises,
    required this.completedSets,
    required this.currentIndex,
    required this.currentSetNumber,
    required this.restRemaining,
    this.lastSet,
  });

  @override
  List<Object?> get props => [
    workout,
    plannedExercises,
    completedSets,
    currentIndex,
    currentSetNumber,
    restRemaining,
    lastSet,
  ];
}

final class WorkoutFinished extends WorkoutSessionState {
  final WorkoutSession workout;
  final List<SetSummary> completedSets;
  final Duration duration;

  const WorkoutFinished({
    required this.workout,
    required this.completedSets,
    required this.duration,
  });

  int get totalSets => completedSets.length;
  int get totalReps => completedSets.fold(0, (s, e) => s + e.reps);

  @override
  List<Object> get props => [workout, completedSets, duration];
}

final class WorkoutError extends WorkoutSessionState {
  final String message;
  final String? workoutId;

  const WorkoutError({required this.message, this.workoutId});

  @override
  List<Object> get props => [message, workoutId ?? ''];
}
