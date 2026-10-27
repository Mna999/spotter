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
  ExerciseLibraryBloc({
    required this.getExerciseUseCase,
    required this.listExercisesUseCase,
  }) : super(ExerciseLibraryInitial()) {
    on<ExercisesRequested>((event, emit) async {
      emit(ExerciseLibraryLoading());
      final res = await listExercisesUseCase(event.exerciseFilterParams);

      res.fold(
        (failure) => emit(ExerciseLibraryError(message: failure.message)),
        (exercises) => emit(ExerciseLibraryLoaded(exercises: exercises)),
      );
    });

    on<ExerciseSelected>((event, emit) async {
      emit(ExerciseLibraryLoading());

      final res = await getExerciseUseCase(event.exerciseId);

      res.fold(
        (failure) => emit(ExerciseLibraryError(message: failure.message)),
        (exercise) => emit(ExerciseLoaded(exercise: exercise)) ,
      );
    });
  }
}
