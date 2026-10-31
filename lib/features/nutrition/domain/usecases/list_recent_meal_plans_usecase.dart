import 'package:dartz/dartz.dart';
import 'package:spotter/core/error/failure.dart';
import 'package:spotter/core/usecases/usecase.dart';
import 'package:spotter/features/nutrition/domain/entities/meal_plan.dart';
import 'package:spotter/features/nutrition/domain/repository/meal_plan_repo.dart';
import 'package:spotter/features/workouts/domain/params/limit_params.dart';

class ListRecentMealPlansUsecase
    implements UseCase<List<MealPlan>, LimitParams> {
  MealPlanRepo mealPlanRepo;

  ListRecentMealPlansUsecase({required this.mealPlanRepo});

  @override
  Future<Either<Failure, List<MealPlan>>> call(LimitParams params) async {
    return await mealPlanRepo.recent(
      uid: params.uid,
      limit: params.limit,
      cursor: params.cursor,
    );
  }
}
