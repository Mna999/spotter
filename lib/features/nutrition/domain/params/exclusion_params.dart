import 'package:equatable/equatable.dart';

class ExclusionParams extends Equatable {
  final String uid;
  final Set<String> excludedFoodIds;

  const ExclusionParams({required this.uid, required this.excludedFoodIds});

  @override
  List<Object?> get props => [uid, excludedFoodIds];
}
