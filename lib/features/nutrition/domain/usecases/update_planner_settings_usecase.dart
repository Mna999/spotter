import 'package:dartz/dartz.dart';
import 'package:spotter/core/error/failure.dart';
import 'package:spotter/core/usecases/usecase.dart';
import 'package:spotter/features/nutrition/domain/entities/dietary_preferences.dart';
import 'package:spotter/features/nutrition/domain/params/update_planner_settings_params.dart';
import 'package:spotter/features/nutrition/domain/repository/nutrition_pref_repo.dart';

/// UPDATE: patch the EGP budget and diet tag of the planner settings.
class UpdatePlannerSettingsUseCase
    implements UseCase<DietaryPreferences, UpdatePlannerSettingsParams> {
  final NutritionPrefRepo nutritionPrefRepo;

  const UpdatePlannerSettingsUseCase({required this.nutritionPrefRepo});

  @override
  Future<Either<Failure, DietaryPreferences>> call(
    UpdatePlannerSettingsParams params,
  ) {
    return nutritionPrefRepo.update(
      uid: params.uid,
      prefsId: params.prefsId,
      partial: <String, dynamic>{
        'budgetEgp': params.budgetEgp,
        'dietTag': params.dietTag,
      },
    );
  }
}
