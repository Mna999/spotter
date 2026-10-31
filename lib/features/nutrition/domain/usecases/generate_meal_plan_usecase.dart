import 'package:dartz/dartz.dart';
import 'package:spotter/core/constants.dart';
import 'package:spotter/core/error/failure.dart';
import 'package:spotter/core/usecases/usecase.dart';
import 'package:spotter/features/nutrition/domain/entities/meal_plan.dart';
import 'package:spotter/features/nutrition/domain/entities/plan_status.dart';
import 'package:spotter/features/nutrition/domain/params/prefs_id_params.dart';
import 'package:spotter/features/nutrition/domain/repository/nutrition_pref_repo.dart';

/// GENERATE: build a new draft plan for today from the user's dietary
/// preferences.
///
/// [MealPlan] does not embed its entries (they live in the plan's
/// `entries` subcollection), so this use case only produces the plan
/// header with the target calories and budget taken from the user's
/// dietary preferences. The caller adds the actual foods through
/// AddMealEntryUseCase and persists the result with SaveMealPlanUseCase.
class GenerateMealPlanUseCase implements UseCase<MealPlan?, PrefsIdParams> {
  NutritionPrefRepo nutritionPrefRepo;

  GenerateMealPlanUseCase({required this.nutritionPrefRepo});

  @override
  Future<Either<Failure, MealPlan?>> call(PrefsIdParams params) async {
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
          budgetEgp: prefs?.budgetEgp ?? 0,
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
