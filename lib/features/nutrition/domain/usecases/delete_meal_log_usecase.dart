import 'package:dartz/dartz.dart';
import 'package:spotter/core/error/failure.dart';
import 'package:spotter/core/usecases/usecase.dart';
import 'package:spotter/features/nutrition/domain/params/meal_log_id_params.dart';
import 'package:spotter/features/nutrition/domain/repository/meal_log_repo.dart';

/// DELETE: remove one log by id.
class DeleteMealLogUseCase implements UseCase<Unit, MealLogIdParams> {
  MealLogRepo mealLogRepo;

  DeleteMealLogUseCase({required this.mealLogRepo});

  @override
  Future<Either<Failure, Unit>> call(MealLogIdParams params) async {
    return await mealLogRepo.delete(
      uid: params.uid,
      mealLogId: params.mealLogId,
    );
  }
}
