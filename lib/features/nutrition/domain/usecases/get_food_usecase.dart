import 'package:dartz/dartz.dart';
import 'package:spotter/core/error/failure.dart';
import 'package:spotter/core/usecases/usecase.dart';
import 'package:spotter/features/nutrition/domain/entities/food_item.dart';
import 'package:spotter/features/nutrition/domain/params/food_id_params.dart';
import 'package:spotter/features/nutrition/domain/repository/food_repo.dart';

class GetFoodUsecase implements UseCase<FoodItem?, FoodIdParams> {
  FoodRepo foodRepo;

  GetFoodUsecase({required this.foodRepo});

  @override
  Future<Either<Failure, FoodItem?>> call(FoodIdParams params) async {
    return await foodRepo.getById(foodId: params.foodId);
  }
}
