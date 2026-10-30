import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:spotter/core/error/failure.dart';
import 'package:spotter/features/workouts/domain/entities/planned_exercise.dart';
import 'package:spotter/features/workouts/domain/entities/session_status.dart';
import 'package:spotter/features/workouts/domain/entities/set_summary.dart';
import 'package:spotter/features/workouts/domain/entities/workout_session.dart';
import 'package:spotter/features/workouts/domain/params/add_planned_exercise_params.dart';
import 'package:spotter/features/workouts/domain/params/create_params.dart';
import 'package:spotter/features/workouts/domain/params/limit_params.dart';
import 'package:spotter/features/workouts/domain/params/log_set_params.dart';
import 'package:spotter/features/workouts/domain/params/planned_exercise_id_params.dart';
import 'package:spotter/features/workouts/domain/params/rest_params.dart';
import 'package:spotter/features/workouts/domain/params/set_id_params.dart';
import 'package:spotter/features/workouts/domain/params/workout_id_params.dart';
import 'package:spotter/features/workouts/domain/usecases/add_planned_exercise_usecase.dart';
import 'package:spotter/features/workouts/domain/usecases/create_workout_usecase.dart';
import 'package:spotter/features/workouts/domain/usecases/delete_planned_exercise_usecase.dart';
import 'package:spotter/features/workouts/domain/usecases/delete_set_usecase.dart';
import 'package:spotter/features/workouts/domain/usecases/delete_workout_usecase.dart';
import 'package:spotter/features/workouts/domain/usecases/finish_workout_usecase.dart';
import 'package:spotter/features/workouts/domain/usecases/get_exercise_usercase.dart';
import 'package:spotter/features/workouts/domain/usecases/get_planned_exercises_usecase.dart';
import 'package:spotter/features/workouts/domain/usecases/get_sets_for_workout_usecase.dart';
import 'package:spotter/features/workouts/domain/usecases/get_workout_usecase.dart';
import 'package:spotter/features/workouts/domain/usecases/list_exercises_usecase.dart';
import 'package:spotter/features/workouts/domain/usecases/list_recent_workouts_usecase.dart';
import 'package:spotter/features/workouts/domain/usecases/log_set_usecase.dart';
import 'package:spotter/features/workouts/domain/usecases/start_rest_timer_usecase.dart';
import 'package:spotter/features/workouts/domain/usecases/start_workout_usecase.dart';
import 'package:spotter/features/workouts/domain/usecases/update_planned_exercise_usecase.dart';
import 'package:spotter/features/workouts/domain/usecases/update_set_usecase.dart';
import 'package:spotter/features/workouts/domain/usecases/update_workout_usecase.dart';

part 'workout_session_event.dart';
part 'workout_session_state.dart';

