import 'package:equatable/equatable.dart';

class CreateMealPlanParams extends Equatable {
  final String uid;
  final DateTime date;
  final double? budgetEgp;

  const CreateMealPlanParams({
    required this.uid,
    required this.date,
    this.budgetEgp,
  });

  @override
  List<Object?> get props => [uid, date, budgetEgp];
}
