import 'package:equatable/equatable.dart';

class DateParams extends Equatable {
  final String uid;
  final DateTime date;

  const DateParams({required this.uid, required this.date});

  @override
  List<Object?> get props => [uid, date];
}
