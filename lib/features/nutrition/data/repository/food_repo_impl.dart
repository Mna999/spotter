import 'dart:developer';

import 'package:dartz/dartz.dart';
import 'package:spotter/core/error/exception.dart';
import 'package:spotter/core/error/exception_handler.dart';
import 'package:spotter/core/error/failure.dart';
import 'package:spotter/features/nutrition/data/datasources/food_remote_data_source.dart';
import 'package:spotter/features/nutrition/domain/entities/food_item.dart';
import 'package:spotter/features/nutrition/domain/params/food_filter_params.dart';
import 'package:spotter/features/nutrition/domain/repository/food_repo.dart';

class FoodRepoImpl implements FoodRepo {
  final FoodRemoteDataSource remoteDataSource;

  FoodRepoImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, FoodItem?>> getById({required String foodId}) async {
    try {
      final foodItem = await remoteDataSource.getById(foodId: foodId);
      return Right(foodItem);
    } on ServerException catch (e) {
      return Left(
        ServerFailure(message: ExceptionHandler.serverExceptionHandler(e.code)),
      );
    } catch (e) {
      log(e.toString());
      return const Left(
        ServerFailure(message: 'Something went wrong. Please try again.'),
      );
    }
  }

  @override
  Future<Either<Failure, List<FoodItem>>> list({
    required FoodFilterParams filter,
  }) async {
    try {
      final foodItems = await remoteDataSource.list(filter: filter);
      return Right(foodItems);
    } on ServerException catch (e) {
      return Left(
        ServerFailure(message: ExceptionHandler.serverExceptionHandler(e.code)),
      );
    } catch (e) {
      log(e.toString());
      return const Left(
        ServerFailure(message: 'Something went wrong. Please try again.'),
      );
    }
  }

  @override
  Future<Either<Failure, List<FoodItem>>> search({
    required String query,
  }) async {
    try {
      final foodItems = await remoteDataSource.search(query: query);
      return Right(foodItems);
    } on ServerException catch (e) {
      return Left(
        ServerFailure(message: ExceptionHandler.serverExceptionHandler(e.code)),
      );
    } catch (_) {
      return const Left(
        ServerFailure(message: 'Something went wrong. Please try again.'),
      );
    }
  }
}
