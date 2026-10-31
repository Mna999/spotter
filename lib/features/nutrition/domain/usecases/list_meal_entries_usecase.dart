import 'package:dartz/dartz.dart';
import 'package:spotter/core/error/failure.dart';
import 'package:spotter/features/nutrition/domain/entities/meal_entry.dart';
import 'package:spotter/features/nutrition/domain/params/list_meal_entries_params.dart';
import 'package:spotter/features/nutrition/domain/repository/meal_entry_repo.dart';

class ListMealEntriesUseCase {
  final MealEntryRepo repo;

  const ListMealEntriesUseCase(this.repo);

  Future<Either<Failure, List<MealEntry>>> call(ListMealEntriesParams p) {
    return repo.list(uid: p.uid, mealPlanId: p.mealPlanId);
  }
}