import 'package:dartz/dartz.dart';
import 'package:spotter/core/error/failure.dart';
import 'package:spotter/features/nutrition/domain/entities/meal_entry.dart';

abstract class MealEntryRepo {
  Future<Either<Failure, MealEntry>> save({
    required String uid,
    required String mealPlanId,
    required MealEntry entry,
  });

  Future<Either<Failure, MealEntry?>> get({
    required String uid,
    required String mealPlanId,
    required String mealEntryId,
  });
  Future<Either<Failure, List<MealEntry>>> list({
    required String uid,
    required String mealPlanId,
  });
  Future<Either<Failure, MealEntry>> update({
    required String uid,
    required String mealPlanId,
    required String mealEntryId,
    required Map<String, dynamic> partial,
  });
  Future<Either<Failure, Unit>> delete({
    required String uid,
    required String mealPlanId,
    required String mealEntryId,
  });
}