class WorkoutSessionBloc
    extends Bloc<WorkoutSessionEvent, WorkoutSessionState> {
  AddPlannedExerciseUseCase addPlannedExerciseUseCase;
  CreateWorkoutUseCase createWorkoutUseCase;
  DeletePlannedExerciseUseCase deletePlannedExerciseUseCase;
  DeleteSetUseCase deleteSetUseCase;
  DeleteWorkoutUseCase deleteWorkoutUseCase;
  FinishWorkoutUseCase finishWorkoutUseCase;
  GetExerciseUseCase getExerciseUseCase;
  GetPlannedExercisesUseCase getPlannedExercisesUseCase;
  GetSetsForWorkoutUseCase getSetsForWorkoutUseCase;
  GetWorkoutUseCase getWorkoutUseCase;
  ListExercisesUseCase listExercisesUseCase;
  ListRecentWorkoutsUseCase listRecentWorkoutsUseCase;
  LogSetUseCase logSetUseCase;
  StartRestTimerUseCase startRestTimerUseCase;
  StartWorkoutUseCase startWorkoutUseCase;
  UpdatePlannedExerciseUseCase updatePlannedExerciseUseCase;
  UpdateSetUseCase updateSetUseCase;
  UpdateWorkoutUseCase updateWorkoutUseCase;
  StreamSubscription<Either<Failure, Duration>>? _restTimerSubscription;
  WorkoutSessionBloc({
    required this.addPlannedExerciseUseCase,
    required this.createWorkoutUseCase,
    required this.deletePlannedExerciseUseCase,
    required this.deleteSetUseCase,
    required this.deleteWorkoutUseCase,
    required this.finishWorkoutUseCase,
    required this.getExerciseUseCase,
    required this.getPlannedExercisesUseCase,
    required this.getSetsForWorkoutUseCase,
    required this.getWorkoutUseCase,
    required this.listExercisesUseCase,
    required this.listRecentWorkoutsUseCase,
    required this.logSetUseCase,
    required this.startRestTimerUseCase,
    required this.startWorkoutUseCase,
    required this.updatePlannedExerciseUseCase,
    required this.updateSetUseCase,
    required this.updateWorkoutUseCase,
  }) : super(const WorkoutInitial()) {
    on<WorkoutStarted>((event, emit) async {
      final res = await startWorkoutUseCase(event.workoutSession);
      res.fold(
        (failure) => emit(WorkoutError(message: failure.message)),
        (workoutSession) => emit(
          WorkoutInProgress(
            workout: workoutSession,
            plannedExercises: event.plannedExercises,
            completedSets: event.completedSets,
            currentIndex: event.currentIndex,
            currentSetNumber: event.currentSetNumber,
          ),
        ),
      );
    });

    on<WorkoutScheduled>((event, emit) async {
      emit(const WorkoutLoading());
      final res = await createWorkoutUseCase(
        CreateParams(
          uid: event.uid,
          name: event.name,
          scheduledFor: event.scheduledFor,
        ),
      );
      res.fold(
        (failure) => emit(WorkoutError(message: failure.message)),
        (workoutSession) => emit(WorkoutLoaded(workoutSession: workoutSession)),
      );
    });

    on<WorkoutEdited>((event, emit) async {
      final previous = state;
      final workout = _workoutOf(previous);
      if (workout == null) {
        emit(const WorkoutError(message: 'No workout is open to edit.'));
        return;
      }

      workout.name = event.name.trim().isEmpty
          ? workout.name
          : event.name.trim();
      final scheduledFor = event.scheduledFor;
      if (scheduledFor != null) {
        workout.scheduledFor = scheduledFor;
      }

      final res = await updateWorkoutUseCase(workout);
      res.fold(
        (failure) => emit(WorkoutError(message: failure.message)),
        (updated) => emit(_withWorkout(previous, updated)),
      );
    });

    on<WorkoutResumed>((event, emit) async {
      emit(const WorkoutLoading());
      final res = await startWorkoutUseCase(event.workoutSession);

      res.fold(
        (failure) => emit(WorkoutError(message: failure.message)),
        (workoutSession) => emit(
          WorkoutInProgress(
            workout: workoutSession,
            plannedExercises: event.plannedExercises,
            completedSets: event.completedSets,
            currentIndex: event.currentIndex,
            currentSetNumber: event.currentSetNumber,
          ),
        ),
      );
    });

    on<LoadWorkout>((event, emit) async {
      emit(const WorkoutLoading());

      final res = await getWorkoutUseCase(
        WorkoutIdParams(uid: event.uid, workoutId: event.workoutId),
      );

      res.fold((failure) => emit(WorkoutError(message: failure.message)), (
        workoutSession,
      ) {
        if (workoutSession == null)
          emit(const WorkoutEmpty());
        else
          emit(WorkoutLoaded(workoutSession: workoutSession));
      });
    });

    on<LoadWorkouts>((event, emit) async {
      emit(const WorkoutLoading());
      final res = await listRecentWorkoutsUseCase(LimitParams(uid: event.uid));

      res.fold(
        (failure) => emit(WorkoutError(message: failure.message)),
        (workouts) => emit(WorkoutsLoaded(workoutSessions: workouts)),
      );
    });

    on<LoadWorkoutPlan>((event, emit) async {
      emit(WorkoutLoading(workoutId: event.workoutId));

      final params = WorkoutIdParams(
        uid: event.uid,
        workoutId: event.workoutId,
      );

      final workoutRes = await getWorkoutUseCase(params);
      if (workoutRes.isLeft()) {
        emit(_failureState(workoutRes));
        return;
      }
      final workout = workoutRes.getOrElse(() => null);
      if (workout == null) {
        emit(const WorkoutEmpty());
        return;
      }

      final plannedRes = await getPlannedExercisesUseCase(params);
      if (plannedRes.isLeft()) {
        emit(_failureState(plannedRes));
        return;
      }
      final plannedExercises = plannedRes.getOrElse(() => <PlannedExercise>[])
        ..sort((a, b) => a.order.compareTo(b.order));

      final completedSets = <SetSummary>[];
      for (final planned in plannedExercises) {
        final setsRes = await getSetsForWorkoutUseCase(
          PlannedExerciseIdParams(
            uid: event.uid,
            workoutId: event.workoutId,
            plannedExerciseId: planned.plannedExerciseId,
          ),
        );
        if (setsRes.isLeft()) {
          emit(_failureState(setsRes));
          return;
        }
        completedSets.addAll(setsRes.getOrElse(() => <SetSummary>[]));
      }
      completedSets.sort((a, b) => a.completedAt.compareTo(b.completedAt));

      switch (workout.status) {
        case SessionStatus.planned:
          emit(
            WorkoutPlanned(
              workout: workout,
              plannedExercises: plannedExercises,
            ),
          );

        case SessionStatus.inProgress:
        case SessionStatus.paused:
          final (currentIndex, currentSetNumber) = _positionFromSets(
            plannedExercises,
            completedSets,
          );
          emit(
            WorkoutInProgress(
              workout: workout,
              plannedExercises: plannedExercises,
              completedSets: completedSets,
              currentIndex: currentIndex,
              currentSetNumber: currentSetNumber,
            ),
          );

        case SessionStatus.finished:
          emit(
            WorkoutFinished(
              workout: workout,
              completedSets: completedSets,
              duration: _durationOf(workout),
            ),
          );

        case SessionStatus.cancelled:
          emit(const WorkoutEmpty());
      }
    });

    on<PlannedExerciseAdded>((event, emit) async {
      final previous = state;

      emit(const WorkoutLoading());

      final res = await addPlannedExerciseUseCase(
        AddPlannedExerciseParams(
          uid: event.uid,
          workoutId: event.workoutId,
          exerciseId: event.exerciseId,
          order: event.order,
          targetSets: event.targetSets,
          targetReps: event.targetReps,
          targetLoad: event.targetLoad,
          targetTempo: event.targetTempo,
          restSec: event.restSec,
        ),
      );

      res.fold(
        (failure) => emit(WorkoutError(message: failure.message)),
        (exercise) => emit(_withAppendedPlannedExercise(exercise, previous)),
      );
    });

    on<PlannedExerciseUpdated>((event, emit) async {
      final previous = state;
      emit(const WorkoutLoading());
      final res = await updatePlannedExerciseUseCase(event.plannedExercise);

      res.fold(
        (failure) => emit(WorkoutError(message: failure.message)),
        (exercise) => emit(_withUpdatedPlannedExercise(previous, exercise)),
      );
    });

    on<PlannedExerciseRemoved>((event, emit) async {
      final previous = state;

      emit(const WorkoutLoading());

      final res = await deletePlannedExerciseUseCase(
        PlannedExerciseIdParams(
          uid: event.uid,
          workoutId: event.workoutId,
          plannedExerciseId: event.plannedExerciseId,
        ),
      );

      res.fold(
        (failure) => emit(WorkoutError(message: failure.message)),
        (_) => emit(_withoutPlannedExercise(previous, event.plannedExerciseId)),
      );
    });

    on<SetCompleted>((event, emit) async {
      final previous = state;
      switch (previous) {
        case WorkoutInProgress(
              :final workout,
              :final plannedExercises,
              :final completedSets,
              :final currentIndex,
              :final currentSetNumber,
            )
            when currentIndex < plannedExercises.length:
          final currentExercise = plannedExercises[currentIndex];

          emit(const WorkoutLoading());

          final res = await logSetUseCase(
            LogSetParams(
              workoutId: event.workoutId,
              uid: event.uid,
              exerciseId: event.exerciseId,
              plannedExerciseId: currentExercise.plannedExerciseId,
              order: event.order,
              reps: event.reps,
              load: event.load,
              timeUnderTension: event.timeUnderTension,
              restSec: event.restSec,
            ),
          );

          res.fold((failure) => emit(WorkoutError(message: failure.message)), (
            setSummary,
          ) {
            final (newIndex, newSetNumber) = _advancePosition(
              plannedExercises,
              currentIndex,
              currentSetNumber,
            );

            emit(
              WorkoutResting(
                workout: workout,
                plannedExercises: plannedExercises,
                completedSets: [...completedSets, setSummary],
                currentIndex: newIndex,
                currentSetNumber: newSetNumber,
                restRemaining: Duration(seconds: event.restSec),
                lastSet: setSummary,
              ),
            );

            _startRestCountdown(event.restSec);
          });
        default:
          throw StateError(
            'Cannot complete a set from state ${previous.runtimeType}',
          );
      }
    });

    on<SetUpdated>((event, emit) async {
      final previous = state;

      final existing = _setById(previous, event.setId);
      if (existing == null) {
        emit(
          WorkoutError(
            message:
                'Set ${event.setId} was not found in state ${previous.runtimeType}',
          ),
        );
        return;
      }

      emit(const WorkoutLoading());

      final res = await updateSetUseCase(
        existing.copyWith(
          reps: event.reps,
          load: event.load,
          timeUnderTension: event.timeUnderTension,
          restSec: event.restSec,
        ),
      );

      res.fold(
        (failure) => emit(WorkoutError(message: failure.message)),
        (setSummary) => emit(_withUpdatedSet(previous, setSummary)),
      );
    });

    on<SetDeleted>((event, emit) async {
      final previous = state;

      final existing = _setById(previous, event.setId);
      if (existing == null) {
        emit(
          WorkoutError(
            message:
                'Set ${event.setId} was not found in state ${previous.runtimeType}',
          ),
        );
        return;
      }

      emit(const WorkoutLoading());

      final res = await deleteSetUseCase(
        SetIdParams(
          uid: event.uid,
          workoutId: event.workoutId,
          plannedExerciseId: existing.plannedExerciseId,
          setId: event.setId,
        ),
      );

      res.fold((failure) => emit(WorkoutError(message: failure.message)), (_) {
        // Undoing the set that started the current rest ends the rest too.
        if (previous is WorkoutResting &&
            previous.lastSet?.setId == event.setId) {
          _restTimerSubscription?.cancel();
        }
        emit(_withoutSet(previous, event.setId));
      });
    });

    on<RestSkipped>((event, emit) {
      _restTimerSubscription?.cancel();

      final previous = state;
      switch (previous) {
        case WorkoutResting():
          emit(_afterRest(previous));
        default:
          throw StateError(
            'Cannot skip rest from state ${previous.runtimeType}',
          );
      }
    });

    on<RestTimerTicked>((event, emit) {
      final previous = state;
      switch (previous) {
        case WorkoutResting(
          :final workout,
          :final plannedExercises,
          :final completedSets,
          :final currentIndex,
          :final currentSetNumber,
          :final lastSet,
        ):
          if (event.remaining > Duration.zero) {
            emit(
              WorkoutResting(
                workout: workout,
                plannedExercises: plannedExercises,
                completedSets: completedSets,
                currentIndex: currentIndex,
                currentSetNumber: currentSetNumber,
                restRemaining: event.remaining,
                lastSet: lastSet,
              ),
            );
          } else {
            _restTimerSubscription?.cancel();
            emit(_afterRest(previous));
          }
        default:
          // Rest was left (state moved on) — let the stream drain and ignore leftover ticks
          _restTimerSubscription?.cancel();
      }
    });

    on<WorkoutFinishRequested>((event, emit) async {
      _restTimerSubscription?.cancel();

      final previous = state;
      emit(const WorkoutLoading());

      switch (previous) {
        case WorkoutInProgress(:final workout):
        case WorkoutResting(:final workout):
          final res = await finishWorkoutUseCase(workout);

          res.fold(
            (failure) => emit(WorkoutError(message: failure.message)),
            (finishedWorkout) => emit(
              WorkoutFinished(
                workout: finishedWorkout,
                completedSets: _completedSetsOf(previous),
                duration: _durationOf(finishedWorkout),
              ),
            ),
          );
        default:
          throw StateError(
            'Cannot finish a workout from state ${previous.runtimeType}',
          );
      }
    });

    on<WorkoutDeleted>((event, emit) async {
      _restTimerSubscription?.cancel();

      emit(const WorkoutLoading());

      final res = await deleteWorkoutUseCase(
        WorkoutIdParams(uid: event.uid, workoutId: event.workoutId),
      );

      res.fold(
        (failure) => emit(WorkoutError(message: failure.message)),
        (_) => emit(const WorkoutEmpty()),
      );
    });

    on<WorkoutPaused>((event, emit) {
      // Freeze the rest countdown by cancelling the timer. The remaining
      // duration stays on the WorkoutResting state so it can be resumed.
      _restTimerSubscription?.cancel();
    });

    on<WorkoutPauseResumed>((event, emit) {
      final previous = state;
      if (previous is WorkoutResting) {
        final restSec = previous.restRemaining.inSeconds;
        if (restSec > 0) _startRestCountdown(restSec);
      }
    });

    on<WorkoutCancelled>((event, emit) {
      _restTimerSubscription?.cancel();
      emit(const WorkoutInitial());
    });
  }

  @override
  Future<void> close() {
    _restTimerSubscription?.cancel();
    return super.close();
  }

  WorkoutSessionState _withAppendedPlannedExercise(
    PlannedExercise newExercise,
    WorkoutSessionState previous,
  ) {
    switch (previous) {
      case WorkoutPlanned(:final workout, :final plannedExercises):
        final updated = _insertSorted(plannedExercises, newExercise);
        return WorkoutPlanned(workout: workout, plannedExercises: updated);

      case WorkoutInProgress(
        :final workout,
        :final plannedExercises,
        :final completedSets,
        :final currentIndex,
        :final currentSetNumber,
      ):
        final updated = _insertSorted(plannedExercises, newExercise);
        return WorkoutInProgress(
          workout: workout,
          plannedExercises: updated,
          completedSets: completedSets,
          currentIndex: currentIndex,
          currentSetNumber: currentSetNumber,
        );

      case WorkoutResting(
        :final workout,
        :final plannedExercises,
        :final completedSets,
        :final currentIndex,
        :final currentSetNumber,
        :final restRemaining,
        :final lastSet,
      ):
        final updated = _insertSorted(plannedExercises, newExercise);
        return WorkoutResting(
          workout: workout,
          plannedExercises: updated,
          completedSets: completedSets,
          currentIndex: currentIndex,
          currentSetNumber: currentSetNumber,
          restRemaining: restRemaining,
          lastSet: lastSet,
        );

      default:
        throw StateError(
          'Cannot add PlannedExercise from state ${previous.runtimeType}',
        );
    }
  }

  List<PlannedExercise> _insertSorted(
    List<PlannedExercise> list,
    PlannedExercise item,
  ) {
    final out = List<PlannedExercise>.from(list);
    out.add(item);
    out.sort((a, b) => a.order.compareTo(b.order));
    return out;
  }

  WorkoutSessionState _withUpdatedPlannedExercise(
    WorkoutSessionState previous,
    PlannedExercise updated,
  ) {
    switch (previous) {
      case WorkoutPlanned(:final workout, :final plannedExercises):
        return WorkoutPlanned(
          workout: workout,
          plannedExercises: _replaceById(plannedExercises, updated),
        );

      case WorkoutInProgress(
        :final workout,
        :final plannedExercises,
        :final completedSets,
        :final currentIndex,
        :final currentSetNumber,
      ):
        return WorkoutInProgress(
          workout: workout,
          plannedExercises: _replaceById(plannedExercises, updated),
          completedSets: completedSets,
          currentIndex: currentIndex,
          currentSetNumber: currentSetNumber,
        );

      case WorkoutResting(
        :final workout,
        :final plannedExercises,
        :final completedSets,
        :final currentIndex,
        :final currentSetNumber,
        :final restRemaining,
        :final lastSet,
      ):
        return WorkoutResting(
          workout: workout,
          plannedExercises: _replaceById(plannedExercises, updated),
          completedSets: completedSets,
          currentIndex: currentIndex,
          currentSetNumber: currentSetNumber,
          restRemaining: restRemaining,
          lastSet: lastSet,
        );

      default:
        throw StateError(
          'Cannot update PlannedExercise from state ${previous.runtimeType}',
        );
    }
  }

  List<PlannedExercise> _replaceById(
    List<PlannedExercise> list,
    PlannedExercise updated,
  ) {
    return list
        .map(
          (e) => e.plannedExerciseId == updated.plannedExerciseId ? updated : e,
        )
        .toList();
  }

  WorkoutSessionState _withoutPlannedExercise(
    WorkoutSessionState previous,
    String plannedExerciseId,
  ) {
    switch (previous) {
      case WorkoutPlanned(:final workout, :final plannedExercises):
        return WorkoutPlanned(
          workout: workout,
          plannedExercises: _removeById(plannedExercises, plannedExerciseId),
        );

      case WorkoutInProgress(
        :final workout,
        :final plannedExercises,
        :final completedSets,
        :final currentIndex,
        :final currentSetNumber,
      ):
        final deletedIndex = plannedExercises.indexWhere(
          (e) => e.plannedExerciseId == plannedExerciseId,
        );
        final newList = _removeById(plannedExercises, plannedExerciseId);
        final (newIdx, newSetNum) = _recomputePosition(
          deletedIndex: deletedIndex,
          oldIndex: currentIndex,
          oldSetNum: currentSetNumber,
          newLength: newList.length,
        );
        return WorkoutInProgress(
          workout: workout,
          plannedExercises: newList,
          completedSets: completedSets,
          currentIndex: newIdx,
          currentSetNumber: newSetNum,
        );

      case WorkoutResting(
        :final workout,
        :final plannedExercises,
        :final completedSets,
        :final currentIndex,
        :final currentSetNumber,
        :final restRemaining,
        :final lastSet,
      ):
        final deletedIndex = plannedExercises.indexWhere(
          (e) => e.plannedExerciseId == plannedExerciseId,
        );
        final newList = _removeById(plannedExercises, plannedExerciseId);
        final (newIdx, newSetNum) = _recomputePosition(
          deletedIndex: deletedIndex,
          oldIndex: currentIndex,
          oldSetNum: currentSetNumber,
          newLength: newList.length,
        );
        return WorkoutResting(
          workout: workout,
          plannedExercises: newList,
          completedSets: completedSets,
          currentIndex: newIdx,
          currentSetNumber: newSetNum,
          restRemaining: restRemaining,
          lastSet: lastSet,
        );

      default:
        throw StateError(
          'Cannot remove PlannedExercise from state ${previous.runtimeType}',
        );
    }
  }

  List<PlannedExercise> _removeById(List<PlannedExercise> list, String id) {
    return list.where((e) => e.plannedExerciseId != id).toList();
  }

  (int, int) _recomputePosition({
    required int deletedIndex,
    required int oldIndex,
    required int oldSetNum,
    required int newLength,
  }) {
    if (deletedIndex < 0 || deletedIndex > oldIndex) {
      return (oldIndex, oldSetNum);
    }

    if (deletedIndex < oldIndex) {
      return (oldIndex - 1, oldSetNum);
    }

    if (newLength == 0) return (0, 1);
    final newIndex = oldIndex < newLength ? oldIndex : newLength - 1;
    return (newIndex, 1);
  }

  WorkoutSessionState _withoutSet(WorkoutSessionState previous, String setId) {
    switch (previous) {
      case WorkoutInProgress(
        :final workout,
        :final plannedExercises,
        :final completedSets,
      ):
        final newCompleted = _removeSetById(completedSets, setId);
        // Undoing a set rewinds the session to the first position that still
        // needs a set, so the removed set can be logged again.
        final (index, setNumber) = _positionFromSets(
          plannedExercises,
          newCompleted,
        );

        return WorkoutInProgress(
          workout: workout,
          plannedExercises: plannedExercises,
          completedSets: newCompleted,
          currentIndex: index,
          currentSetNumber: setNumber,
        );

      case WorkoutResting(
        :final workout,
        :final plannedExercises,
        :final completedSets,
        :final restRemaining,
        :final lastSet,
      ):
        final newCompleted = _removeSetById(completedSets, setId);
        final (index, setNumber) = _positionFromSets(
          plannedExercises,
          newCompleted,
        );

        // Undoing the set that started this rest also ends the rest, so the
        // session returns straight to logging that set again.
        if (lastSet?.setId == setId) {
          return WorkoutInProgress(
            workout: workout,
            plannedExercises: plannedExercises,
            completedSets: newCompleted,
            currentIndex: index,
            currentSetNumber: setNumber,
          );
        }

        return WorkoutResting(
          workout: workout,
          plannedExercises: plannedExercises,
          completedSets: newCompleted,
          currentIndex: index,
          currentSetNumber: setNumber,
          restRemaining: restRemaining,
          lastSet: lastSet,
        );

      case WorkoutFinished(
        :final workout,
        :final completedSets,
        :final duration,
      ):
        // Allow undoing sets from history
        return WorkoutFinished(
          workout: workout,
          completedSets: _removeSetById(completedSets, setId),
          duration: duration,
        );

      default:
        throw StateError(
          'Cannot delete a set from state ${previous.runtimeType}',
        );
    }
  }

  List<SetSummary> _replaceSetById(List<SetSummary> list, SetSummary updated) {
    return list.map((s) => s.setId == updated.setId ? updated : s).toList();
  }

  List<SetSummary> _removeSetById(List<SetSummary> list, String setId) {
    return list.where((s) => s.setId != setId).toList();
  }

  void _startRestCountdown(int durationSec) {
    _restTimerSubscription?.cancel();
    _restTimerSubscription =
        startRestTimerUseCase(RestParams(durationSec: durationSec)).listen((
          res,
        ) {
          res.fold(
            (failure) => _restTimerSubscription?.cancel(),
            (remaining) => add(RestTimerTicked(remaining: remaining)),
          );
        });
  }

  (int, int) _advancePosition(
    List<PlannedExercise> plannedExercises,
    int currentIndex,
    int currentSetNumber,
  ) {
    final current = plannedExercises[currentIndex];

    if (currentSetNumber < current.targetSets) {
      return (currentIndex, currentSetNumber + 1);
    }

    if (currentIndex + 1 < plannedExercises.length) {
      return (currentIndex + 1, 1);
    }

    return (currentIndex, currentSetNumber);
  }

  WorkoutSessionState _afterRest(WorkoutSessionState previous) {
    switch (previous) {
      case WorkoutResting(
        :final workout,
        :final plannedExercises,
        :final completedSets,
        :final currentIndex,
        :final currentSetNumber,
      ):
        return WorkoutInProgress(
          workout: workout,
          plannedExercises: plannedExercises,
          completedSets: completedSets,
          currentIndex: currentIndex,
          currentSetNumber: currentSetNumber,
        );

      default:
        throw StateError(
          'Cannot leave rest from state ${previous.runtimeType}',
        );
    }
  }

  SetSummary? _setById(WorkoutSessionState previous, String setId) {
    switch (previous) {
      case WorkoutInProgress(:final completedSets):
      case WorkoutResting(:final completedSets):
      case WorkoutFinished(:final completedSets):
        return _setByIdIn(completedSets, setId);

      default:
        return null;
    }
  }

  SetSummary? _setByIdIn(List<SetSummary> completedSets, String setId) {
    for (final set in completedSets) {
      if (set.setId == setId) return set;
    }
    return null;
  }

  WorkoutSessionState _withUpdatedSet(
    WorkoutSessionState previous,
    SetSummary updated,
  ) {
    switch (previous) {
      case WorkoutInProgress(
        :final workout,
        :final plannedExercises,
        :final completedSets,
        :final currentIndex,
        :final currentSetNumber,
      ):
        return WorkoutInProgress(
          workout: workout,
          plannedExercises: plannedExercises,
          completedSets: _replaceSetById(completedSets, updated),
          currentIndex: currentIndex,
          currentSetNumber: currentSetNumber,
        );

      case WorkoutResting(
        :final workout,
        :final plannedExercises,
        :final completedSets,
        :final currentIndex,
        :final currentSetNumber,
        :final restRemaining,
        :final lastSet,
      ):
        return WorkoutResting(
          workout: workout,
          plannedExercises: plannedExercises,
          completedSets: _replaceSetById(completedSets, updated),
          currentIndex: currentIndex,
          currentSetNumber: currentSetNumber,
          restRemaining: restRemaining,
          lastSet: lastSet?.setId == updated.setId ? updated : lastSet,
        );

      case WorkoutFinished(
        :final workout,
        :final completedSets,
        :final duration,
      ):
        return WorkoutFinished(
          workout: workout,
          completedSets: _replaceSetById(completedSets, updated),
          duration: duration,
        );

      default:
        throw StateError(
          'Cannot update a set from state ${previous.runtimeType}',
        );
    }
  }

  WorkoutSession? _workoutOf(WorkoutSessionState state) {
    switch (state) {
      case WorkoutLoaded(:final workoutSession):
        return workoutSession;
      case WorkoutPlanned(:final workout):
        return workout;
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

  WorkoutSessionState _withWorkout(
    WorkoutSessionState previous,
    WorkoutSession workout,
  ) {
    switch (previous) {
      case WorkoutLoaded():
        return WorkoutLoaded(workoutSession: workout);

      case WorkoutPlanned(:final plannedExercises):
        return WorkoutPlanned(
          workout: workout,
          plannedExercises: plannedExercises,
        );

      case WorkoutInProgress(
        :final plannedExercises,
        :final completedSets,
        :final currentIndex,
        :final currentSetNumber,
      ):
        return WorkoutInProgress(
          workout: workout,
          plannedExercises: plannedExercises,
          completedSets: completedSets,
          currentIndex: currentIndex,
          currentSetNumber: currentSetNumber,
        );

      case WorkoutResting(
        :final plannedExercises,
        :final completedSets,
        :final currentIndex,
        :final currentSetNumber,
        :final restRemaining,
        :final lastSet,
      ):
        return WorkoutResting(
          workout: workout,
          plannedExercises: plannedExercises,
          completedSets: completedSets,
          currentIndex: currentIndex,
          currentSetNumber: currentSetNumber,
          restRemaining: restRemaining,
          lastSet: lastSet,
        );

      case WorkoutFinished(:final completedSets, :final duration):
        return WorkoutFinished(
          workout: workout,
          completedSets: completedSets,
          duration: duration,
        );

      case WorkoutsLoaded(:final workoutSessions):
        return WorkoutsLoaded(
          workoutSessions: [
            for (final session in workoutSessions)
              if (session.workoutId == workout.workoutId) workout else session,
          ],
        );

      default:
        return previous;
    }
  }

  List<SetSummary> _completedSetsOf(WorkoutSessionState previous) {
    switch (previous) {
      case WorkoutInProgress(:final completedSets):
        return completedSets;

      case WorkoutResting(:final completedSets):
        return completedSets;

      default:
        return [];
    }
  }

  Duration _durationOf(WorkoutSession workout) {
    final startedAt = workout.startedAt;
    final endedAt = workout.endedAt;
    if (startedAt == null || endedAt == null) return Duration.zero;
    return endedAt.difference(startedAt);
  }

  WorkoutError _failureState(Either<Failure, dynamic> result) {
    final message = result.fold(
      (failure) => failure.message,
      (_) => 'Unexpected failure occurred',
    );
    return WorkoutError(message: message);
  }

  (int, int) _positionFromSets(
    List<PlannedExercise> plannedExercises,
    List<SetSummary> completedSets,
  ) {
    if (plannedExercises.isEmpty) return (0, 1);

    for (var i = 0; i < plannedExercises.length; i++) {
      final planned = plannedExercises[i];
      final done = completedSets
          .where((s) => s.plannedExerciseId == planned.plannedExerciseId)
          .length;
      if (done < planned.targetSets) return (i, done + 1);
    }

    final last = plannedExercises.length - 1;
    return (last, plannedExercises[last].targetSets);
  }
}
