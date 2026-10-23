import 'package:dartz/dartz.dart';
import 'package:spotter/core/error/failure.dart';
import 'package:spotter/core/usecases/usecase.dart';
import 'package:spotter/features/workouts/domain/params/set_id_params.dart';
import 'package:spotter/features/workouts/domain/repository/set_repo.dart';

class DeleteSetUseCase implements UseCase<Unit, SetIdParams> {
  SetRepo setRepo;
  DeleteSetUseCase({required this.setRepo});
  @override
  Future<Either<Failure, Unit>> call(SetIdParams params) async {
    return await setRepo.deleteSet(
      uid: params.uid,
      workoutId: params.workoutId,
      setId: params.setId,
    );
  }
}
