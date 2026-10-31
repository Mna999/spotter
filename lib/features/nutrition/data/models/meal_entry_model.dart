import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:spotter/features/nutrition/domain/entities/meal_entry.dart';
import 'package:spotter/features/nutrition/domain/entities/meal_type.dart';
import 'package:spotter/features/nutrition/data/models/portion_model.dart';
import 'package:spotter/features/nutrition/domain/entities/meal_type.dart';
import 'package:spotter/features/nutrition/domain/entities/portion.dart';

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
      'mealType': mealType.toString(),
      'order': order,
      'portion': PortionModel.fromEntity(portion).toJson(),
      'servingsCount': servingsCount,
      'note': note,
      'schemaVersion': schemaVersion,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': updatedAt != null ? Timestamp.fromDate(updatedAt!) : null,
    };
  }

  // Create model from JSON (Firestore document)
  factory MealEntryModel.fromJson(Map<String, dynamic> json) {
    return MealEntryModel(
      mealEntryId: json['mealEntryId'],
      mealPlanId: json['mealPlanId'],
      uid: json['uid'],
      foodId: json['foodId'],
      mealType: MealType.fromString(json['mealType']),
      order: json['order'],
      portion: PortionModel.fromJson(json['portion']).toEntity(),
      servingsCount: json['servingsCount'],
      note: json['note'],
      schemaVersion: json['schemaVersion'],
      createdAt: (json['createdAt'] as Timestamp).toDate(),
      updatedAt: json['updatedAt'] != null ? (json['updatedAt'] as Timestamp).toDate() : null,
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
}