import 'package:dartz/dartz.dart';
import 'package:spotter/core/error/failure.dart';
import 'package:spotter/core/usecases/usecase.dart';
import 'package:spotter/features/nutrition/domain/entities/meal_plan.dart';
import 'package:spotter/features/nutrition/domain/entities/plan_status.dart';
import 'package:spotter/features/nutrition/domain/params/create_meal_plan_params.dart';
import 'package:spotter/features/nutrition/domain/repository/meal_plan_repo.dart';

/// CREATE: a new, empty draft plan for the given day. Entries are not part
/// of the plan (they live in the entries subcollection) — add them via
/// AddMealEntryUseCase afterwards.
class CreateMealPlanUseCase implements UseCase<MealPlan, CreateMealPlanParams> {
  MealPlanRepo mealPlanRepo;

  CreateMealPlanUseCase({required this.mealPlanRepo});

  @override
  Future<Either<Failure, MealPlan>> call(CreateMealPlanParams params) async {
    final now = DateTime.now();
    final plan = MealPlan(
      mealPlanId: '', // assigned by Firestore on save
      uid: params.uid,
      date: params.date,
      budgetEgp: params.budgetEgp,
      totalKcal: 0,
      costEgp: 0,
      status: PlanStatus.draft,
      schemaVersion: 1,
      createdAt: now,
      updatedAt: now,
    );
    return await mealPlanRepo.save(uid: params.uid, plan: plan);
  }
}
