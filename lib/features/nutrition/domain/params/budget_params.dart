import 'package:equatable/equatable.dart';

class BudgetParams extends Equatable {
  final String uid;
  final double budgetEgp;

  const BudgetParams({required this.uid, required this.budgetEgp});

  @override
  List<Object?> get props => [uid, budgetEgp];
}
