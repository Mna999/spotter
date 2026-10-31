import 'package:equatable/equatable.dart';

class MacroNutrients extends Equatable {
  final double energyKcal;
  final double proteinG;
  final double fatG;
  final double carbohydrateG;
  final double fiberG;
  final double waterG;
  final double ashG;
  final int refusePct;
  final Map<String, double> mineralsMg;
  final Map<String, dynamic> vitamins;

  const MacroNutrients({
    required this.energyKcal,
    required this.proteinG,
    required this.fatG,
    required this.carbohydrateG,
    required this.fiberG,
    required this.waterG,
    required this.ashG,
    required this.refusePct,
    required this.mineralsMg,
    required this.vitamins,
  });

  /// Neutral element for aggregations (empty day, empty list of logs).
  static const MacroNutrients zero = MacroNutrients(
    energyKcal: 0,
    proteinG: 0,
    fatG: 0,
    carbohydrateG: 0,
    fiberG: 0,
    waterG: 0,
    ashG: 0,
    refusePct: 0,
    mineralsMg: <String, double>{},
    vitamins: <String, dynamic>{},
  );

  /// Energy-only nutrients, used when only the denormalised kcal of a log is
  /// known (e.g. the food was removed from the shared catalogue).
  const MacroNutrients.energyOnly(this.energyKcal)
    : proteinG = 0,
      fatG = 0,
      carbohydrateG = 0,
      fiberG = 0,
      waterG = 0,
      ashG = 0,
      refusePct = 0,
      mineralsMg = const <String, double>{},
      vitamins = const <String, dynamic>{};
      
  MacroNutrients operator +(MacroNutrients other) {
    return MacroNutrients(
      energyKcal: energyKcal + other.energyKcal,
      proteinG: proteinG + other.proteinG,
      fatG: fatG + other.fatG,
      carbohydrateG: carbohydrateG + other.carbohydrateG,
      fiberG: fiberG + other.fiberG,
      waterG: waterG + other.waterG,
      ashG: ashG + other.ashG,
      refusePct: refusePct + other.refusePct,
      mineralsMg: _mergeNumeric(mineralsMg, other.mineralsMg),
      vitamins: _mergeVitamins(vitamins, other.vitamins),
    );
  }

  MacroNutrients scale(double factor) {
    return MacroNutrients(
      energyKcal: energyKcal * factor,
      proteinG: proteinG * factor,
      fatG: fatG * factor,
      carbohydrateG: carbohydrateG * factor,
      fiberG: fiberG * factor,
      waterG: waterG * factor,
      ashG: ashG * factor,
      refusePct: refusePct, // a percentage, doesn't scale
      mineralsMg: mineralsMg.map((k, v) => MapEntry(k, v * factor)),
      vitamins: vitamins.map((k, v) => MapEntry(k, v is num ? v * factor : v)),
    );
  }

  static Map<String, double> _mergeNumeric(
    Map<String, double> a,
    Map<String, double> b,
  ) {
    final result = Map<String, double>.from(a);
    b.forEach((key, value) {
      result[key] = (result[key] ?? 0) + value;
    });
    return result;
  }

  static Map<String, dynamic> _mergeVitamins(
    Map<String, dynamic> a,
    Map<String, dynamic> b,
  ) {
    final result = Map<String, dynamic>.from(a);
    b.forEach((key, value) {
      final existing = result[key];
      if (existing is num && value is num) {
        result[key] = existing + value;
      } else {
        result[key] = existing ?? value; // non-numeric: keep first
      }
    });
    return result;
  }

  @override
  List<Object?> get props => [
    energyKcal,
    proteinG,
    fatG,
    carbohydrateG,
    fiberG,
    waterG,
    ashG,
    refusePct,
    mineralsMg,
    vitamins,
  ];
}
