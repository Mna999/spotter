part of 'food_log_bloc.dart';

abstract class FoodLogState extends Equatable {
  const FoodLogState();
  @override
  List<Object?> get props => [];
}

class FoodLogEmpty extends FoodLogState {
  /// Null while the first day is still being requested.
  final FoodLogDay? day;
  const FoodLogEmpty({this.day});

  DateTime? get date => day?.date;
  @override
  List<Object?> get props => [day];
}

class FoodLogLoading extends FoodLogState {
  const FoodLogLoading();
}

class FoodLogLoaded extends FoodLogState {
  final FoodLogDay day;

  /// The log created by the most recent "log food" action, when there is one.
  final MealLog? latestLog;
  final String? message;

  const FoodLogLoaded({required this.day, this.latestLog, this.message});

  List<MealLog> get logs => day.logs;
  MacroNutrients get totals => day.totals;

  @override
  List<Object?> get props => [day, latestLog, message];
}

class FoodLogError extends FoodLogState {
  final String message;
  const FoodLogError({required this.message});
  @override
  List<Object?> get props => [message];
}
