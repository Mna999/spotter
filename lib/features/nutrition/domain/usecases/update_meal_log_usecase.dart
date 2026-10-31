import 'package:dartz/dartz.dart';
import 'package:spotter/core/error/failure.dart';
import 'package:spotter/core/usecases/usecase.dart';
import 'package:spotter/features/nutrition/domain/entities/food_item.dart';
import 'package:spotter/features/nutrition/domain/entities/meal_log.dart';
import 'package:spotter/features/nutrition/domain/params/update_meal_log_params.dart';
import 'package:spotter/features/nutrition/domain/repository/food_repo.dart';
import 'package:spotter/features/nutrition/domain/repository/meal_log_repo.dart';

/// UPDATE: atomic partial update of a log. When the portion or the number
/// of servings changes, the denormalized `computedKcal` is recomputed from
/// the logged food's per-100g energy. Keys of the partial map mirror the
/// MealLog field names (`portion` as the domain object, `servingsCount`,
/// `note`, `computedKcal`) and the RepositoryImpl serializes them.
/// `updatedAt` is bumped automatically.
class UpdateMealLogUseCase implements UseCase<MealLog, UpdateMealLogParams> {
  MealLogRepo mealLogRepo;
  FoodRepo foodRepo;

  UpdateMealLogUseCase({required this.mealLogRepo, required this.foodRepo});

  @override
  Future<Either<Failure, MealLog>> call(UpdateMealLogParams params) async {
    // 1) The current log — needed to recompute kcal when the amount changed.
    final currentOrFailure = await mealLogRepo.get(
      uid: params.uid,
      mealLogId: params.mealLogId,
    );
    Failure? failure;
    MealLog? current;
    currentOrFailure.fold((f) => failure = f, (log) => current = log);
    if (failure != null || current == null) {
      return Left(failure ?? const ServerFailure());
    }

    final newPortion = params.portion ?? current!.portion;
    final newServings = params.servingsCount ?? current!.servingsCount;
    final amountChanged =
        params.portion != null || params.servingsCount != null;

    final partial = <String, dynamic>{};
    if (params.portion != null) partial['portion'] = newPortion;
    if (params.servingsCount != null) partial['servingsCount'] = newServings;
    if (params.note != null) partial['note'] = params.note;

    // 2) Recompute the kcal for the new amount.
    if (amountChanged) {
      final foodOrFailure = await foodRepo.getById(foodId: current!.foodId);
      Failure? foodFailure;
      FoodItem? food;
      foodOrFailure.fold((f) => foodFailure = f, (item) => food = item);
      if (foodFailure != null || food == null) {
        return Left(foodFailure ?? const ServerFailure());
      }
      final grams = newPortion.grams * newServings;
      partial['computedKcal'] = food!.per100g.energyKcal * grams / 100;
    }
    partial['updatedAt'] = DateTime.now();

    // 3) Persist the partial update.
    return await mealLogRepo.update(
      uid: params.uid,
      mealLogId: params.mealLogId,
      partial: partial,
    );
  }
}
