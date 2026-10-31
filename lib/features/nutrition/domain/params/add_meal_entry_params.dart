import 'package:equatable/equatable.dart';
import 'package:spotter/features/nutrition/domain/entities/meal_type.dart';
import 'package:spotter/features/nutrition/domain/entities/portion.dart';

class AddMealEntryParams extends Equatable {
  final String uid;
  final String mealPlanId;
  final String foodId;
  final MealType mealType;
  final int order;
  final Portion portion;
  final double servingsCount;
  final String? note;

  const AddMealEntryParams({
    required this.uid,
    required this.mealPlanId,
    required this.foodId,
    required this.mealType,
    required this.order,
    required this.portion,
    required this.servingsCount,
    this.note,
  });

  @override
  List<Object?> get props => [
    uid,
    mealPlanId,
    foodId,
    mealType,
    order,
    portion,
    servingsCount,
    note,
  ];
}
