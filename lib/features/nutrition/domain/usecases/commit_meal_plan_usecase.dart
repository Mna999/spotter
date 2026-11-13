import 'package:dartz/dartz.dart';
import 'package:spotter/core/error/failure.dart';
import 'package:spotter/core/usecases/usecase.dart';
import 'package:spotter/features/nutrition/domain/entities/meal_plan.dart';
import 'package:spotter/features/nutrition/domain/entities/meal_plan_entries.dart';
import 'package:spotter/features/nutrition/domain/entities/plan_status.dart';
import 'package:spotter/features/nutrition/domain/params/list_meal_entries_params.dart';
import 'package:spotter/features/nutrition/domain/params/meal_plan_id_params.dart';
import 'package:spotter/features/nutrition/domain/repository/meal_plan_repo.dart';
import 'package:spotter/features/nutrition/domain/usecases/get_meal_plan_entries_usecase.dart';

/// UPDATE: persist the current totals of a plan and mark it as committed.
class CommitMealPlanUseCase implements UseCase<MealPlan, MealPlanIdParams> {
  final MealPlanRepo mealPlanRepo;
  final GetMealPlanEntriesUseCase getMealPlanEntries;

  const CommitMealPlanUseCase({
    required this.mealPlanRepo,
    required this.getMealPlanEntries,
  });

  @override
  Future<Either<Failure, MealPlan>> call(MealPlanIdParams params) async {
    final planResult = await mealPlanRepo.get(
      uid: params.uid,
      mealPlanId: params.mealPlanId,
    );
    return planResult.fold<Future<Either<Failure, MealPlan>>>(
      (failure) async => Left(failure),
      (plan) async {
        if (plan == null) {
          return const Left(
            ServerFailure(message: 'Meal plan was not found.'),
          );
        }
        final entriesResult = await getMealPlanEntries(
          ListMealEntriesParams(
            uid: params.uid,
            mealPlanId: params.mealPlanId,
          ),
        );
        final entries = entriesResult.fold<MealPlanEntries>(
          (_) => const MealPlanEntries(),
          (value) => value,
        );
        final updated = plan.copyWith(
          totalKcal: entries.totals.energyKcal > 0
              ? entries.totals.energyKcal
              : plan.totalKcal,
          costEgp: entries.spentEgp > 0 ? entries.spentEgp : plan.costEgp,
          status: PlanStatus.committed,
        );
        return mealPlanRepo.save(uid: params.uid, plan: updated);
      },
    );
  }
}
