part of 'food_log_bloc.dart';

abstract class FoodLogEvent extends Equatable {
  const FoodLogEvent();
  @override
  List<Object?> get props => [];
}

class FoodLogged extends FoodLogEvent {
  final LogFoodParams params;
  const FoodLogged(this.params);
  @override
  List<Object?> get props => [params];
}

class YesterdayRepeated extends FoodLogEvent {
  final String uid;
  const YesterdayRepeated({required this.uid});
  @override
  List<Object?> get props => [uid];
}

class DailyTotalsRequested extends FoodLogEvent {
  final String uid;
  final DateTime date;
  const DailyTotalsRequested({required this.uid, required this.date});
  @override
  List<Object?> get props => [uid, date];
}

class LogsForDateRequested extends FoodLogEvent {
  final String uid;
  final DateTime date;
  const LogsForDateRequested({required this.uid, required this.date});
  @override
  List<Object?> get props => [uid, date];
}

class MealLogUpdated extends FoodLogEvent {
  final UpdateMealLogParams params;
  const MealLogUpdated(this.params);
  @override
  List<Object?> get props => [params];
}

class MealLogDeleted extends FoodLogEvent {
  final String uid;
  final String mealLogId;
  final DateTime date;
  const MealLogDeleted({
    required this.uid,
    required this.mealLogId,
    required this.date,
  });
  @override
  List<Object?> get props => [uid, mealLogId, date];
}
