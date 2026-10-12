import 'package:dartz/dartz.dart';
import 'package:spotter/core/error/failure.dart';
import 'package:spotter/features/auth/domain/entities/weekly_activity_target.dart';

abstract class ActivityTargetRepo {
  Future<Either<Failure, WeeklyActivityTarget>> getWeeklyTarget(String id);
  Future<Either<Failure, Unit>> setWeeklyTarget({
    required String uid,
    required int minutes,
    required int strengthDays,
  });
}
