import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:spotter/core/constants.dart';
import 'package:spotter/core/input_converter/input_parser.dart';
import 'package:spotter/features/nutrition/domain/entities/meal_plan.dart';
import 'package:spotter/features/nutrition/domain/entities/plan_status.dart';

class MealPlanModel extends MealPlan {
  MealPlanModel({
    required super.mealPlanId,
    required super.uid,
    required super.date,
    super.budgetEgp,
    required super.totalKcal,
    required super.costEgp,
    required super.status,
    required super.schemaVersion,
    required super.createdAt,
    super.updatedAt,
  });

  // Convert model to JSON for Firestore
  Map<String, dynamic> toJson() {
    return {
      'mealPlanId': mealPlanId,
      'uid': uid,
      'date': Timestamp.fromDate(date),
      'budgetEgp': budgetEgp,
      'totalKcal': totalKcal,
      'costEgp': costEgp,
      'status': status.name,
      'schemaVersion': schemaVersion,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': updatedAt != null ? Timestamp.fromDate(updatedAt!) : null,
    };
  }

  // Create model from JSON (Firestore document). [docId] is the document id,
  // which is the source of truth when the stored body predates that field.
  factory MealPlanModel.fromJson(Map<String, dynamic> json, {String? docId}) {
    return MealPlanModel(
      mealPlanId: docId ?? json['mealPlanId'] ?? '',
      uid: json['uid'],
      date: (json['date'] as Timestamp).toDate(),
      budgetEgp: (json['budgetEgp'] as num?)?.toDouble(),
      totalKcal: (json['totalKcal'] as num?)?.toDouble() ?? 0,
      costEgp: (json['costEgp'] as num?)?.toDouble() ?? 0,
      status: PlanStatus.fromString(json['status'] ?? 'draft'),
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
  factory MealPlanModel.fromEntity(MealPlan entity) {
    return MealPlanModel(
      mealPlanId: entity.mealPlanId,
      uid: entity.uid,
      date: entity.date,
      budgetEgp: entity.budgetEgp,
      totalKcal: entity.totalKcal,
      costEgp: entity.costEgp,
      status: entity.status,
      schemaVersion: entity.schemaVersion,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
    );
  }

  // Convert to domain entity
  MealPlan toEntity() {
    return MealPlan(
      mealPlanId: mealPlanId,
      uid: uid,
      date: date,
      budgetEgp: budgetEgp,
      totalKcal: totalKcal,
      costEgp: costEgp,
      status: status,
      schemaVersion: schemaVersion,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  /// Returns a copy of this model carrying [id] as its document id.
  MealPlanModel withId(String id) {
    return MealPlanModel(
      mealPlanId: id,
      uid: uid,
      date: date,
      budgetEgp: budgetEgp,
      totalKcal: totalKcal,
      costEgp: costEgp,
      status: status,
      schemaVersion: schemaVersion,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}