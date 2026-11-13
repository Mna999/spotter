import 'package:equatable/equatable.dart';

class UpdatePlannerSettingsParams extends Equatable {
  final String uid;
  final String prefsId;
  final double? budgetEgp;
  final String? dietTag;

  const UpdatePlannerSettingsParams({
    required this.uid,
    required this.prefsId,
    this.budgetEgp,
    this.dietTag,
  });

  @override
  List<Object?> get props => [uid, prefsId, budgetEgp, dietTag];
}
