import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:spotter/features/workouts/domain/entities/exercise.dart';
import 'package:spotter/features/workouts/domain/params/exercise_filter_params.dart';
import 'package:spotter/features/workouts/domain/params/exercise_id_params.dart';
import 'package:spotter/features/workouts/domain/usecases/get_exercise_usercase.dart';
import 'package:spotter/features/workouts/domain/usecases/list_exercises_usecase.dart';

part 'exercise_library_event.dart';
part 'exercise_library_state.dart';

class ExerciseLibraryBloc
    extends Bloc<ExerciseLibraryEvent, ExerciseLibraryState> {
  ListExercisesUseCase listExercisesUseCase;
  GetExerciseUseCase getExerciseUseCase;

  /// Guards against a slow, older search landing after a newer one.
  int _searchRequestId = 0;

  ExerciseLibraryBloc({
    required this.getExerciseUseCase,
    required this.listExercisesUseCase,
  }) : super(ExerciseLibraryInitial()) {
    on<ExercisesRequested>((event, emit) async {
      final requestId = ++_searchRequestId;
      emit(ExerciseLibraryLoading());
      final res = await listExercisesUseCase(event.exerciseFilterParams);
      // Ignore stale responses and results for a screen that has been closed.
      if (isClosed || requestId != _searchRequestId) return;

      res.fold(
        (failure) => emit(ExerciseLibraryError(message: failure.message)),
        (exercises) => emit(ExerciseLibraryLoaded(exercises: exercises)),
      );
    });

    on<ExerciseSelected>((event, emit) async {
      emit(ExerciseLibraryLoading());

      final res = await getExerciseUseCase(event.exerciseId);
      if (isClosed) return;

      res.fold(
        (failure) => emit(ExerciseLibraryError(message: failure.message)),
        (exercise) => emit(ExerciseLoaded(exercise: exercise)),
      );
    });

    on<ExerciseDetailsRequested>((event, emit) async {
      // Keep any names that are already resolved, and don't emit a loading
      // state: screens render whatever map they have so far, so flashing
      // loading would blank out exercise names on the plan screen.
      final current = state;
      final exercises = <String, Exercise>{
        if (current is ExerciseDetailsLoaded) ...current.exercises,
      };

      for (final exerciseId in event.exerciseIds) {
        if (exercises.containsKey(exerciseId)) continue;
        final res = await getExerciseUseCase(ExerciseIdParams(id: exerciseId));
        final exercise = res.getOrElse(() => null);
        if (exercise != null) exercises[exerciseId] = exercise;
      }

      if (isClosed) return;
      emit(ExerciseDetailsLoaded(exercises: exercises));
    });
  }
}
