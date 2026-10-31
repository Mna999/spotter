import 'package:dartz/dartz.dart';
import 'package:spotter/core/error/failure.dart';
import 'package:spotter/features/nutrition/domain/entities/food_item.dart';
import 'package:spotter/features/nutrition/domain/params/food_filter_params.dart';

abstract class FoodRepo {
  Future<Either<Failure, List<FoodItem>>> search({required String query});

  Future<Either<Failure, FoodItem?>> getById({required String foodId});

  Future<Either<Failure, List<FoodItem>>> list({
    required FoodFilterParams filter,
  });
}
