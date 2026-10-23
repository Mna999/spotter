import 'package:equatable/equatable.dart';
import 'cue_text.dart';

class Exercise extends Equatable {
  final String exerciseId;

  final String nameAr;

  final String nameEn;

  final List<int>? requiredLandmarks;

  final Map<String, dynamic>? repThresholds;

  final List<Map<String, dynamic>>? rules;

  final Map<String, CueText>? cues;

  final int schemaVersion;

  final DateTime createdAt;

  final DateTime? updatedAt;

  const Exercise({
    required this.exerciseId,
    required this.nameAr,
    required this.nameEn,
    this.requiredLandmarks,
    this.repThresholds,
    this.rules,
    this.cues,
    required this.schemaVersion,
    required this.createdAt,
    this.updatedAt,
  });

  @override
  List<Object?> get props => [
        exerciseId, nameAr, nameEn,
        requiredLandmarks, repThresholds, rules, cues,
        schemaVersion, createdAt, updatedAt,
      ];
}
