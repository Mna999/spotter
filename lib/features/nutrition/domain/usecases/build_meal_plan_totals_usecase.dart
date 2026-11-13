import 'package:dartz/dartz.dart';
import 'package:spotter/core/error/failure.dart';
import 'package:spotter/core/usecases/usecase.dart';
import 'package:spotter/features/nutrition/domain/entities/food_item.dart';
import 'package:spotter/features/nutrition/domain/entities/meal_entry.dart';
import 'package:spotter/features/nutrition/domain/entities/meal_plan.dart';
import 'package:spotter/features/nutrition/domain/params/food_ids_params.dart';
import 'package:spotter/features/nutrition/domain/params/meal_plan_totals_params.dart';
import 'package:spotter/features/nutrition/domain/repository/meal_entry_repo.dart';
import 'package:spotter/features/nutrition/domain/repository/meal_plan_repo.dart';
import 'package:spotter/features/nutrition/domain/services/nutrition_calculator.dart';
import 'package:spotter/features/nutrition/domain/usecases/get_foods_by_ids_usecase.dart';

/// UPDATE: recompute a plan's stored kcal and EGP cost from its entries and
/// persist them so the plan list shows fresh numbers without a manual save.
class BuildMealPlanTotalsUseCase
    implements UseCase<MealPlan, MealPlanTotalsParams> {
  final MealEntryRepo mealEntryRepo;
  final MealPlanRepo mealPlanRepo;
  final GetFoodsByIdsUseCase getFoodsByIds;

  const BuildMealPlanTotalsUseCase({
    required this.mealEntryRepo,
    required this.mealPlanRepo,
    required this.getFoodsByIds,
  });

  @override
  Future<Either<Failure, MealPlan>> call(MealPlanTotalsParams params) async {
    final plan = params.plan;
    final planId = plan.mealPlanId.trim();
    if (planId.isEmpty) return Right(plan);

    final entriesResult = await mealEntryRepo.list(
      uid: params.uid,
      mealPlanId: planId,
    );
    final entries = entriesResult.fold<List<MealEntry>>(
      (_) => const <MealEntry>[],
      (value) => value,
    );
    final foods = entries.isEmpty
        ? const <String, FoodItem>{}
        : await _foodsFor(entries);

    final updated = plan.copyWith(
      totalKcal: NutritionCalculator.macrosForEntries(entries, foods).energyKcal,
      costEgp: NutritionCalculator.estimatedCostForEntries(entries, foods),
    );

    final updateResult = await mealPlanRepo.update(
      uid: params.uid,
      mealPlanId: planId,
      partial: <String, dynamic>{
        'totalKcal': updated.totalKcal,
        'costEgp': updated.costEgp,
      },
    );
    return updateResult.fold((_) => Right(updated), (saved) => Right(saved));
  }

  Future<Map<String, FoodItem>> _foodsFor(List<MealEntry> entries) async {
    final result = await getFoodsByIds(
      FoodIdsParams(entries.map((entry) => entry.foodId).toSet()),
    );
    return result.fold<Map<String, FoodItem>>(
      (_) => const <String, FoodItem>{},
      (value) => value,
    );
  }
}
