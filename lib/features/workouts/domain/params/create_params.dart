import 'package:equatable/equatable.dart';

class CreateParams extends Equatable {
  final String uid;

  final DateTime? scheduledFor;

  const CreateParams({
    required this.uid,
    this.scheduledFor,
  });

  @override
  List<Object?> get props => [uid, scheduledFor];
}
