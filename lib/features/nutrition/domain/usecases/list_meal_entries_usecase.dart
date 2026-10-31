import 'package:dartz/dartz.dart';
import 'package:spotter/core/error/failure.dart';
import 'package:spotter/core/usecases/usecase.dart';
import 'package:spotter/features/nutrition/domain/entities/meal_entry.dart';
import 'package:spotter/features/nutrition/domain/params/meal_plan_id_params.dart';
import 'package:spotter/features/nutrition/domain/repository/meal_entry_repo.dart';

/// READ: every entry inside one meal plan, ordered by meal type then position.
class ListMealEntriesUseCase implements UseCase<List<MealEntry>, MealPlanIdParams> {
  MealEntryRepo mealEntryRepo;

  ListMealEntriesUseCase({required this.mealEntryRepo});

  @override
  Future<Either<Failure, List<MealEntry>>> call(MealPlanIdParams params) {
    return mealEntryRepo.list(
      uid: params.uid,
      mealPlanId: params.mealPlanId,
    );
  }
}
