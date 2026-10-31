import 'package:equatable/equatable.dart';
import 'package:spotter/features/nutrition/domain/entities/meal_type.dart';
import 'package:spotter/features/nutrition/domain/entities/portion.dart';

class LogFoodParams extends Equatable {
  final String uid;
  final String foodId;
  final MealType mealType;
  final Portion portion;
  final double servingsCount;
  final DateTime loggetAt;
  final String? note;

  const LogFoodParams({
    required this.uid,
    required this.foodId,
    required this.mealType,
    required this.portion,
    required this.servingsCount,
    required this.loggetAt,
    this.note,
  });

  @override
  List<Object?> get props => [
    uid,
    foodId,
    mealType,
    portion,
    servingsCount,
    loggetAt,
    note,
  ];
}
