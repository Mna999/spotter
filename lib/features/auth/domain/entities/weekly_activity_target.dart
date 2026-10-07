import 'package:equatable/equatable.dart';

class WeeklyActivityTarget extends Equatable {
  int minutes;
  int strengthDays;

  WeeklyActivityTarget({required this.minutes, required this.strengthDays});

  @override
  // TODO: implement props
  List<Object?> get props => [minutes, strengthDays];
}
