import 'package:dartz/dartz.dart';
import 'package:spotter/core/error/failure.dart';
import 'package:spotter/core/usecases/usecase.dart';
import 'package:spotter/features/nutrition/domain/entities/meal_entry.dart';
import 'package:spotter/features/nutrition/data/models/portion_model.dart';
import 'package:spotter/features/nutrition/domain/params/update_meal_entry_params.dart';
import 'package:spotter/features/nutrition/domain/repository/meal_entry_repo.dart';

/// UPDATE: patch one entry of a meal plan. Only the supplied fields are sent
/// to the repository (partial update), so untouched values stay as they are.
class UpdateMealEntryUseCase implements UseCase<MealEntry, UpdateMealEntryParams> {
  MealEntryRepo mealEntryRepo;

  UpdateMealEntryUseCase({required this.mealEntryRepo});

  @override
  Future<Either<Failure, MealEntry>> call(UpdateMealEntryParams params) {
    final partial = <String, dynamic>{
      if (params.order != null) 'order': params.order,
      if (params.portion != null)
        'portion': PortionModel.fromEntity(params.portion!).toJson(),
      if (params.servingsCount != null)
        'servingsCount': params.servingsCount,
      if (params.note != null) 'note': params.note,
    };
    return mealEntryRepo.update(
      uid: params.uid,
      mealPlanId: params.mealPlanId,
      mealEntryId: params.mealEntryId,
      partial: partial,
    );
  }
}
