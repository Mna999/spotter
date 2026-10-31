import 'package:equatable/equatable.dart';
import 'package:spotter/features/nutrition/domain/entities/portion.dart';

class UpdateMealLogParams extends Equatable {
  final String uid;
  final String mealLogId;
  final Portion? portion;
  final double? servingsCount;
  final String? note;

  const UpdateMealLogParams({
    required this.uid,
    required this.mealLogId,
    this.portion,
    this.servingsCount,
    this.note,
  });

  @override
  List<Object?> get props => [uid, mealLogId, portion, servingsCount, note];
}
