import 'package:dartz/dartz.dart';
import 'package:spotter/core/error/failure.dart';
import 'package:spotter/core/usecases/usecase.dart';
import 'package:spotter/features/workouts/domain/entities/workout_session.dart';
import 'package:spotter/features/workouts/domain/params/limit_params.dart';
import 'package:spotter/features/workouts/domain/repository/workout_repo.dart';

class ListRecentWorkoutsUseCase
    implements UseCase<List<WorkoutSession>, LimitParams> {
  WorkoutRepo workoutRepo;
  ListRecentWorkoutsUseCase({required this.workoutRepo});
  @override
  Future<Either<Failure, List<WorkoutSession>>> call(LimitParams params) async {
    return await workoutRepo.recent(uid: params.uid, limit: params.limit);
  }
}
