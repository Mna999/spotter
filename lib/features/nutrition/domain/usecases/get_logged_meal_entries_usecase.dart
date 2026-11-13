import 'package:dartz/dartz.dart';
import 'package:spotter/core/error/failure.dart';
import 'package:spotter/core/usecases/usecase.dart';
import 'package:spotter/features/nutrition/domain/entities/meal_log.dart';
import 'package:spotter/features/nutrition/domain/params/date_params.dart';
import 'package:spotter/features/nutrition/domain/repository/meal_log_repo.dart';

/// READ: today's logs that were created from a planned meal entry, keyed by
/// the source entry id.
class GetLoggedMealEntriesUseCase
    implements UseCase<Map<String, MealLog>, DateParams> {
  final MealLogRepo mealLogRepo;

  const GetLoggedMealEntriesUseCase({required this.mealLogRepo});

  @override
  Future<Either<Failure, Map<String, MealLog>>> call(DateParams params) async {
    final result = await mealLogRepo.listForDate(
      uid: params.uid,
      date: params.date,
    );
    return result.map((logs) {
      final logged = <String, MealLog>{};
      for (final log in logs) {
        final entryId = log.sourceMealEntryId;
        if (entryId != null && entryId.isNotEmpty) logged[entryId] = log;
      }
      return logged;
    });
  }
}
