import 'package:equatable/equatable.dart';

class MealPlanIdsParams extends Equatable {
  final String uid;
  final List<String> mealPlanIds;

  const MealPlanIdsParams({required this.uid, required this.mealPlanIds});

  @override
  List<Object?> get props => [uid, mealPlanIds];
}
