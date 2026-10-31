import 'package:equatable/equatable.dart';

class ExclusionParams extends Equatable {
  final String uid;
  final String prefsId;
  final Set<String> excludedFoodIds;

  const ExclusionParams({required this.uid, required this.excludedFoodIds,required this.prefsId});

  @override
  List<Object?> get props => [uid, excludedFoodIds,prefsId];
}
