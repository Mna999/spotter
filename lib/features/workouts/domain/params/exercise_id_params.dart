import 'package:equatable/equatable.dart';

class ExerciseIdParams extends Equatable {
  final String id;

  const ExerciseIdParams({required this.id});

  @override
  List<Object?> get props => [id];
}
