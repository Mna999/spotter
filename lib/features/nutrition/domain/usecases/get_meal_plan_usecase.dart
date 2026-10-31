import 'package:dartz/dartz.dart';
import 'package:spotter/core/error/failure.dart';
import 'package:spotter/core/usecases/usecase.dart';
import 'package:spotter/features/nutrition/domain/entities/meal_plan.dart';
import 'package:spotter/features/nutrition/domain/params/meal_plan_id_params.dart';
import 'package:spotter/features/nutrition/domain/repository/meal_plan_repo.dart';

class GetMealPlanUseCase implements UseCase<MealPlan?, MealPlanIdParams> {
  MealPlanRepo mealPlanRepo;

  GetMealPlanUseCase({required this.mealPlanRepo});

  @override
  Future<Either<Failure, MealPlan?>> call(MealPlanIdParams params) async {
    return await mealPlanRepo.get(
      uid: params.uid,
      mealPlanId: params.mealPlanId,
    );
  }
}
