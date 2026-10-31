import 'package:dartz/dartz.dart';
import 'package:spotter/core/error/failure.dart';
import 'package:spotter/core/usecases/usecase.dart';
import 'package:spotter/features/nutrition/domain/entities/meal_log.dart';
import 'package:spotter/features/nutrition/domain/params/date_params.dart';
import 'package:spotter/features/nutrition/domain/repository/meal_log_repo.dart';

/// READ: every log of one calendar day (listForDate). Use it to fill the
/// day view of the food log.
class ListMealLogsForDateUseCase implements UseCase<List<MealLog>, DateParams> {
  MealLogRepo mealLogRepo;

  ListMealLogsForDateUseCase({required this.mealLogRepo});

  @override
  Future<Either<Failure, List<MealLog>>> call(DateParams params) async {
    return await mealLogRepo.listForDate(uid: params.uid, date: params.date);
  }
}
