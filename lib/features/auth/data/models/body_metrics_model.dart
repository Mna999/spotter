import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:spotter/features/auth/domain/entities/body_metrics.dart';

class BodyMetricsModel extends BodyMetrics {
  BodyMetricsModel({
    required super.bmi,
    required super.ree,
    required super.tdee,
    required super.macroTargets,
  });

  factory BodyMetricsModel.fromJson(Map<String, dynamic> json) {
    return BodyMetricsModel(
      bmi: (json['bmi'] as num).toDouble(),
      ree: (json['ree'] as num).toDouble(),
      tdee: (json['tdee'] as num).toDouble(),
      macroTargets: MacroTargets.fromJson(
        Map<String, dynamic>.from(json['macroTargets'] as Map),
      ),
    );
  }

  Map<String, dynamic> toJson() => {
    'bmi': bmi,
    'ree': ree,
    'tdee': tdee,
    'macroTargets': macroTargets.toJson(),
    'updatedAt': FieldValue.serverTimestamp(),
  };
}
