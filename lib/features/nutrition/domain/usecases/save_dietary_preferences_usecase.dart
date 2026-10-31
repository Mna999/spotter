import 'package:dartz/dartz.dart';
import 'package:spotter/core/error/failure.dart';
import 'package:spotter/core/usecases/usecase.dart';
import 'package:spotter/features/nutrition/domain/entities/dietary_preferences.dart';
import 'package:spotter/features/nutrition/domain/params/save_dietary_pref_params.dart';
import 'package:spotter/features/nutrition/domain/repository/nutrition_pref_repo.dart';

/// CREATE / UPDATE: persist a full dietary preferences document.
class SaveDietaryPreferencesUseCase
    implements UseCase<DietaryPreferences, SaveDietaryPrefParams> {
  final NutritionPrefRepo nutritionPrefRepo;

  SaveDietaryPreferencesUseCase({required this.nutritionPrefRepo});

  @override
  Future<Either<Failure, DietaryPreferences>> call(
    SaveDietaryPrefParams params,
  ) {
    return nutritionPrefRepo.save(uid: params.uid, prefs: params.prefs);
  }
}
