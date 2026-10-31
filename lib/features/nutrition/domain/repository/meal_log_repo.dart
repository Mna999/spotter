import 'package:dartz/dartz.dart';
import 'package:spotter/core/error/failure.dart';
import 'package:spotter/features/nutrition/domain/entities/meal_log.dart';

abstract class MealLogRepo {
  Future<Either<Failure, MealLog>> save({
    required String uid,
    required MealLog log,
  });
  Future<Either<Failure, MealLog?>> get({
    required String uid,
    required String mealLogId,
  });
  Future<Either<Failure, List<MealLog>>> listForDate({
    required String uid,
    required DateTime date,
  });
  Future<Either<Failure, List<MealLog>>> inRange({
    required String uid,
    required DateTime start,
    required DateTime end,
  });
  Future<Either<Failure, MealLog>> update({
    required String uid,
    required String mealLogId,
    required Map<String, dynamic> partial,
  });
  Future<Either<Failure, Unit>> delete({
    required String uid,
    required String mealLogId,
  });
}
