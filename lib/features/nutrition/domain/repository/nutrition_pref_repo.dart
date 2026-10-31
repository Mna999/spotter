import 'package:dartz/dartz.dart';
import 'package:spotter/core/error/failure.dart';
import 'package:spotter/features/nutrition/domain/entities/dietary_preferences.dart';

abstract class NutritionPrefRepo {
  Future<Either<Failure, DietaryPreferences?>> get({required String uid,required String prefsId});
  Future<Either<Failure, DietaryPreferences>> save({
    required String uid,
    required DietaryPreferences prefs,
  });
  Future<Either<Failure, DietaryPreferences>> updateExclusions({
    required String uid,
    required Set<String> excludedFoodIds,
    required String prefsId
  });
  Future<Either<Failure, DietaryPreferences>> update({
    required String uid,
    required Map<String, dynamic> partial,
    required String prefsId
  });
}
