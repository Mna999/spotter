import 'package:equatable/equatable.dart';

class SetIdParams extends Equatable {
  final String uid;
  final String workoutId;
  final String setId;

  const SetIdParams({
    required this.uid,
    required this.workoutId,
    required this.setId,
  });

  @override
  List<Object?> get props => [uid, workoutId, setId];
}
