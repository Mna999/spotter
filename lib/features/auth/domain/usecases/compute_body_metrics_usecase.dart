import 'package:dartz/dartz.dart';
import 'package:spotter/core/error/failure.dart';
import 'package:spotter/core/usecases/usecase.dart';
import 'package:spotter/features/auth/domain/entities/body_metrics.dart';
import 'package:spotter/features/auth/domain/repositories/profile_repo.dart';

class ComputeBodyMetricsUseCase implements UseCase<BodyMetrics, MetricsParams> {
  ProfileRepo profileRepo;
  ComputeBodyMetricsUseCase({required this.profileRepo});
  @override
  Future<Either<Failure, BodyMetrics>> call(MetricsParams params) async {
    final metrics = BodyMetrics.calculate(
      isMale: params.isMale,
      age: params.age,
      height: params.height,
      weight: params.weight,
      activityLevel: params.activityLevel,
      goal: params.goal,
    );
    return await profileRepo.saveMetrics(uid: params.uid, metrics: metrics);
  }
}
