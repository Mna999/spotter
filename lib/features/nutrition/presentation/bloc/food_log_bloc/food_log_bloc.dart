import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:spotter/features/nutrition/domain/entities/macro_nutrients.dart';
import 'package:spotter/features/nutrition/domain/entities/meal_log.dart';
import 'package:spotter/features/nutrition/domain/params/date_params.dart';
import 'package:spotter/features/nutrition/domain/params/log_food_params.dart';
import 'package:spotter/features/nutrition/domain/params/meal_log_id_params.dart';
import 'package:spotter/features/nutrition/domain/params/update_meal_log_params.dart';
import 'package:spotter/features/nutrition/domain/usecases/delete_meal_log_usecase.dart';
import 'package:spotter/features/nutrition/domain/usecases/get_daily_totals_usecase.dart';
import 'package:spotter/features/nutrition/domain/usecases/list_meal_logs_for_date_usecase.dart';
import 'package:spotter/features/nutrition/domain/usecases/log_food_usecase.dart';
import 'package:spotter/features/nutrition/domain/usecases/repeat_yesterday_usecase.dart';
import 'package:spotter/features/nutrition/domain/usecases/update_meal_log_usecase.dart';

part 'food_log_event.dart';
part 'food_log_state.dart';

class FoodLogBloc extends Bloc<FoodLogEvent, FoodLogState> {
  final LogFoodUseCase logFood;
  final RepeatYesterdayUseCase repeatYesterday;
  final GetDailyTotalsUseCase getDailyTotals;
  final ListMealLogsForDateUseCase listMealLogsForDate;
  final UpdateMealLogUseCase updateMealLog;
  final DeleteMealLogUseCase deleteMealLog;

  FoodLogBloc({
    required this.logFood,
    required this.repeatYesterday,
    required this.getDailyTotals,
    required this.listMealLogsForDate,
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
      final date = DateTime(
        log.loggedAt.year,
        log.loggedAt.month,
        log.loggedAt.day,
      );
      final totals = await getDailyTotals(
        DateParams(uid: event.params.uid, date: date),
      );
      totals.fold(
        (f) => emit(FoodLogError(message: f.message)),
        (value) => emit(
          FoodLogLoaded(
            logs: [log],
            totals: value,
            message: 'Food logged successfully.',
          ),
        ),
      );
    });
  }

  Future<void> _onYesterdayRepeated(
    YesterdayRepeated event,
    Emitter<FoodLogState> emit,
  ) async {
    emit(const FoodLogLoading());
    final now = DateTime.now();
    final yesterday = DateTime(
      now.year,
      now.month,
      now.day,
    ).subtract(const Duration(days: 1));
    final result = await repeatYesterday(
      DateParams(uid: event.uid, date: yesterday),
    );
    await result.fold((f) async => emit(FoodLogError(message: f.message)), (
      logs,
    ) async {
      final totals = await getDailyTotals(
        DateParams(
          uid: event.uid,
          date: DateTime(now.year, now.month, now.day),
        ),
      );
      totals.fold(
        (f) => emit(FoodLogError(message: f.message)),
        (value) => emit(
          FoodLogLoaded(
            logs: logs,
            totals: value,
            message: 'Yesterday’s meals repeated.',
          ),
        ),
      );
    });
  }

  Future<void> _onDailyTotalsRequested(
    DailyTotalsRequested event,
    Emitter<FoodLogState> emit,
  ) async {
    emit(const FoodLogLoading());
    final result = await getDailyTotals(
      DateParams(uid: event.uid, date: event.date),
    );
    result.fold(
      (f) => emit(FoodLogError(message: f.message)),
      (totals) => emit(FoodLogLoaded(totals: totals)),
    );
  }

  Future<void> _onLogsForDateRequested(
    LogsForDateRequested event,
    Emitter<FoodLogState> emit,
  ) async {
    emit(const FoodLogLoading());
    final results = await listMealLogsForDate(
      DateParams(uid: event.uid, date: event.date),
    );

    await results.fold((f) async => emit(FoodLogError(message: f.message)), (
      logs,
    ) async {
      final totals = await getDailyTotals(
        DateParams(uid: event.uid, date: event.date),
      );
      totals.fold(
        (f) => emit(FoodLogError(message: f.message)),
        (value) => emit(
          logs.isEmpty
              ? FoodLogEmpty(date: event.date, totals: value)
              : FoodLogLoaded(logs: logs, totals: value),
        ),
      );
    });
  }

  Future<void> _onMealLogUpdated(
    MealLogUpdated event,
    Emitter<FoodLogState> emit,
  ) async {
    emit(const FoodLogLoading());
    final result = await updateMealLog(event.params);
    result.fold(
      (f) => emit(FoodLogError(message: f.message)),
      (log) => add(
        DailyTotalsRequested(
          uid: event.params.uid,
          date: DateTime(
            log.loggedAt.year,
            log.loggedAt.month,
            log.loggedAt.day,
          ),
        ),
      ),
    );
  }

  Future<void> _onMealLogDeleted(
    MealLogDeleted event,
    Emitter<FoodLogState> emit,
  ) async {
    emit(const FoodLogLoading());
    final result = await deleteMealLog(
      MealLogIdParams(uid: event.uid, mealLogId: event.mealLogId),
    );
    result.fold(
      (f) => emit(FoodLogError(message: f.message)),
      (_) => add(DailyTotalsRequested(uid: event.uid, date: event.date)),
    );
  }
}
