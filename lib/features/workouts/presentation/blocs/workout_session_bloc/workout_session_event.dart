part of 'workout_session_bloc.dart';

sealed class WorkoutSessionEvent extends Equatable {
  const WorkoutSessionEvent();

  @override
  List<Object?> get props => [];
}

final class WorkoutStarted extends WorkoutSessionEvent {
  final WorkoutSession workoutSession;
  final List<PlannedExercise> plannedExercises;
  final List<SetSummary> completedSets;
  final int currentIndex;
  final int currentSetNumber;

  const WorkoutStarted({
    required this.workoutSession,
    required this.plannedExercises,
    required this.completedSets,
    required this.currentIndex,
    required this.currentSetNumber,
  });

  @override
  List<Object> get props => [workoutSession, plannedExercises];
}

final class WorkoutScheduled extends WorkoutSessionEvent {
  final String uid;
  final String name;
  final DateTime scheduledFor;

  const WorkoutScheduled({
    required this.uid,
    this.name = 'Workout',
    required this.scheduledFor,
  });

  @override
  List<Object> get props => [uid, name, scheduledFor];
}

final class WorkoutEdited extends WorkoutSessionEvent {
  final String uid;
  final String workoutId;
  final String name;
  final DateTime? scheduledFor;

  const WorkoutEdited({
    required this.uid,
    required this.workoutId,
    required this.name,
    this.scheduledFor,
  });

  @override
  List<Object?> get props => [uid, workoutId, name, scheduledFor];
}

final class WorkoutResumed extends WorkoutSessionEvent {
  final WorkoutSession workoutSession;
  final List<PlannedExercise> plannedExercises;
  final List<SetSummary> completedSets;
  final int currentIndex;
  final int currentSetNumber;

  const WorkoutResumed({
    required this.workoutSession,
    required this.plannedExercises,
    required this.completedSets,
    required this.currentIndex,
    required this.currentSetNumber,
  });

  @override
  List<Object> get props => [
    plannedExercises,
    completedSets,
    currentIndex,
    currentSetNumber,
    workoutSession,
  ];
}

final class LoadWorkout extends WorkoutSessionEvent {
  String workoutId;
  String uid;

  LoadWorkout({required this.workoutId, required this.uid});
  @override
  List<Object> get props => [uid, workoutId];
}

final class LoadWorkouts extends WorkoutSessionEvent {
  String uid;

  LoadWorkouts({required this.uid});
  @override
  List<Object> get props => [uid];
}

final class LoadWorkoutPlan extends WorkoutSessionEvent {
  final String uid;
  final String workoutId;

  const LoadWorkoutPlan({required this.uid, required this.workoutId});

  @override
  List<Object> get props => [uid, workoutId];
}

final class PlannedExerciseAdded extends WorkoutSessionEvent {
  final String uid;
  final String workoutId;
  final String exerciseId;
  final int order;
  final int targetSets;
  final int targetReps;
  final double targetLoad;
  final String targetTempo;
  final int restSec;

  const PlannedExerciseAdded({
    required this.uid,
    required this.workoutId,
    required this.exerciseId,
    required this.order,
    required this.targetSets,
    required this.targetReps,
    required this.targetLoad,
    required this.targetTempo,
    required this.restSec,
  });

  @override
  List<Object> get props => [
    uid,
    workoutId,
    exerciseId,
    order,
    targetSets,
    targetReps,
    targetLoad,
    targetTempo,
    restSec,
  ];
}

final class PlannedExerciseUpdated extends WorkoutSessionEvent {
  final PlannedExercise plannedExercise;

  const PlannedExerciseUpdated({required this.plannedExercise});

  @override
  List<Object?> get props => [plannedExercise];
}

final class PlannedExerciseRemoved extends WorkoutSessionEvent {
  final String uid;
  final String workoutId;
  final String plannedExerciseId;

  const PlannedExerciseRemoved({
    required this.uid,
    required this.workoutId,
    required this.plannedExerciseId,
  });

  @override
  List<Object> get props => [uid, workoutId, plannedExerciseId];
}

final class SetCompleted extends WorkoutSessionEvent {
  final String workoutId;
  final String uid;
  final String exerciseId;
  final int order;
  final int reps;
  final double load;
  final int timeUnderTension;
  final int restSec;

  const SetCompleted({
    required this.workoutId,
    required this.uid,
    required this.exerciseId,
    required this.order,
    required this.reps,
    required this.load,
    required this.timeUnderTension,
    required this.restSec,
  });

  @override
  List<Object> get props => [
    workoutId,
    uid,
    exerciseId,
    order,
    reps,
    load,
    timeUnderTension,
    restSec,
  ];
}

final class SetUpdated extends WorkoutSessionEvent {
  final String uid;
  final String workoutId;
  final String setId;
  final int? reps;
  final double? load;
  final int? timeUnderTension;
  final int? restSec;

  const SetUpdated({
    required this.uid,
    required this.workoutId,
    required this.setId,
    this.reps,
    this.load,
    this.timeUnderTension,
    this.restSec,
  });

  @override
  List<Object?> get props => [
    uid,
    workoutId,
    setId,
    reps,
    load,
    timeUnderTension,
    restSec,
  ];
}

final class SetDeleted extends WorkoutSessionEvent {
  final String uid;
  final String workoutId;
  final String setId;

  const SetDeleted({
    required this.uid,
    required this.workoutId,
    required this.setId,
  });

  @override
  List<Object> get props => [uid, workoutId, setId];
}

final class RestSkipped extends WorkoutSessionEvent {
  const RestSkipped();
}

final class RestTimerTicked extends WorkoutSessionEvent {
  final Duration remaining;

  const RestTimerTicked({required this.remaining});

  @override
  List<Object?> get props => [remaining];
}

final class WorkoutFinishRequested extends WorkoutSessionEvent {
  const WorkoutFinishRequested();
}

final class WorkoutDeleted extends WorkoutSessionEvent {
  final String uid;
  final String workoutId;

  const WorkoutDeleted({required this.uid, required this.workoutId});

  @override
  List<Object> get props => [uid, workoutId];
}

final class WorkoutPaused extends WorkoutSessionEvent {
  const WorkoutPaused();
}

final class WorkoutPauseResumed extends WorkoutSessionEvent {
  const WorkoutPauseResumed();
}

final class WorkoutCancelled extends WorkoutSessionEvent {
  final String? reason;

  const WorkoutCancelled({this.reason});

  @override
  List<Object?> get props => [reason];
}
