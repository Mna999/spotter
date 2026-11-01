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

    // 3) Refuse to log the same food twice for the same meal on the same day.
    // The existing entry should be edited instead, so the diary never shows
    // accidental duplicates (double taps, repeated taps on a plan entry).
    var duplicate = false;
    final day = DateTime(
      params.loggetAt.year,
      params.loggetAt.month,
      params.loggetAt.day,
    );
    final existing = await mealLogRepo.listForDate(uid: params.uid, date: day);
    existing.fold((_) {}, (logs) {
      duplicate = logs.any(
        (log) =>
            log.foodId == params.foodId &&
            log.mealType == params.mealType &&
            (log.portion.grams - params.portion.grams).abs() < 0.01 &&
            (log.servingsCount - params.servingsCount).abs() < 0.01,
      );
    });
    if (duplicate) {
      return const Left(
        ServerFailure(
          message:
              'This food is already logged for that meal today. Edit the '
              'existing entry if you need a different amount.',
        ),
      );
    }

    // 4) Persist the log.
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
      sourceMealEntryId: params.sourceMealEntryId,
      schemaVersion: 1,
      createdAt: now,
      updatedAt: now,
    );
    return await mealLogRepo.save(uid: params.uid, log: log);
  }
}
