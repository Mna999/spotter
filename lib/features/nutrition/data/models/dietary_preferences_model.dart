import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:spotter/core/constants.dart';
import 'package:spotter/core/input_converter/input_parser.dart';
import 'package:spotter/features/nutrition/domain/entities/dietary_preferences.dart';

class DietaryPreferencesModel extends DietaryPreferences {
  const DietaryPreferencesModel({
    required super.uid,
    required super.prefsId,
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
      'prefsId': prefsId,
      'excludedFoodIds': excludedFoodIds.toList(),
      'excludedCategories': excludedCategories.toList(),
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

  // Create model from JSON (Firestore document). [docId] is the document id,
  // which is the source of truth when the stored body predates that field.
  factory DietaryPreferencesModel.fromJson(
    Map<String, dynamic> json, {
    String? docId,
  }) {
    return DietaryPreferencesModel(
      prefsId: docId ?? json['prefsId'] ?? '',
      uid: json['uid'] ?? '',
      excludedFoodIds: Set<String>.from(json['excludedFoodIds'] ?? []),
      excludedCategories: Set<String>.from(json['excludedCategories'] ?? []),
      targetKcal: (json['targetKcal'] as num?)?.toDouble() ?? 0,
      targetProteinG: (json['targetProteinG'] as num?)?.toDouble() ?? 0,
      targetCarbG: (json['targetCarbG'] as num?)?.toDouble() ?? 0,
      targetFatG: (json['targetFatG'] as num?)?.toDouble() ?? 0,
      budgetEgp: json['budgetEgp']?.toDouble(),
      dietTag: json['dietTag'],

      schemaVersion: (json['schemaVersion'] as num?)?.toInt() ?? SCHEMA_VERSION,
      createdAt:
          InputParser.toDateTime(json['createdAt']) ??
          DateTime.fromMillisecondsSinceEpoch(0),
      updatedAt:
          InputParser.toDateTime(json['updatedAt']) ??
          DateTime.fromMillisecondsSinceEpoch(0),
    );
  }

  // Create model from domain entity
  factory DietaryPreferencesModel.fromEntity(DietaryPreferences entity) {
    return DietaryPreferencesModel(
      prefsId: entity.prefsId,
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
      prefsId: prefsId,
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
