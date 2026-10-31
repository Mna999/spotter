import 'package:equatable/equatable.dart';
import 'package:spotter/features/nutrition/domain/entities/portion.dart';

class UpdateMealEntryParams extends Equatable {
  final String uid;
  final String mealPlanId;
  final String mealEntryId;
  final int? order;
  final Portion? portion;
  final double? servingsCount;
  final String? note;

  const UpdateMealEntryParams({
    required this.uid,
    required this.mealPlanId,
    required this.mealEntryId,
    this.order,
    this.portion,
    this.servingsCount,
    this.note,
  });

  @override
  List<Object?> get props => [
    uid,
    mealPlanId,
    mealEntryId,
    order,
    portion,
    servingsCount,
    note,
  ];
}
