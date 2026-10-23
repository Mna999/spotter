import 'package:dartz/dartz.dart';
import 'package:spotter/core/error/failure.dart';
import 'package:spotter/features/workouts/domain/entities/set_summary.dart';

abstract class SetRepo {
  Future<Either<Failure, SetSummary>> saveSet({
    required String uid,
    required String workoutId,
    required SetSummary setSummary,
  });

  Future<Either<Failure, List<SetSummary>>> getSets({
    required String uid,
    int limit = 20,
    String cursor,
  });
  Future<Either<Failure, List<SetSummary>>> getSetsFor({
    required String uid,
    required String workoutId,
  });
  Future<Either<Failure, Unit>> deleteSet({
    required String uid,
    required String workoutId,
    required String setId,
  });

  Future<Either<Failure, SetSummary>> update({
    required String uid,
    required String workoutId,
    required String setId,
    int? order,
    int? reps,
    double? load,
    int? timeUnderTension,
    double? rom,
    String? tempo,
    int? formScore,
    Map<String, int>? faultCounts,
    int? restSec,
  });
}
