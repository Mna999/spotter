import 'package:dartz/dartz.dart';
import 'package:spotter/core/error/failure.dart';
import 'package:spotter/core/usecases/usecase.dart';
import 'package:spotter/features/nutrition/domain/params/meal_plan_id_params.dart';
import 'package:spotter/features/nutrition/domain/repository/meal_plan_repo.dart';

/// DELETE: remove a plan by id. Cascading the entries subcollection
/// (users/{uid}/mealPlans/{id}/entries) is the RepositoryImpl's job.
class DeleteMealPlanUseCase implements UseCase<Unit, MealPlanIdParams> {
  MealPlanRepo mealPlanRepo;

  DeleteMealPlanUseCase({required this.mealPlanRepo});

  @override
  Future<Either<Failure, Unit>> call(MealPlanIdParams params) async {
    return await mealPlanRepo.delete(
      uid: params.uid,
      mealPlanId: params.mealPlanId,
    );
  }
}
