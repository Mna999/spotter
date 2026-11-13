import 'package:equatable/equatable.dart';

class ExclusionParams extends Equatable {
  final String uid;
  final String prefsId;
  final Set<String> excludedFoodIds;

  /// Null leaves the stored categories untouched.
  final Set<String>? excludedCategories;

  const ExclusionParams({
    required this.uid,
    required this.excludedFoodIds,
    required this.prefsId,
    this.excludedCategories,
  });

  @override
  List<Object?> get props => [
    uid,
    excludedFoodIds,
    prefsId,
    excludedCategories,
  ];
}
