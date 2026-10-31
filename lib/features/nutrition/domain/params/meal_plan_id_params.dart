import 'package:equatable/equatable.dart';

class MealPlanIdParams extends Equatable {
  final String uid;
  final String mealPlanId;

  const MealPlanIdParams({required this.uid, required this.mealPlanId});

  @override
  List<Object?> get props => [uid, mealPlanId];
}
