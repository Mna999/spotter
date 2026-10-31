import 'package:dartz/dartz.dart';
import 'package:spotter/core/error/failure.dart';
import 'package:spotter/core/usecases/usecase.dart';
import 'package:spotter/features/nutrition/domain/entities/food_item.dart';
import 'package:spotter/features/nutrition/domain/params/food_filter_params.dart';
import 'package:spotter/features/nutrition/domain/repository/food_repo.dart';

/// READ: browse the shared foods library by category with cursor
/// pagination (startAfterDocument in the RepositoryImpl).
class ListFoodsUseCase implements UseCase<List<FoodItem>, FoodFilterParams> {
  FoodRepo foodRepo;

  ListFoodsUseCase({required this.foodRepo});

  @override
  Future<Either<Failure, List<FoodItem>>> call(FoodFilterParams params) {
    return foodRepo.list(filter: params);
  }
}
