import 'package:dartz/dartz.dart';
import 'package:spotter/core/error/exception.dart';
import 'package:spotter/core/error/exception_handler.dart';
import 'package:spotter/core/error/failure.dart';
import 'package:spotter/core/network/network_info.dart';
import 'package:spotter/features/workouts/data/datasources/set_remote_datasource.dart';
import 'package:spotter/features/workouts/domain/entities/set_summary.dart';
import 'package:spotter/features/workouts/domain/repository/set_repo.dart';

class SetRepoImpl implements SetRepo {
  SetRemoteDataSource setRemoteDataSource;
  NetworkInfo networkInfo;
  SetRepoImpl({required this.setRemoteDataSource, required this.networkInfo});
  @override
  Future<Either<Failure, Unit>> deleteSet({
    required String uid,
    required String workoutId,
    required String plannedExerciseId,
    required String setId,
  }) async {
    bool isConnected = await networkInfo.isConnected;
    try {
      await setRemoteDataSource.deleteSet(
        uid: uid,
        workoutId: workoutId,
        plannedExerciseId: plannedExerciseId,
        setId: setId,
        isLocal: !isConnected,
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
    bool isConnected = await networkInfo.isConnected;
    try {
      return Right(
        await setRemoteDataSource.getSetsFor(
          uid: uid,
          workoutId: workoutId,
          plannedExerciseId: plannedExerciseId,
          isLocal: !isConnected,
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
    bool isConnected = await networkInfo.isConnected;
    try {
      return Right(
        await setRemoteDataSource.saveSet(
          uid: uid,
          workoutId: workoutId,
          plannedExerciseId: plannedExerciseId,
          setSummary: setSummary,
          isLocal: !isConnected,
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
    bool isConnected = await networkInfo.isConnected;
    try {
      return Right(
        await setRemoteDataSource.update(
          setSummary: setSummary,
          isLocal: !isConnected,
        ),
      );
    } on ServerException catch (e) {
      return Left(
        ServerFailure(message: ExceptionHandler.serverExceptionHandler(e.code)),
      );
    }
  }
}
