import 'package:spotter/features/nutrition/domain/entities/macro_nutrients.dart';

class MacroNutrientsModel extends MacroNutrients {
  MacroNutrientsModel({
    required super.energyKcal,
    required super.proteinG,
    required super.fatG,
    required super.carbohydrateG,
    required super.fiberG,
    required super.waterG,
    required super.ashG,
    required super.refusePct,
    required super.mineralsMg,
    required super.vitamins,
  });

  // Convert model to JSON for Firestore
  Map<String, dynamic> toJson() {
    return {
      'energyKcal': energyKcal,
      'proteinG': proteinG,
      'fatG': fatG,
      'carbohydrateG': carbohydrateG,
      'fiberG': fiberG,
      'waterG': waterG,
      'ashG': ashG,
      'refusePct': refusePct,
      'mineralsMg': mineralsMg,
      'vitamins': vitamins,
    };
  }

  // Create model from JSON (Firestore document)
  factory MacroNutrientsModel.fromJson(Map<String, dynamic> json) {
    final minerals = json['mineralsMg'] as Map?;
    return MacroNutrientsModel(
      energyKcal: (json['energyKcal'] as num?)?.toDouble() ?? 0,
      proteinG: (json['proteinG'] as num?)?.toDouble() ?? 0,
      fatG: (json['fatG'] as num?)?.toDouble() ?? 0,
      carbohydrateG: (json['carbohydrateG'] as num?)?.toDouble() ?? 0,
      fiberG: (json['fiberG'] as num?)?.toDouble() ?? 0,
      waterG: (json['waterG'] as num?)?.toDouble() ?? 0,
      ashG: (json['ashG'] as num?)?.toDouble() ?? 0,
      refusePct: (json['refusePct'] as num?)?.toInt() ?? 0,
      mineralsMg: minerals == null
          ? const <String, double>{}
          : minerals.map(
              (key, value) =>
                  MapEntry(key as String, (value as num?)?.toDouble() ?? 0),
            ),
      vitamins: Map<String, dynamic>.from(json['vitamins'] ?? {}),
    );
  }

  // Create model from domain entity
  factory MacroNutrientsModel.fromEntity(MacroNutrients entity) {
    return MacroNutrientsModel(
      energyKcal: entity.energyKcal,
      proteinG: entity.proteinG,
      fatG: entity.fatG,
      carbohydrateG: entity.carbohydrateG,
      fiberG: entity.fiberG,
      waterG: entity.waterG,
      ashG: entity.ashG,
      refusePct: entity.refusePct,
      mineralsMg: entity.mineralsMg,
      vitamins: entity.vitamins,
    );
  }

  // Convert to domain entity
  MacroNutrients toEntity() {
    return MacroNutrients(
      energyKcal: energyKcal,
      proteinG: proteinG,
      fatG: fatG,
      carbohydrateG: carbohydrateG,
      fiberG: fiberG,
      waterG: waterG,
      ashG: ashG,
      refusePct: refusePct,
      mineralsMg: mineralsMg,
      vitamins: vitamins,
    );
  }
}