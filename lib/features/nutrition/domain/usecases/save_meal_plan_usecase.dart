import 'package:dartz/dartz.dart';
import 'package:spotter/core/error/failure.dart';
import 'package:spotter/core/usecases/usecase.dart';
import 'package:spotter/features/nutrition/domain/entities/meal_plan.dart';
import 'package:spotter/features/nutrition/domain/params/save_plan_params.dart';
import 'package:spotter/features/nutrition/domain/repository/meal_plan_repo.dart';

class SaveMealPlanUsecase implements UseCase<MealPlan, SavePlanParams> {
  MealPlanRepo mealPlanRepo;

  SaveMealPlanUsecase({required this.mealPlanRepo});

  @override
  Future<Either<Failure, MealPlan>> call(SavePlanParams params) async {
    return await mealPlanRepo.save(uid: params.uid, plan: params.mealPlan);
  }
}