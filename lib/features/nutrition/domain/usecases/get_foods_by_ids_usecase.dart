import 'package:dartz/dartz.dart';
import 'package:spotter/core/error/failure.dart';
import 'package:spotter/core/usecases/usecase.dart';
import 'package:spotter/features/nutrition/domain/entities/food_item.dart';
import 'package:spotter/features/nutrition/domain/params/food_ids_params.dart';
import 'package:spotter/features/nutrition/domain/repository/food_repo.dart';

/// READ: load several catalogue foods at once, keyed by their id.
class GetFoodsByIdsUseCase
    implements UseCase<Map<String, FoodItem>, FoodIdsParams> {
  final FoodRepo foodRepo;

  const GetFoodsByIdsUseCase({required this.foodRepo});

  @override
  Future<Either<Failure, Map<String, FoodItem>>> call(FoodIdsParams params) {
    return foodRepo.getByIds(foodIds: params.foodIds);
  }
}
