import 'package:dartz/dartz.dart';
import 'package:spotter/core/constants.dart';
import 'package:spotter/core/error/failure.dart';
import 'package:spotter/core/usecases/usecase.dart';
import 'package:spotter/features/nutrition/domain/entities/meal_plan.dart';
import 'package:spotter/features/nutrition/domain/entities/plan_status.dart';
import 'package:spotter/features/nutrition/domain/params/budget_params.dart';
import 'package:spotter/features/nutrition/domain/repository/nutrition_pref_repo.dart';

/// GENERATE: re-roll today's plan under a new budget.
///
/// The user's calorie target still comes from their dietary preferences,
/// while the budget is the one supplied in [BudgetParams]. The returned
/// plan is a fresh draft (not persisted); persist it with
/// SaveMealPlanUseCase after adding the entries.
class RegenerateUnderBudgetUseCase implements UseCase<MealPlan, BudgetParams> {
  NutritionPrefRepo nutritionPrefRepo;

  RegenerateUnderBudgetUseCase({required this.nutritionPrefRepo});

  @override
  Future<Either<Failure, MealPlan>> call(BudgetParams params) async {
    final prefsOrFailure = await nutritionPrefRepo.get(
      uid: params.uid,
      prefsId: params.prefsId,
    );

    return prefsOrFailure.fold((failure) => Left(failure), (prefs) {
      final now = DateTime.now();
      return Right(
        MealPlan(
          mealPlanId: '', // assigned by Firestore on save
          uid: params.uid,
          date: DateTime(now.year, now.month, now.day),
          budgetEgp: params.budgetEgp,
          totalKcal: prefs?.targetKcal ?? 0,
          costEgp: 0,
          status: PlanStatus.draft,
          schemaVersion: SCHEMA_VERSION,
          createdAt: now,
          updatedAt: now,
        ),
      );
    });
  }
}
