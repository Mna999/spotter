import 'package:dartz/dartz.dart';
import 'package:spotter/core/error/failure.dart';
import 'package:spotter/core/usecases/usecase.dart';
import 'package:spotter/features/auth/domain/repositories/activity_target_repo.dart';

class UpdateWeeklyTargetUseCase implements UseCase<Unit, TargetParams> {
  ActivityTargetRepo activityTargetRepo;
  UpdateWeeklyTargetUseCase({required this.activityTargetRepo});
  @override
  Future<Either<Failure, Unit>> call(TargetParams params) {
    return activityTargetRepo.setWeeklyTarget(
      uid: params.uid,
      minutes: params.minutes,
      strengthDays: params.strengthDays,
    );
  }
}
