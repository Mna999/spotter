part of 'exercise_library_bloc.dart';

sealed class ExerciseLibraryEvent extends Equatable {
  const ExerciseLibraryEvent();

  @override
  List<Object> get props => [];
}

class ExercisesRequested extends ExerciseLibraryEvent {
  ExerciseFilterParams exerciseFilterParams;
  ExercisesRequested({required this.exerciseFilterParams});
  @override
  List<Object> get props => [exerciseFilterParams];
}

class ExerciseSelected extends ExerciseLibraryEvent {
  ExerciseIdParams exerciseId;

  ExerciseSelected({required this.exerciseId});
  @override
  List<Object> get props => [exerciseId];
}
