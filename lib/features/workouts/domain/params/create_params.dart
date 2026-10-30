import 'package:equatable/equatable.dart';

class CreateParams extends Equatable {
  final String uid;

  final String name;

  final DateTime? scheduledFor;

  const CreateParams({
    required this.uid,
    this.name = 'Workout',
    this.scheduledFor,
  });

  @override
  List<Object?> get props => [uid, name, scheduledFor];
}
