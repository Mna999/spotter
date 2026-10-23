import 'package:dartz/dartz.dart';
import 'package:spotter/core/error/failure.dart';
import 'package:spotter/core/usecases/usecase.dart';
import 'package:spotter/features/workouts/domain/entities/set_summary.dart';
import 'package:spotter/features/workouts/domain/params/update_set_params.dart';
import 'package:spotter/features/workouts/domain/repository/set_repo.dart';

class UpdateSetUseCase implements UseCase<SetSummary, UpdateSetParams> {
  SetRepo setRepo;
  UpdateSetUseCase({required this.setRepo});
  @override
  Future<Either<Failure, SetSummary>> call(UpdateSetParams params) async {
    return await setRepo.update(
      uid: params.uid,
      workoutId: params.workoutId,
      setId: params.setId,
      load: params.load,
      reps: params.reps,
      restSec: params.restSec,
      timeUnderTension: params.timeUnderTension,
    );
  }
}
