import 'package:dartz/dartz.dart';
import 'package:spotter/core/error/failure.dart';
import 'package:spotter/core/usecases/usecase.dart';
import 'package:spotter/features/nutrition/domain/entities/dietary_preferences.dart';
import 'package:spotter/features/nutrition/domain/params/exclusion_params.dart';
import 'package:spotter/features/nutrition/domain/repository/nutrition_pref_repo.dart';

/// UPDATE: replace the excluded food ids of a user's preferences.
class UpdateExclusionsUseCase
    implements UseCase<DietaryPreferences, ExclusionParams> {
  final NutritionPrefRepo nutritionPrefRepo;

  UpdateExclusionsUseCase({required this.nutritionPrefRepo});

  @override
  Future<Either<Failure, DietaryPreferences>> call(ExclusionParams params) {
    return nutritionPrefRepo.updateExclusions(
      uid: params.uid,
      excludedFoodIds: params.excludedFoodIds,
    );
  }
}
