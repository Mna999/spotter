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
    return MacroNutrientsModel(
      energyKcal: json['energyKcal'],
      proteinG: json['proteinG'],
      fatG: json['fatG'],
      carbohydrateG: json['carbohydrateG'],
      fiberG: json['fiberG'],
      waterG: json['waterG'],
      ashG: json['ashG'],
      refusePct: json['refusePct'],
      mineralsMg: Map<String, double>.from(json['mineralsMg'] ?? {}),
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