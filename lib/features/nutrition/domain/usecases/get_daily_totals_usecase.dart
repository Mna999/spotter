import 'package:dartz/dartz.dart';
import 'package:spotter/core/error/failure.dart';
import 'package:spotter/core/usecases/usecase.dart';
import 'package:spotter/features/nutrition/domain/entities/macro_nutrients.dart';
import 'package:spotter/features/nutrition/domain/params/date_params.dart';
import 'package:spotter/features/nutrition/domain/repository/meal_log_repo.dart';

/// READ: aggregate the logs of one calendar day into a single
/// [MacroNutrients] value.
///
/// A `MealLog` only stores the denormalized `computedKcal`, so the daily
/// total is exact for energy. The remaining macro fields are returned as
/// zero because their per-food values live in `FoodItem.per100g` and are
/// not part of the log document.
class GetDailyTotalsUseCase implements UseCase<MacroNutrients, DateParams> {
  MealLogRepo mealLogRepo;

  GetDailyTotalsUseCase({required this.mealLogRepo});

  @override
  Future<Either<Failure, MacroNutrients>> call(DateParams params) async {
    final logsOrFailure = await mealLogRepo.listForDate(
      uid: params.uid,
      date: params.date,
    );

    return logsOrFailure.fold((failure) => Left(failure), (logs) {
      var totalKcal = 0.0;
      for (final log in logs) {
        totalKcal += log.computedKcal;
      }

      return Right(
        MacroNutrients(
          energyKcal: totalKcal,
          proteinG: 0,
          fatG: 0,
          carbohydrateG: 0,
          fiberG: 0,
          waterG: 0,
          ashG: 0,
          refusePct: 0,
          mineralsMg: const {},
          vitamins: const {},
        ),
      );
    });
  }
}
