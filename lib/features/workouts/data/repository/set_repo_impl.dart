import 'package:dartz/dartz.dart';
import 'package:spotter/core/error/exception.dart';
import 'package:spotter/core/error/exception_handler.dart';
import 'package:spotter/core/error/failure.dart';
import 'package:spotter/features/workouts/data/datasources/set_remote_datasource.dart';
import 'package:spotter/features/workouts/domain/entities/set_summary.dart';
import 'package:spotter/features/workouts/domain/repository/set_repo.dart';

class SetRepoImpl implements SetRepo {
  SetRemoteDataSource setRemoteDataSource;
  SetRepoImpl({required this.setRemoteDataSource});
  @override
  Future<Either<Failure, Unit>> deleteSet({
    required String uid,
    required String workoutId,
    required String plannedExerciseId,
    required String setId,
  }) async {
    try {
      await setRemoteDataSource.deleteSet(
        uid: uid,
        workoutId: workoutId,
        plannedExerciseId: plannedExerciseId,
        setId: setId,
      );
      return const Right(unit);
    } on ServerException catch (e) {
      return Left(
        ServerFailure(message: ExceptionHandler.serverExceptionHandler(e.code)),
      );
    }
  }

  @override
  Future<Either<Failure, List<SetSummary>>> getSetsFor({
    required String uid,
    required String workoutId,
    required String plannedExerciseId,
  }) async {
    try {
      return Right(
        await setRemoteDataSource.getSetsFor(
          uid: uid,
          workoutId: workoutId,
          plannedExerciseId: plannedExerciseId,
        ),
      );
    } on ServerException catch (e) {
      return Left(
        ServerFailure(message: ExceptionHandler.serverExceptionHandler(e.code)),
      );
    }
  }

  @override
  Future<Either<Failure, SetSummary>> saveSet({
    required String uid,
    required String workoutId,
    required String plannedExerciseId,
    required SetSummary setSummary,
  }) async {
    try {
      return Right(
        await setRemoteDataSource.saveSet(
          uid: uid,
          workoutId: workoutId,
          plannedExerciseId: plannedExerciseId,
          setSummary: setSummary,
        ),
      );
    } on ServerException catch (e) {
      return Left(
        ServerFailure(message: ExceptionHandler.serverExceptionHandler(e.code)),
      );
    }
  }

  @override
  Future<Either<Failure, SetSummary>> update({
    required SetSummary setSummary,
  }) async {
    try {
      return Right(await setRemoteDataSource.update(setSummary: setSummary));
    } on ServerException catch (e) {
      return Left(
        ServerFailure(message: ExceptionHandler.serverExceptionHandler(e.code)),
      );
    }
  }
}
