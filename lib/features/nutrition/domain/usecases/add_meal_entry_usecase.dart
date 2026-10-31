import 'package:dartz/dartz.dart';
import 'package:spotter/core/error/failure.dart';
import 'package:spotter/core/usecases/usecase.dart';
import 'package:spotter/features/nutrition/domain/entities/meal_entry.dart';
import 'package:spotter/features/nutrition/domain/params/add_meal_entry_params.dart';
import 'package:spotter/features/nutrition/domain/repository/meal_entry_repo.dart';

class AddMealEntryUseCase implements UseCase<MealEntry, AddMealEntryParams> {
  MealEntryRepo mealEntryRepo;

  AddMealEntryUseCase({required this.mealEntryRepo});

  @override
  Future<Either<Failure, MealEntry>> call(AddMealEntryParams params) async {
    final now = DateTime.now();
    final entry = MealEntry(
      mealEntryId: '',
      mealPlanId: params.mealPlanId,
      uid: params.uid,
      foodId: params.foodId,
      mealType: params.mealType,
      order: params.order,
      portion: params.portion,
      servingsCount: params.servingsCount,
      note: params.note,
      schemaVersion: 1,
      createdAt: now,
      updatedAt: now,
    );
    return await mealEntryRepo.save(
      uid: params.uid,
      mealPlanId: params.mealPlanId,
      entry: entry,
    );
  }
}
