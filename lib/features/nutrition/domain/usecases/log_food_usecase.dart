import 'package:dartz/dartz.dart';
import 'package:spotter/core/error/failure.dart';
import 'package:spotter/core/usecases/usecase.dart';
import 'package:spotter/features/nutrition/domain/entities/food_item.dart';
import 'package:spotter/features/nutrition/domain/entities/meal_log.dart';
import 'package:spotter/features/nutrition/domain/params/log_food_params.dart';
import 'package:spotter/features/nutrition/domain/repository/food_repo.dart';
import 'package:spotter/features/nutrition/domain/repository/meal_log_repo.dart';

/// CREATE: log a food into users/{uid}/mealLogs. The denormalized
/// `computedKcal` is calculated here from the food's per-100g energy and
/// the consumed amount (portion grams x servings) so the logs stay fast
/// to query without joining the foods collection.
class LogFoodUseCase implements UseCase<MealLog, LogFoodParams> {
  FoodRepo foodRepo;
  MealLogRepo mealLogRepo;

  LogFoodUseCase({required this.foodRepo, required this.mealLogRepo});

  @override
  Future<Either<Failure, MealLog>> call(LogFoodParams params) async {
    // 1) Fetch the food to compute the kcal of the consumed amount.
    final foodOrFailure = await foodRepo.getById(foodId: params.foodId);
    Failure? failure;
    FoodItem? food;
    foodOrFailure.fold((f) => failure = f, (item) => food = item);
    if (failure != null || food == null) {
      return Left(failure ?? const ServerFailure());
    }

    // 2) kcal relative to the per-100g values.
    final grams = params.portion.grams * params.servingsCount;
    final computedKcal = food!.per100g.energyKcal * grams / 100;

    // 3) Persist the log.
    final now = DateTime.now();
    final log = MealLog(
      mealLogId: '', // assigned by Firestore on save
      uid: params.uid,
      foodId: params.foodId,
      mealType: params.mealType,
      portion: params.portion,
      servingsCount: params.servingsCount,
      computedKcal: computedKcal,
      loggedAt: params.loggetAt,
      note: params.note,
      schemaVersion: 1,
      createdAt: now,
      updatedAt: now,
    );
    return await mealLogRepo.save(uid: params.uid, log: log);
  }
}
