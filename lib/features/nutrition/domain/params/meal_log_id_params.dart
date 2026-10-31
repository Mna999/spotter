import 'package:equatable/equatable.dart';

class MealLogIdParams extends Equatable {
  final String uid;
  final String mealLogId;

  const MealLogIdParams({required this.uid, required this.mealLogId});

  @override
  List<Object?> get props => [uid, mealLogId];
}
