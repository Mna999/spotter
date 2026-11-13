import 'package:dartz/dartz.dart';
import 'package:spotter/core/error/failure.dart';
import 'package:spotter/core/usecases/usecase.dart';
import 'package:spotter/features/nutrition/domain/entities/food_item.dart';
import 'package:spotter/features/nutrition/domain/entities/meal_entry.dart';
import 'package:spotter/features/nutrition/domain/entities/meal_plan_summary.dart';
import 'package:spotter/features/nutrition/domain/params/food_ids_params.dart';
import 'package:spotter/features/nutrition/domain/params/meal_plan_ids_params.dart';
import 'package:spotter/features/nutrition/domain/repository/meal_entry_repo.dart';
import 'package:spotter/features/nutrition/domain/services/nutrition_calculator.dart';
import 'package:spotter/features/nutrition/domain/usecases/get_foods_by_ids_usecase.dart';

/// READ: aggregate the entries of every listed plan into a single summary.
class GetMealPlansSummaryUseCase
    implements UseCase<MealPlanSummary, MealPlanIdsParams> {
  final MealEntryRepo mealEntryRepo;
  final GetFoodsByIdsUseCase getFoodsByIds;

  const GetMealPlansSummaryUseCase({
    required this.mealEntryRepo,
    required this.getFoodsByIds,
  });

  @override
  Future<Either<Failure, MealPlanSummary>> call(
    MealPlanIdsParams params,
  ) async {
    final ids = params.mealPlanIds
        .map((id) => id.trim())
        .where((id) => id.isNotEmpty)
        .toList();
    if (ids.isEmpty) return const Right(MealPlanSummary());

    final results = await Future.wait(
      ids.map(
        (id) => mealEntryRepo.list(uid: params.uid, mealPlanId: id),
      ),
    );

    final entries = <MealEntry>[];
    for (final result in results) {
      final value = result.fold<List<MealEntry>?>(
        (_) => null,
        (list) => list,
      );
      if (value != null) entries.addAll(value);
    }

    final foodsResult = await getFoodsByIds(
      FoodIdsParams(entries.map((entry) => entry.foodId).toSet()),
    );
    final foods = foodsResult.fold<Map<String, FoodItem>>(
      (_) => const <String, FoodItem>{},
      (value) => value,
    );

    return Right(
      MealPlanSummary(
        totals: NutritionCalculator.macrosForEntries(entries, foods),
        spentEgp: NutritionCalculator.estimatedCostForEntries(entries, foods),
        itemCount: entries.length,
      ),
    );
  }
}
