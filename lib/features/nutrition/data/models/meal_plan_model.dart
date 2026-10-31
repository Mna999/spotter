import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:spotter/features/nutrition/domain/entities/meal_plan.dart';
import 'package:spotter/features/nutrition/domain/entities/plan_status.dart';
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
      'status': status.toString(),
      'schemaVersion': schemaVersion,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': updatedAt != null ? Timestamp.fromDate(updatedAt!) : null,
    };
  }

  // Create model from JSON (Firestore document)
  factory MealPlanModel.fromJson(Map<String, dynamic> json) {
    return MealPlanModel(
      mealPlanId: json['mealPlanId'],
      uid: json['uid'],
      date: (json['date'] as Timestamp).toDate(),
      budgetEgp: json['budgetEgp']?.toDouble(),
      totalKcal: json['totalKcal'],
      costEgp: json['costEgp'],
      status: PlanStatus.fromString(json['status']),
      schemaVersion: json['schemaVersion'],
      createdAt: (json['createdAt'] as Timestamp).toDate(),
      updatedAt: json['updatedAt'] != null ? (json['updatedAt'] as Timestamp).toDate() : null,
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
}