import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:spotter/core/constants.dart';
import 'package:spotter/core/input_converter/input_parser.dart';
import 'package:spotter/features/nutrition/domain/entities/meal_entry.dart';
import 'package:spotter/features/nutrition/domain/entities/meal_type.dart';
import 'package:spotter/features/nutrition/data/models/portion_model.dart';

class MealEntryModel extends MealEntry {
  MealEntryModel({
    required super.mealEntryId,
    required super.mealPlanId,
    required super.uid,
    required super.foodId,
    required super.mealType,
    required super.order,
    required super.portion,
    required super.servingsCount,
    super.note,
    required super.schemaVersion,
    required super.createdAt,
    super.updatedAt,
  });

  // Convert model to JSON for Firestore
  Map<String, dynamic> toJson() {
    return {
      'mealEntryId': mealEntryId,
      'mealPlanId': mealPlanId,
      'uid': uid,
      'foodId': foodId,
      'mealType': mealType.name,
      'order': order,
      'portion': PortionModel.fromEntity(portion).toJson(),
      'servingsCount': servingsCount,
      'note': note,
      'schemaVersion': schemaVersion,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': updatedAt != null ? Timestamp.fromDate(updatedAt!) : null,
    };
  }

  // Create model from JSON (Firestore document). [docId] is the document id,
  // which is the source of truth when the stored body predates that field.
  factory MealEntryModel.fromJson(Map<String, dynamic> json, {String? docId}) {
    return MealEntryModel(
      mealEntryId: docId ?? json['mealEntryId'] ?? '',
      mealPlanId: json['mealPlanId'],
      uid: json['uid'],
      foodId: json['foodId'],
      mealType: MealType.fromString(json['mealType'] ?? 'snack'),
      order: (json['order'] as num?)?.toInt() ?? 0,
      portion: PortionModel.fromJson(json['portion']).toEntity(),
      servingsCount: (json['servingsCount'] as num?)?.toDouble() ?? 1,
      note: json['note'],
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
  factory MealEntryModel.fromEntity(MealEntry entity) {
    return MealEntryModel(
      mealEntryId: entity.mealEntryId,
      mealPlanId: entity.mealPlanId,
      uid: entity.uid,
      foodId: entity.foodId,
      mealType: entity.mealType,
      order: entity.order,
      portion: entity.portion,
      servingsCount: entity.servingsCount,
      note: entity.note,
      schemaVersion: entity.schemaVersion,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
    );
  }

  // Convert to domain entity
  MealEntry toEntity() {
    return MealEntry(
      mealEntryId: mealEntryId,
      mealPlanId: mealPlanId,
      uid: uid,
      foodId: foodId,
      mealType: mealType,
      order: order,
      portion: portion,
      servingsCount: servingsCount,
      note: note,
      schemaVersion: schemaVersion,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  /// Returns a copy of this model carrying [id] as its document id.
  MealEntryModel withId(String id) {
    return MealEntryModel(
      mealEntryId: id,
      mealPlanId: mealPlanId,
      uid: uid,
      foodId: foodId,
      mealType: mealType,
      order: order,
      portion: portion,
      servingsCount: servingsCount,
      note: note,
      schemaVersion: schemaVersion,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}