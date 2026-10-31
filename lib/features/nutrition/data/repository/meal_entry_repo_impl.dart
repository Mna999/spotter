import 'package:dartz/dartz.dart';
import 'package:spotter/core/error/exception.dart';
import 'package:spotter/core/error/exception_handler.dart';
import 'package:spotter/core/error/failure.dart';
import 'package:spotter/features/nutrition/data/datasources/meal_entry_remote_data_source.dart';
import 'package:spotter/features/nutrition/domain/entities/meal_entry.dart';
import 'package:spotter/features/nutrition/domain/repository/meal_entry_repo.dart';

class MealEntryRepoImpl implements MealEntryRepo {
  final MealEntryRemoteDataSource remoteDataSource;

  MealEntryRepoImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, Unit>> delete({
    required String uid,
    required String mealPlanId,
    required String mealEntryId,
  }) async {
    try {
      await remoteDataSource.delete(
        uid: uid,
        mealPlanId: mealPlanId,
        mealEntryId: mealEntryId,
      );
      return const Right(unit);
    } on ServerException catch (e) {
      return Left(
        ServerFailure(message: ExceptionHandler.serverExceptionHandler(e.code)),
      );
    } 
  }

  @override
  Future<Either<Failure, MealEntry?>> get({
    required String uid,
    required String mealPlanId,
    required String mealEntryId,
  }) async {
    try {
      final mealEntry = await remoteDataSource.get(
        uid: uid,
        mealPlanId: mealPlanId,
        mealEntryId: mealEntryId,
      );
      return Right(mealEntry);
    } on ServerException catch (e) {
      return Left(
        ServerFailure(message: ExceptionHandler.serverExceptionHandler(e.code)),
      );
    } 
  }

  @override
  Future<Either<Failure, List<MealEntry>>> list({
    required String uid,
    required String mealPlanId,
  }) async {
    try {
      final mealEntries = await remoteDataSource.list(
        uid: uid,
        mealPlanId: mealPlanId,
      );
      return Right(mealEntries);
    } on ServerException catch (e) {
      return Left(
        ServerFailure(message: ExceptionHandler.serverExceptionHandler(e.code)),
      );
    }
  }

  @override
  Future<Either<Failure, MealEntry>> save({
    required String uid,
    required String mealPlanId,
    required MealEntry entry,
  }) async {
    try {
      final savedEntry = await remoteDataSource.save(
        uid: uid,
        mealPlanId: mealPlanId,
        entry: entry,
      );
      return Right(savedEntry);
    } on ServerException catch (e) {
      return Left(
        ServerFailure(message: ExceptionHandler.serverExceptionHandler(e.code)),
      );
    }
  }

  @override
  Future<Either<Failure, MealEntry>> update({
    required String uid,
    required String mealPlanId,
    required String mealEntryId,
    required Map<String, dynamic> partial,
  }) async {
    try {
      final updatedEntry = await remoteDataSource.update(
        uid: uid,
        mealPlanId: mealPlanId,
        mealEntryId: mealEntryId,
        partial: partial,
      );
      return Right(updatedEntry);
    } on ServerException catch (e) {
      return Left(
        ServerFailure(message: ExceptionHandler.serverExceptionHandler(e.code)),
      );
    } 
  }
}
