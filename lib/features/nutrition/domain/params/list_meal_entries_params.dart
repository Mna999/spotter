import 'package:equatable/equatable.dart';

class ListMealEntriesParams extends Equatable {
  final String uid;
  final String mealPlanId;

  const ListMealEntriesParams({required this.uid, required this.mealPlanId});

  @override
  List<Object?> get props => [uid, mealPlanId];
}