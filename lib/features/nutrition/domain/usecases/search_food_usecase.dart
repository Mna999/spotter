import 'package:dartz/dartz.dart';
import 'package:spotter/core/error/failure.dart';
import 'package:spotter/core/usecases/usecase.dart';
import 'package:spotter/features/nutrition/domain/entities/food_item.dart';
import 'package:spotter/features/nutrition/domain/params/search_params.dart';
import 'package:spotter/features/nutrition/domain/repository/food_repo.dart';

class SearchFoodUsecase implements UseCase<List<FoodItem>, SearchParams> {
  FoodRepo foodRepo;

  SearchFoodUsecase({required this.foodRepo});

  @override
  Future<Either<Failure, List<FoodItem>>> call(SearchParams params) async {
    return await foodRepo.search(query: params.query);
  }
}
