import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:spotter/features/nutrition/domain/entities/food_log_day.dart';
import 'package:spotter/features/nutrition/domain/entities/macro_nutrients.dart';
import 'package:spotter/features/nutrition/domain/entities/meal_log.dart';
import 'package:spotter/features/nutrition/domain/params/date_params.dart';
import 'package:spotter/features/nutrition/domain/params/log_food_params.dart';
import 'package:spotter/features/nutrition/domain/params/meal_log_id_params.dart';
import 'package:spotter/features/nutrition/domain/params/update_meal_log_params.dart';
import 'package:spotter/features/nutrition/domain/usecases/delete_meal_log_usecase.dart';
import 'package:spotter/features/nutrition/domain/usecases/get_food_log_day_usecase.dart';
import 'package:spotter/features/nutrition/domain/usecases/log_food_usecase.dart';
import 'package:spotter/features/nutrition/domain/usecases/repeat_yesterday_usecase.dart';
import 'package:spotter/features/nutrition/domain/usecases/update_meal_log_usecase.dart';

part 'food_log_event.dart';
part 'food_log_state.dart';

class FoodLogBloc extends Bloc<FoodLogEvent, FoodLogState> {
  final LogFoodUseCase logFood;
  final RepeatYesterdayUseCase repeatYesterday;
  final GetFoodLogDayUseCase getFoodLogDay;
  final UpdateMealLogUseCase updateMealLog;
  final DeleteMealLogUseCase deleteMealLog;

  FoodLogBloc({
    required this.logFood,
    required this.repeatYesterday,
    required this.getFoodLogDay,
    required this.updateMealLog,
    required this.deleteMealLog,
  }) : super(const FoodLogEmpty()) {
    on<FoodLogged>(_onFoodLogged);
    on<YesterdayRepeated>(_onYesterdayRepeated);
    on<DailyTotalsRequested>(_onDailyTotalsRequested);
    on<LogsForDateRequested>(_onLogsForDateRequested);
    on<MealLogUpdated>(_onMealLogUpdated);
    on<MealLogDeleted>(_onMealLogDeleted);
  }

  Future<void> _onFoodLogged(
    FoodLogged event,
    Emitter<FoodLogState> emit,
  ) async {
    emit(const FoodLogLoading());
    final result = await logFood(event.params);
    await result.fold((f) async => emit(FoodLogError(message: f.message)), (
      log,
    ) async {
      await _emitDay(
        uid: event.params.uid,
        date: DateTime(log.loggedAt.year, log.loggedAt.month, log.loggedAt.day),
        emit: emit,
        latestLog: log,
        message: 'Food logged successfully.',
      );
    });
  }

  Future<void> _onYesterdayRepeated(
    YesterdayRepeated event,
    Emitter<FoodLogState> emit,
  ) async {
    emit(const FoodLogLoading());
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final result = await repeatYesterday(
      DateParams(uid: event.uid, date: yesterday),
    );
    await result.fold((f) async => emit(FoodLogError(message: f.message)), (
      _,
    ) async {
      await _emitDay(
        uid: event.uid,
        date: today,
        emit: emit,
        message: 'Yesterday’s meals repeated.',
      );
    });
  }

  Future<void> _onDailyTotalsRequested(
    DailyTotalsRequested event,
    Emitter<FoodLogState> emit,
  ) async {
    emit(const FoodLogLoading());
    await _emitDay(uid: event.uid, date: event.date, emit: emit);
  }

  Future<void> _onLogsForDateRequested(
    LogsForDateRequested event,
    Emitter<FoodLogState> emit,
  ) async {
    emit(const FoodLogLoading());
    await _emitDay(uid: event.uid, date: event.date, emit: emit);
  }

  Future<void> _onMealLogUpdated(
    MealLogUpdated event,
    Emitter<FoodLogState> emit,
  ) async {
    emit(const FoodLogLoading());
    final result = await updateMealLog(event.params);
    await result.fold((f) async => emit(FoodLogError(message: f.message)), (
      log,
    ) async {
      await _emitDay(
        uid: event.params.uid,
        date: DateTime(log.loggedAt.year, log.loggedAt.month, log.loggedAt.day),
        emit: emit,
      );
    });
  }

  Future<void> _onMealLogDeleted(
    MealLogDeleted event,
    Emitter<FoodLogState> emit,
  ) async {
    emit(const FoodLogLoading());
    final result = await deleteMealLog(
      MealLogIdParams(uid: event.uid, mealLogId: event.mealLogId),
    );
    await result.fold(
      (f) async => emit(FoodLogError(message: f.message)),
      (_) async => _emitDay(uid: event.uid, date: event.date, emit: emit),
    );
  }

  /// Loads a whole day and emits the matching state. The full day is emitted
  /// so every listener gets the logs, foods and totals together.
  Future<void> _emitDay({
    required String uid,
    required DateTime date,
    required Emitter<FoodLogState> emit,
    MealLog? latestLog,
    String? message,
  }) async {
    final result = await getFoodLogDay(DateParams(uid: uid, date: date));
    result.fold(
      (failure) => emit(FoodLogError(message: failure.message)),
      (day) => emit(
        day.isEmpty && message == null
            ? FoodLogEmpty(day: day)
            : FoodLogLoaded(
                day: day,
                latestLog: latestLog,
                message: message,
              ),
      ),
    );
  }
}
