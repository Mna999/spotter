import 'package:dartz/dartz.dart';
import 'package:spotter/core/error/failure.dart';
import 'package:spotter/features/nutrition/domain/entities/meal_plan.dart';

abstract class MealPlanRepo {
  /// Creates or overwrites a plan. Returns the saved plan.
  Future<Either<Failure, MealPlan>> save({
    required String uid,
    required MealPlan plan,
  });

  Future<Either<Failure, MealPlan?>> get({
    required String uid,
    required String mealPlanId,
  });

  /// Most recent plans first. Pass the last item's id as [cursor]
  /// to fetch the next page.
  Future<Either<Failure, List<MealPlan>>> recent({
    required String uid,
    int limit = 20,
    String? cursor,
  });

  Future<Either<Failure, List<MealPlan>>> inRange({
    required String uid,
    required DateTime start,
    required DateTime end,
  });

  /// Applies [partial] fields to the plan. Returns the updated plan.
  Future<Either<Failure, MealPlan>> update({
    required String uid,
    required String mealPlanId,
    required Map<String, dynamic> partial,
  });

  Future<Either<Failure, Unit>> delete({
    required String uid,
    required String mealPlanId,
  });
}
