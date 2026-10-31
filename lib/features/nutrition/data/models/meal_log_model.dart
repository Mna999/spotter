import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:spotter/core/constants.dart';
import 'package:spotter/core/input_converter/input_parser.dart';
import 'package:spotter/features/nutrition/domain/entities/meal_log.dart';
import 'package:spotter/features/nutrition/domain/entities/meal_type.dart';
import 'package:spotter/features/nutrition/data/models/portion_model.dart';

class MealLogModel extends MealLog {
  MealLogModel({
    required super.mealLogId,
    required super.uid,
    required super.foodId,
    required super.mealType,
    required super.portion,
    required super.servingsCount,
    required super.computedKcal,
    required super.loggedAt,
    super.note,
    required super.schemaVersion,
    required super.createdAt,
    super.updatedAt,
  });

  // Convert model to JSON for Firestore
  Map<String, dynamic> toJson() {
    return {
      'mealLogId': mealLogId,
      'uid': uid,
      'foodId': foodId,
      'mealType': mealType.name,
      'portion': PortionModel.fromEntity(portion).toJson(),
      'servingsCount': servingsCount,
      'computedKcal': computedKcal,
      'loggedAt': Timestamp.fromDate(loggedAt),
      'note': note,
      'schemaVersion': schemaVersion,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': updatedAt != null ? Timestamp.fromDate(updatedAt!) : null,
    };
  }

  // Create model from JSON (Firestore document). [docId] is the document id,
  // which is the source of truth when the stored body predates that field.
  factory MealLogModel.fromJson(Map<String, dynamic> json, {String? docId}) {
    return MealLogModel(
      mealLogId: docId ?? json['mealLogId'] ?? '',
      uid: json['uid'],
      foodId: json['foodId'],
      mealType: MealType.fromString(json['mealType']),
      portion: PortionModel.fromJson(json['portion']).toEntity(),
      servingsCount: (json['servingsCount'] as num?)?.toDouble() ?? 1,
      computedKcal: (json['computedKcal'] as num?)?.toDouble() ?? 0,
      loggedAt: (json['loggedAt'] as Timestamp).toDate(),
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
  factory MealLogModel.fromEntity(MealLog entity) {
    return MealLogModel(
      mealLogId: entity.mealLogId,
      uid: entity.uid,
      foodId: entity.foodId,
      mealType: entity.mealType,
      portion: entity.portion,
      servingsCount: entity.servingsCount,
      computedKcal: entity.computedKcal,
      loggedAt: entity.loggedAt,
      note: entity.note,
      schemaVersion: entity.schemaVersion,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
    );
  }

  // Convert to domain entity
  MealLog toEntity() {
    return MealLog(
      mealLogId: mealLogId,
      uid: uid,
      foodId: foodId,
      mealType: mealType,
      portion: portion,
      servingsCount: servingsCount,
      computedKcal: computedKcal,
      loggedAt: loggedAt,
      note: note,
      schemaVersion: schemaVersion,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  /// Returns a copy of this model carrying [id] as its document id.
  MealLogModel withId(String id) {
    return MealLogModel(
      mealLogId: id,
      uid: uid,
      foodId: foodId,
      mealType: mealType,
      portion: portion,
      servingsCount: servingsCount,
      computedKcal: computedKcal,
      loggedAt: loggedAt,
      note: note,
      schemaVersion: schemaVersion,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}