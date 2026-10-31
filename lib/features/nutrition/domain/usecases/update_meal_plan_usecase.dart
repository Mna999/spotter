import 'package:dartz/dartz.dart';
import 'package:spotter/core/error/failure.dart';
import 'package:spotter/core/usecases/usecase.dart';
import 'package:spotter/features/nutrition/domain/entities/meal_plan.dart';
import 'package:spotter/features/nutrition/domain/params/update_meal_plan_params.dart';
import 'package:spotter/features/nutrition/domain/repository/meal_plan_repo.dart';

class UpdateMealPlanUseCase implements UseCase<MealPlan, UpdateMealPlanParams> {
  MealPlanRepo mealPlanRepo;

  UpdateMealPlanUseCase({required this.mealPlanRepo});

  @override
  Future<Either<Failure, MealPlan>> call(UpdateMealPlanParams params) async {
    final partial = <String, dynamic>{};
    if (params.totalKcal != null) partial['totalKcal'] = params.totalKcal;
    if (params.costEgp != null) partial['costEgp'] = params.costEgp;
    if (params.status != null) partial['status'] = params.status!.name;
    partial['updatedAt'] = DateTime.now();

    return await mealPlanRepo.update(
      uid: params.uid,
      mealPlanId: params.mealPlanId,
      partial: partial,
    );
  }
}
