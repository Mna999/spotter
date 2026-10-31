import 'package:dartz/dartz.dart';
import 'package:spotter/core/error/failure.dart';
import 'package:spotter/core/usecases/usecase.dart';
import 'package:spotter/features/nutrition/domain/params/meal_entry_id_params.dart';
import 'package:spotter/features/nutrition/domain/repository/meal_entry_repo.dart';

/// DELETE: remove one entry by id from its meal plan.
class DeleteMealEntryUseCase implements UseCase<Unit, MealEntryIdParams> {
  MealEntryRepo mealEntryRepo;

  DeleteMealEntryUseCase({required this.mealEntryRepo});

  @override
  Future<Either<Failure, Unit>> call(MealEntryIdParams params) {
    return mealEntryRepo.delete(
      uid: params.uid,
      mealPlanId: params.mealPlanId,
      mealEntryId: params.mealEntryId,
    );
  }
}
