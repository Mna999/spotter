import 'package:dartz/dartz.dart';
import 'package:spotter/core/error/failure.dart';
import 'package:spotter/core/usecases/usecase.dart';
import 'package:spotter/features/nutrition/domain/entities/meal_plan_entries.dart';
import 'package:spotter/features/nutrition/domain/params/food_ids_params.dart';
import 'package:spotter/features/nutrition/domain/params/list_meal_entries_params.dart';
import 'package:spotter/features/nutrition/domain/repository/meal_entry_repo.dart';
import 'package:spotter/features/nutrition/domain/usecases/get_foods_by_ids_usecase.dart';

/// READ: the entries of one meal plan with their foods and aggregates.
class GetMealPlanEntriesUseCase
    implements UseCase<MealPlanEntries, ListMealEntriesParams> {
  final MealEntryRepo mealEntryRepo;
  final GetFoodsByIdsUseCase getFoodsByIds;

  const GetMealPlanEntriesUseCase({
    required this.mealEntryRepo,
    required this.getFoodsByIds,
  });

  @override
  Future<Either<Failure, MealPlanEntries>> call(
    ListMealEntriesParams params,
  ) async {
    final entriesResult = await mealEntryRepo.list(
      uid: params.uid,
      mealPlanId: params.mealPlanId,
    );
    return entriesResult.fold<Future<Either<Failure, MealPlanEntries>>>(
      (failure) async => Left(failure),
      (entries) async {
        final foodsResult = await getFoodsByIds(
          FoodIdsParams(entries.map((entry) => entry.foodId).toSet()),
        );
        return foodsResult.fold(
          (failure) => Left<Failure, MealPlanEntries>(failure),
          (foods) => Right<Failure, MealPlanEntries>(
            MealPlanEntries.from(entries: entries, foods: foods),
          ),
        );
      },
    );
  }
}
