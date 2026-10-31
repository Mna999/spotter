import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:spotter/features/nutrition/domain/entities/dietary_preferences.dart';

class DietaryPreferencesModel extends DietaryPreferences {
  DietaryPreferencesModel({
    required super.uid,
    required super.excludedFoodIds,
    required super.excludedCategories,
    required super.targetKcal,
    required super.targetProteinG,
    required super.targetCarbG,
    required super.targetFatG,
    super.budgetEgp,
    super.dietTag,
    required super.schemaVersion,
    required super.createdAt,
    super.updatedAt,
  });

  // Convert model to JSON for Firestore
  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'excludedFoodIds': excludedFoodIds,
      'excludedCategories': excludedCategories,
      'targetKcal': targetKcal,
      'targetProteinG': targetProteinG,
      'targetCarbG': targetCarbG,
      'targetFatG': targetFatG,
      'budgetEgp': budgetEgp,
      'dietTag': dietTag,
      'schemaVersion': schemaVersion,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': updatedAt != null ? Timestamp.fromDate(updatedAt!) : null,
    };
  }

  // Create model from JSON (Firestore document)
  factory DietaryPreferencesModel.fromJson(Map<String, dynamic> json) {
    return DietaryPreferencesModel(
      uid: json['uid'],
      excludedFoodIds: Set<String>.from(json['excludedFoodIds'] ?? []),
      excludedCategories: Set<String>.from(json['excludedCategories'] ?? []),
      targetKcal: json['targetKcal'],
      targetProteinG: json['targetProteinG'],
      targetCarbG: json['targetCarbG'],
      targetFatG: json['targetFatG'],
      budgetEgp: json['budgetEgp']?.toDouble(),
      dietTag: json['dietTag'],
      schemaVersion: json['schemaVersion'],
      createdAt: (json['createdAt'] as Timestamp).toDate(),
      updatedAt: json['updatedAt'] != null ? (json['updatedAt'] as Timestamp).toDate() : null,
    );
  }

  // Create model from domain entity
  factory DietaryPreferencesModel.fromEntity(DietaryPreferences entity) {
    return DietaryPreferencesModel(
      uid: entity.uid,
      excludedFoodIds: entity.excludedFoodIds,
      excludedCategories: entity.excludedCategories,
      targetKcal: entity.targetKcal,
      targetProteinG: entity.targetProteinG,
      targetCarbG: entity.targetCarbG,
      targetFatG: entity.targetFatG,
      budgetEgp: entity.budgetEgp,
      dietTag: entity.dietTag,
      schemaVersion: entity.schemaVersion,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
    );
  }

  // Convert to domain entity
  DietaryPreferences toEntity() {
    return DietaryPreferences(
      uid: uid,
      excludedFoodIds: excludedFoodIds,
      excludedCategories: excludedCategories,
      targetKcal: targetKcal,
      targetProteinG: targetProteinG,
      targetCarbG: targetCarbG,
      targetFatG: targetFatG,
      budgetEgp: budgetEgp,
      dietTag: dietTag,
      schemaVersion: schemaVersion,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}