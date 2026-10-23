import 'package:dartz/dartz.dart';
import 'package:spotter/core/error/failure.dart';
import 'package:spotter/core/usecases/usecase.dart';
import 'package:spotter/features/workouts/domain/params/workout_id_params.dart';
import 'package:spotter/features/workouts/domain/repository/workout_repo.dart';

class DeleteWorkoutUseCase implements UseCase<Unit, WorkoutIdParams> {
  WorkoutRepo workoutRepo;
  DeleteWorkoutUseCase({required this.workoutRepo});
  @override
  Future<Either<Failure, Unit>> call(WorkoutIdParams params) async {
    return await workoutRepo.delete(
      uid: params.uid,
      workoutId: params.workoutId,
    );
  }
}
