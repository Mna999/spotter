import 'package:dartz/dartz.dart';
import 'package:spotter/core/error/failure.dart';
import 'package:spotter/core/usecases/usecase.dart';
import 'package:spotter/features/auth/domain/entities/body_metrics.dart';
import 'package:spotter/features/auth/domain/repositories/profile_repo.dart';

class ComputeBodyMetricsUseCase implements UseCase<BodyMetrics, MetricsParams> {
  ProfileRepo profileRepo;
  ComputeBodyMetricsUseCase({required this.profileRepo});
  @override
  Future<Either<Failure, BodyMetrics>> call(MetricsParams params) {
    final heightM = params.height / 100;
    final bmi = params.weight / (heightM * heightM);
    final ree =
        (10 * params.weight) +
        (6.25 * params.height) -
        (5 * params.age) +
        (params.isMale ? 5 : -161);
    final tdee = ree * params.activityLevel.factor;
    final targetCalories = tdee * params.goal.calorieMultiplier;

    final metrics = BodyMetrics(
      bmi: bmi,
      ree: ree,
      tdee: tdee,
      macroTargets: MacroTargets.calculate(
        targetCalories: targetCalories,
        weightKg: params.weight,
      ),
    );
    return profileRepo.saveMetrics(uid: params.uid, metrics: metrics);
  }
}
