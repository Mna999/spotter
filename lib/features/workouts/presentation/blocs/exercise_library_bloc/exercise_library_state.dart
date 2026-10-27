part of 'exercise_library_bloc.dart';

sealed class ExerciseLibraryState extends Equatable {
  const ExerciseLibraryState();

  @override
  List<Object?> get props => [];
}

final class ExerciseLibraryInitial extends ExerciseLibraryState {}

final class ExerciseLibraryLoading extends ExerciseLibraryState {}

final class ExerciseLibraryLoaded extends ExerciseLibraryState {
  List<Exercise> exercises;
  ExerciseLibraryLoaded({required this.exercises});
  @override
  List<Object> get props => [exercises];
}

final class ExerciseLoaded extends ExerciseLibraryState {
  final Exercise? exercise;

  const ExerciseLoaded({this.exercise});

  @override
  List<Object?> get props => [exercise];
}

final class ExerciseLibraryError extends ExerciseLibraryState {
  String message;

  ExerciseLibraryError({required this.message});
  @override
  List<Object> get props => [message];
}
