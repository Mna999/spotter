import 'package:equatable/equatable.dart';

class Portion extends Equatable {
  /// Human readable label, e.g. `1 cup`.
  final String label;

  /// Mass equivalent of the portion, in grams.
  final double grams;

  /// Number of units when the portion is expressed as units (`2 slices`).
  final double? unitCount;

  const Portion({required this.label, required this.grams, this.unitCount});

  /// Mass of this portion in grams.
  ///
  /// When the portion is expressed in units ([unitCount]) and the mass of a
  /// single unit is known ([refGrams]), the unit count wins; otherwise the
  /// stored [grams] mass is returned.
  double toGrams({double? refGrams}) {
    if (unitCount != null && refGrams != null) {
      return unitCount! * refGrams;
    }
    return grams;
  }

  @override
  List<Object?> get props => [label, grams, unitCount];
}
