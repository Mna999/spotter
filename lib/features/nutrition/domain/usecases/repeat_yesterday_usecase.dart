import 'package:dartz/dartz.dart';
import 'package:spotter/core/error/failure.dart';
import 'package:spotter/core/usecases/usecase.dart';
import 'package:spotter/features/nutrition/domain/entities/meal_log.dart';
import 'package:spotter/features/nutrition/domain/params/date_params.dart';
import 'package:spotter/features/nutrition/domain/repository/meal_log_repo.dart';

/// READ + CREATE: clone every meal log of the day in [DateParams.date]
/// (usually yesterday: `DateTime.now().subtract(Duration(days: 1))`) to
/// today. Meal types, foods, portions and kcal are copied; the copy is
/// stamped with today's date (keeping the original time of day). Returns
/// the newly created logs.
class RepeatYesterdayUseCase implements UseCase<List<MealLog>, DateParams> {
  MealLogRepo mealLogRepo;

  RepeatYesterdayUseCase({required this.mealLogRepo});

  @override
  Future<Either<Failure, List<MealLog>>> call(DateParams params) async {
    // 1) The logs of the source day.
    final sourceOrFailure = await mealLogRepo.listForDate(
      uid: params.uid,
      date: params.date,
    );
    Failure? failure;
    List<MealLog>? source;
    sourceOrFailure.fold((f) => failure = f, (logs) => source = logs);
    if (failure != null || source == null) {
      return Left(failure ?? const CacheFailure());
    }
    if (source!.isEmpty) return const Right([]);

    // 2) Clone each log to today and persist it.
    final created = <MealLog>[];
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    for (final log in source!) {
      final loggedAt = DateTime(
        today.year,
        today.month,
        today.day,
        log.loggedAt.hour,
        log.loggedAt.minute,
      );
      final clone = MealLog(
        mealLogId: '', // assigned by Firestore on save
        uid: params.uid,
        foodId: log.foodId,
        mealType: log.mealType,
        portion: log.portion,
        servingsCount: log.servingsCount,
        computedKcal: log.computedKcal,
        loggedAt: loggedAt,
        note: log.note,
        schemaVersion: log.schemaVersion,
        createdAt: now,
        updatedAt: now,
      );
      final savedOrFailure = await mealLogRepo.save(
        uid: params.uid,
        log: clone,
      );
      Failure? saveFailure;
      MealLog? saved;
      savedOrFailure.fold((f) => saveFailure = f, (l) => saved = l);
      if (saveFailure != null || saved == null) {
        return Left(saveFailure ?? const ServerFailure());
      }
      created.add(saved!);
    }
    return Right(created);
  }
}
