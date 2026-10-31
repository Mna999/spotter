import 'package:equatable/equatable.dart';

class BudgetParams extends Equatable {
  final String uid;
  final String prefsId;
  final double budgetEgp;

  const BudgetParams({
    required this.uid,
    required this.budgetEgp,
    required this.prefsId,
  });

  @override
  List<Object?> get props => [uid, budgetEgp, prefsId];
}
