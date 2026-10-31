import 'package:dartz/dartz.dart';
import 'package:spotter/core/error/failure.dart';
import 'package:spotter/core/usecases/usecase.dart';
import 'package:spotter/features/nutrition/domain/entities/meal_log.dart';
import 'package:spotter/features/nutrition/domain/params/meal_log_id_params.dart';
import 'package:spotter/features/nutrition/domain/repository/meal_log_repo.dart';

/// READ: fetch a single log by its id.
class GetMealLogUseCase implements UseCase<MealLog?, MealLogIdParams> {
  MealLogRepo mealLogRepo;

  GetMealLogUseCase({required this.mealLogRepo});

  @override
  Future<Either<Failure, MealLog?>> call(MealLogIdParams params) async {
    return await mealLogRepo.get(uid: params.uid, mealLogId: params.mealLogId);
  }
}
