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
      budgetEgp: (json['budgetEgp'] as num?)?.toDouble(),
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
      budgetEgp: entity.budgetEgp,
      dietTag: entity.dietTag,
      schemaVersion: entity.schemaVersion,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
    );
  }

  /// Returns a copy of this model carrying [id] as its document id.
  DietaryPreferencesModel withId(String id) {
    return DietaryPreferencesModel(
      prefsId: id,
      uid: uid,
      excludedFoodIds: excludedFoodIds,
      excludedCategories: excludedCategories,
      budgetEgp: budgetEgp,
      dietTag: dietTag,
      schemaVersion: schemaVersion,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  // Convert to domain entity
  DietaryPreferences toEntity() {
    return DietaryPreferences(
      prefsId: prefsId,
      uid: uid,
      excludedFoodIds: excludedFoodIds,
      excludedCategories: excludedCategories,
      budgetEgp: budgetEgp,
      dietTag: dietTag,
      schemaVersion: schemaVersion,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}
