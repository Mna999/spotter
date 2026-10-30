import 'package:dartz/dartz.dart';
import 'package:spotter/core/error/exception.dart';
import 'package:spotter/core/error/exception_handler.dart';
import 'package:spotter/core/error/failure.dart';
import 'package:spotter/core/network/network_info.dart';
import 'package:spotter/features/workouts/data/datasources/workout_remote_datasource.dart';
import 'package:spotter/features/workouts/domain/entities/workout_session.dart';
import 'package:spotter/features/workouts/domain/repository/workout_repo.dart';

class WorkoutRepoImpl implements WorkoutRepo {
  WorkoutRemoteDataSource workoutRemoteDataSource;
  NetworkInfo networkInfo;
  WorkoutRepoImpl({
    required this.workoutRemoteDataSource,
    required this.networkInfo,
  });
  @override
  Future<Either<Failure, Unit>> delete({
    required String uid,
    required String workoutId,
  }) async {
    bool isConnected = await networkInfo.isConnected;
    try {
      Right(
        await workoutRemoteDataSource.delete(
          uid: uid,
          workoutId: workoutId,
          isLocal: !isConnected,
        ),
      );
      return const Right(unit);
    } on ServerException catch (e) {
      return Left(
        ServerFailure(message: ExceptionHandler.serverExceptionHandler(e.code)),
      );
    }
  }

  @override
  Future<Either<Failure, WorkoutSession?>> get({
    required String uid,
    required String workoutId,
  }) async {
    bool isConnected = await networkInfo.isConnected;
    try {
      return Right(
        await workoutRemoteDataSource.get(
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
  Future<Either<Failure, List<WorkoutSession>>> inRange({
    required String uid,
    required DateTime start,
    required DateTime end,
  }) async {
    bool isConnected = await networkInfo.isConnected;
    try {
      return Right(
        await workoutRemoteDataSource.inRange(
          uid: uid,
          start: start,
          end: end,
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
  Future<Either<Failure, List<WorkoutSession>>> recent({
    required String uid,
    int? limit,
  }) async {
    bool isConnected = await networkInfo.isConnected;
    try {
      return Right(
        await workoutRemoteDataSource.recent(
          uid: uid,
          limit: limit,
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
  Future<Either<Failure, WorkoutSession>> save({
    required WorkoutSession workout,
  }) async {
    bool isConnected = await networkInfo.isConnected;
    try {
      return Right(
        await workoutRemoteDataSource.save(
          workout: workout,
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
  Future<Either<Failure, WorkoutSession>> update({
    required WorkoutSession workout,
  }) async {
    bool isConnected = await networkInfo.isConnected;
    try {
      return Right(
        await workoutRemoteDataSource.update(
          workout: workout,
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
