import 'package:dartz/dartz.dart';
import 'package:spotter/core/error/exception.dart';
import 'package:spotter/core/error/exception_handler.dart';
import 'package:spotter/core/error/failure.dart';
import 'package:spotter/features/nutrition/data/datasources/meal_plan_remote_data_source.dart';
import 'package:spotter/features/nutrition/domain/entities/meal_plan.dart';
import 'package:spotter/features/nutrition/domain/repository/meal_plan_repo.dart';

class MealPlanRepoImpl implements MealPlanRepo {
  final MealPlanRemoteDataSource remoteDataSource;

  MealPlanRepoImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, Unit>> delete({
    required String uid,
    required String mealPlanId,
  }) async {
    try {
      await remoteDataSource.delete(uid: uid, mealPlanId: mealPlanId);
      return const Right(unit);
    } on ServerException catch (e) {
      return Left(
        ServerFailure(message: ExceptionHandler.serverExceptionHandler(e.code)),
      );
    } 
  }

  @override
  Future<Either<Failure, MealPlan?>> get({
    required String uid,
    required String mealPlanId,
  }) async {
    try {
      final mealPlan = await remoteDataSource.get(
        uid: uid,
        mealPlanId: mealPlanId,
      );
      return Right(mealPlan);
    } on ServerException catch (e) {
      return Left(
        ServerFailure(message: ExceptionHandler.serverExceptionHandler(e.code)),
      );
    } 
  }

  @override
  Future<Either<Failure, List<MealPlan>>> inRange({
    required String uid,
    required DateTime start,
    required DateTime end,
  }) async {
    try {
      final mealPlans = await remoteDataSource.inRange(
        uid: uid,
        start: start,
        end: end,
      );
      return Right(mealPlans);
    } on ServerException catch (e) {
      return Left(
        ServerFailure(message: ExceptionHandler.serverExceptionHandler(e.code)),
      );
    }
  }

  @override
  Future<Either<Failure, List<MealPlan>>> recent({
    required String uid,
    int limit = 20,
    String? cursor,
  }) async {
    try {
      final mealPlans = await remoteDataSource.recent(
        uid: uid,
        limit: limit,
        cursor: cursor,
      );
      return Right(mealPlans);
    } on ServerException catch (e) {
      return Left(
        ServerFailure(message: ExceptionHandler.serverExceptionHandler(e.code)),
      );
    }
  }

  @override
  Future<Either<Failure, MealPlan>> save({
    required String uid,
    required MealPlan plan,
  }) async {
    try {
      final savedPlan = await remoteDataSource.save(uid: uid, plan: plan);
      return Right(savedPlan);
    } on ServerException catch (e) {
      return Left(
        ServerFailure(message: ExceptionHandler.serverExceptionHandler(e.code)),
      );
    }
  }

  @override
  Future<Either<Failure, MealPlan>> update({
    required String uid,
    required String mealPlanId,
    required Map<String, dynamic> partial,
  }) async {
    try {
      final updatedPlan = await remoteDataSource.update(
        uid: uid,
        mealPlanId: mealPlanId,
        partial: partial,
      );
      return Right(updatedPlan);
    } on ServerException catch (e) {
      return Left(
        ServerFailure(message: ExceptionHandler.serverExceptionHandler(e.code)),
      );
    } 
  }
}
