import 'package:dartz/dartz.dart';
import 'package:spotter/core/error/failure.dart';
import 'package:spotter/core/usecases/usecase.dart';
import 'package:spotter/features/nutrition/domain/entities/food_log_day.dart';
import 'package:spotter/features/nutrition/domain/params/date_params.dart';
import 'package:spotter/features/nutrition/domain/params/food_ids_params.dart';
import 'package:spotter/features/nutrition/domain/repository/meal_log_repo.dart';
import 'package:spotter/features/nutrition/domain/usecases/get_foods_by_ids_usecase.dart';

/// READ: one calendar day of logs plus the foods they reference and the
/// aggregated macros / EGP cost.
class GetFoodLogDayUseCase implements UseCase<FoodLogDay, DateParams> {
  final MealLogRepo mealLogRepo;
  final GetFoodsByIdsUseCase getFoodsByIds;

  const GetFoodLogDayUseCase({
    required this.mealLogRepo,
    required this.getFoodsByIds,
  });

  @override
  Future<Either<Failure, FoodLogDay>> call(DateParams params) async {
    final logsResult = await mealLogRepo.listForDate(
      uid: params.uid,
      date: params.date,
    );
    return logsResult.fold<Future<Either<Failure, FoodLogDay>>>(
      (failure) async => Left(failure),
      (logs) async {
        final foodsResult = await getFoodsByIds(
          FoodIdsParams(logs.map((log) => log.foodId).toSet()),
        );
        return foodsResult.fold(
          (failure) => Left<Failure, FoodLogDay>(failure),
          (foods) => Right<Failure, FoodLogDay>(
            FoodLogDay.from(date: params.date, logs: logs, foods: foods),
          ),
        );
      },
    );
  }
}
