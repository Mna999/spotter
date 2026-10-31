import 'package:spotter/features/nutrition/domain/entities/portion.dart';

class PortionModel extends Portion {
  const PortionModel({
    required super.label,
    required super.grams,
    super.unitCount,
  });

  // Convert model to JSON for Firestore
  Map<String, dynamic> toJson() {
    return {'label': label, 'grams': grams, 'unitCount': unitCount};
  }

  // Create model from JSON (Firestore document)
  factory PortionModel.fromJson(Map<String, dynamic> json) {
    return PortionModel(
      label: json['label'] ?? '100 g',
      grams: (json['grams'] as num?)?.toDouble() ?? 100,
      unitCount: (json['unitCount'] as num?)?.toDouble(),
    );
  }

  // Create model from domain entity
  factory PortionModel.fromEntity(Portion entity) {
    return PortionModel(
      label: entity.label,
      grams: entity.grams,
      unitCount: entity.unitCount,
    );
  }

  // Convert to domain entity
  Portion toEntity() {
    return Portion(label: label, grams: grams, unitCount: unitCount);
  }
}
