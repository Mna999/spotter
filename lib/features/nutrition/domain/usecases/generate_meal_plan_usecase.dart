import 'package:dartz/dartz.dart';
import 'package:spotter/core/constants.dart';
import 'package:spotter/core/error/failure.dart';
import 'package:spotter/core/usecases/usecase.dart';
import 'package:spotter/features/auth/domain/entities/body_metrics.dart';
import 'package:spotter/features/auth/domain/entities/user_profile.dart';
import 'package:spotter/features/auth/domain/usecases/get_user_profile_usecase.dart';
import 'package:spotter/features/nutrition/domain/entities/meal_plan.dart';
import 'package:spotter/features/nutrition/domain/entities/plan_status.dart';
import 'package:spotter/features/nutrition/domain/params/prefs_id_params.dart';
import 'package:spotter/features/nutrition/domain/repository/nutrition_pref_repo.dart';

/// GENERATE: build a new draft plan for today.
///
/// The calorie goal is derived from the user's profile (`BodyMetrics`), while
/// the EGP budget comes from their dietary preferences. [MealPlan] does not
/// embed its entries (they live in the plan's `entries` subcollection), so
/// this use case only produces the plan header. The caller adds the actual
/// foods through AddMealEntryUseCase and persists the result with
/// SaveMealPlanUseCase.
class GenerateMealPlanUseCase implements UseCase<MealPlan?, PrefsIdParams> {
  final NutritionPrefRepo nutritionPrefRepo;
  final GetUserProfileUseCase getUserProfile;

  GenerateMealPlanUseCase({
    required this.nutritionPrefRepo,
    required this.getUserProfile,
  });

  @override
  Future<Either<Failure, MealPlan?>> call(PrefsIdParams params) async {
    // Goal calories live in the user profile, not in dietary preferences.
    final profileResult = await getUserProfile(ProfileParams(params.uid));
    Failure? failure;
    UserProfile? profile;
    profileResult.fold((f) => failure = f, (p) => profile = p);
    if (failure != null) return Left(failure!);

    final targetKcal = profile == null
        ? 0.0
        : BodyMetrics.fromProfile(profile!).macroTargets.calories.toDouble();

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
          totalKcal: targetKcal,
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
