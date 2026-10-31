import 'package:equatable/equatable.dart';

class MealEntryIdParams extends Equatable {
  final String uid;
  final String mealPlanId;
  final String mealEntryId;

  const MealEntryIdParams({
    required this.uid,
    required this.mealPlanId,
    required this.mealEntryId,
  });

  @override
  List<Object?> get props => [uid, mealPlanId, mealEntryId];
}
