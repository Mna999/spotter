import 'package:dartz/dartz.dart';
import 'package:spotter/core/error/failure.dart';
import 'package:spotter/core/usecases/usecase.dart';
import 'package:spotter/features/workouts/domain/entities/workout_session.dart';
import 'package:spotter/features/workouts/domain/params/workout_id_params.dart';
import 'package:spotter/features/workouts/domain/repository/workout_repo.dart';

class GetWorkoutUseCase implements UseCase<WorkoutSession?, WorkoutIdParams> {
  WorkoutRepo workoutRepo;
  GetWorkoutUseCase({required this.workoutRepo});
  @override
  Future<Either<Failure, WorkoutSession?>> call(WorkoutIdParams params) async {
    return await workoutRepo.get(uid: params.uid, workoutId: params.workoutId);
  }
}
