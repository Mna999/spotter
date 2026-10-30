import 'package:dartz/dartz.dart';
import 'package:spotter/core/error/exception.dart';
import 'package:spotter/core/error/exception_handler.dart';
import 'package:spotter/core/error/failure.dart';
import 'package:spotter/core/network/network_info.dart';
import 'package:spotter/features/workouts/data/datasources/planned_exercise_remote_datasource.dart';
import 'package:spotter/features/workouts/domain/entities/planned_exercise.dart';
import 'package:spotter/features/workouts/domain/repository/planned_exercise_repo.dart';

class PlannedExerciseRepoImpl implements PlannedExerciseRepo {
  PlannedExerciseRemoteDataSource plannedExerciseRemoteDataSource;
  NetworkInfo networkInfo;
  PlannedExerciseRepoImpl({
    required this.plannedExerciseRemoteDataSource,
    required this.networkInfo,
  });
  @override
  Future<Either<Failure, Unit>> delete({
    required String uid,
    required String workoutId,
    required String plannedExerciseId,
  }) async {
    bool isConnected = await networkInfo.isConnected;
    try {
      await plannedExerciseRemoteDataSource.delete(
        uid: uid,
        workoutId: workoutId,
        plannedExerciseId: plannedExerciseId,
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
  Future<Either<Failure, PlannedExercise?>> get({
    required String uid,
    required String workoutId,
    required String exerciseId,
  }) async {
    bool isConnected = await networkInfo.isConnected;
    try {
      return Right(
        await plannedExerciseRemoteDataSource.get(
          uid: uid,
          workoutId: workoutId,
          exerciseId: exerciseId,
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
  Future<Either<Failure, List<PlannedExercise>>> list({
    required String uid,
    required String workoutId,
  }) async {
    bool isConnected = await networkInfo.isConnected;
    try {
      return Right(
        await plannedExerciseRemoteDataSource.list(
          uid: uid,
          workoutId: workoutId,
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
  Future<Either<Failure, PlannedExercise>> save({
    required String uid,
    required String workoutId,
    required PlannedExercise plannedExercise,
  }) async {
    bool isConnected = await networkInfo.isConnected;
    try {
      return Right(
        await plannedExerciseRemoteDataSource.save(
          uid: uid,
          workoutId: workoutId,
          plannedExercise: plannedExercise,
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
  Future<Either<Failure, PlannedExercise>> update({
    required PlannedExercise plannedExercise,
  }) async {
    bool isConnected = await networkInfo.isConnected;
    try {
      return Right(
        await plannedExerciseRemoteDataSource.update(
          plannedExercise: plannedExercise,
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
