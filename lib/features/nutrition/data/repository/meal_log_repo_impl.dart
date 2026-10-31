import 'package:dartz/dartz.dart';
import 'package:spotter/core/error/exception.dart';
import 'package:spotter/core/error/exception_handler.dart';
import 'package:spotter/core/error/failure.dart';
import 'package:spotter/features/nutrition/data/datasources/meal_log_remote_data_source.dart';
import 'package:spotter/features/nutrition/domain/entities/meal_log.dart';
import 'package:spotter/features/nutrition/domain/repository/meal_log_repo.dart';


class MealLogRepoImpl implements MealLogRepo {
  final MealLogRemoteDataSource remoteDataSource;

  MealLogRepoImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, Unit>> delete({
    required String uid,
    required String mealLogId,
  }) async {
    try {
      await remoteDataSource.delete(uid: uid, mealLogId: mealLogId);
      return const Right(unit);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: ExceptionHandler.serverExceptionHandler(e.code)));
    }
  }

  @override
  Future<Either<Failure, MealLog?>> get({
    required String uid,
    required String mealLogId,
  }) async {
    try {
      final mealLog = await remoteDataSource.get(uid: uid, mealLogId: mealLogId);
      return Right(mealLog);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: ExceptionHandler.serverExceptionHandler(e.code)));
    } 
  }

  @override
  Future<Either<Failure, List<MealLog>>> inRange({
    required String uid,
    required DateTime start,
    required DateTime end,
  }) async {
    try {
      final mealLogs = await remoteDataSource.inRange(uid: uid, start: start, end: end);
      return Right(mealLogs);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: ExceptionHandler.serverExceptionHandler(e.code)));
    }
  }

  @override
  Future<Either<Failure, List<MealLog>>> listForDate({
    required String uid,
    required DateTime date,
  }) async {
    try {
      final mealLogs = await remoteDataSource.listForDate(uid: uid, date: date);
      return Right(mealLogs);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: ExceptionHandler.serverExceptionHandler(e.code)));
    }
  }

  @override
  Future<Either<Failure, MealLog>> save({
    required String uid,
    required MealLog log,
  }) async {
    try {
      final savedLog = await remoteDataSource.save(uid: uid, log: log);
      return Right(savedLog);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: ExceptionHandler.serverExceptionHandler(e.code)));
    }
  }

  @override
  Future<Either<Failure, MealLog>> update({
    required String uid,
    required String mealLogId,
    required Map<String, dynamic> partial,
  }) async {
    try {
      final updatedLog = await remoteDataSource.update(
        uid: uid,
        mealLogId: mealLogId,
        partial: partial,
      );
      return Right(updatedLog);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: ExceptionHandler.serverExceptionHandler(e.code)));
    } 
  }
}