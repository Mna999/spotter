part of 'food_log_bloc.dart';

abstract class FoodLogState extends Equatable {
  const FoodLogState();
  @override
  List<Object?> get props => [];
}

class FoodLogEmpty extends FoodLogState {
  final DateTime? date;
  final MacroNutrients? totals;
  const FoodLogEmpty({this.date, this.totals});
  @override
  List<Object?> get props => [date, totals];
}

class FoodLogLoading extends FoodLogState {
  const FoodLogLoading();
}

class FoodLogLoaded extends FoodLogState {
  final List<MealLog> logs;
  final MacroNutrients totals;
  final String? message;
  const FoodLogLoaded({
    this.logs = const [],
    this.totals = MacroNutrients.zero,
    this.message,
  });
  @override
  List<Object?> get props => [logs, totals, message];
}

class FoodLogError extends FoodLogState {
  final String message;
  const FoodLogError({required this.message});
  @override
  List<Object?> get props => [message];
}
