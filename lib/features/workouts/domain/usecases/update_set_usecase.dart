import 'package:dartz/dartz.dart';
import 'package:spotter/core/error/failure.dart';
import 'package:spotter/core/usecases/usecase.dart';
import 'package:spotter/features/workouts/domain/entities/set_summary.dart';
import 'package:spotter/features/workouts/domain/repository/set_repo.dart';

class UpdateSetUseCase implements UseCase<SetSummary, SetSummary> {
  SetRepo setRepo;
  UpdateSetUseCase({required this.setRepo});
  @override
  Future<Either<Failure, SetSummary>> call(SetSummary setSummary) async {
    return await setRepo.update(setSummary: setSummary);
  }
}
