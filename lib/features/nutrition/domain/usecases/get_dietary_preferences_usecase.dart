import 'package:dartz/dartz.dart';
import 'package:spotter/core/error/failure.dart';
import 'package:spotter/core/usecases/usecase.dart';
import 'package:spotter/features/nutrition/domain/entities/dietary_preferences.dart';
import 'package:spotter/features/nutrition/domain/params/prefs_id_params.dart';
import 'package:spotter/features/nutrition/domain/repository/nutrition_pref_repo.dart';

/// READ: the dietary preferences / macro targets of one user.
class GetDietaryPreferencesUseCase
    implements UseCase<DietaryPreferences?, PrefsIdParams> {
  final NutritionPrefRepo nutritionPrefRepo;

  GetDietaryPreferencesUseCase({required this.nutritionPrefRepo});

  @override
  Future<Either<Failure, DietaryPreferences?>> call(PrefsIdParams params) {
    return nutritionPrefRepo.get(uid: params.uid, prefsId: params.prefsId);
  }
}
