import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:spotter/core/constants.dart';
import 'package:spotter/features/workouts/domain/entities/session_status.dart';
import 'package:spotter/features/workouts/domain/entities/workout_session.dart';

class WorkoutSessionModel extends WorkoutSession {
  WorkoutSessionModel({
    required super.workoutId,
    required super.uid,
    super.name,
    required super.status,
    super.avgHr,
    super.currentIndex,
    super.endedAt,
    super.maxHr,
    super.meanFormScore,
    super.scheduledFor,
    super.startedAt,
    required super.schemaVersion,
    required super.createdAt,
    super.updatedAt,
  });

  factory WorkoutSessionModel.fromJson(Map<String, dynamic> json) {
    final startedAt = (json['startedAt'] as Timestamp?)?.toDate();
    final scheduledFor = (json['scheduledFor'] as Timestamp?)?.toDate();
    final endedAt = (json['endedAt'] as Timestamp?)?.toDate();
    var status = SessionStatus.fromString(json['status'] as String);

    // Older documents were saved with an end time but never had their status
    // updated, so treat them as finished instead of showing a stale live
    // session forever.
    if (endedAt != null &&
        (status == SessionStatus.inProgress || status == SessionStatus.paused)) {
      status = SessionStatus.finished;
    }

    final name = (json['name'] as String?)?.trim();

    return WorkoutSessionModel(
      workoutId: json['workoutId'] as String,
      uid: json['uid'] as String,
      name: (name == null || name.isEmpty) ? 'Workout' : name,
      status: status,
      startedAt: startedAt,
      scheduledFor: scheduledFor,
      endedAt: endedAt,
      avgHr: (json['avgHr'] as num?)?.toInt(),
      currentIndex: (json['currentIndex'] as num?)?.toInt() ?? 0,
      maxHr: (json['maxHr'] as num?)?.toInt(),
      meanFormScore: (json['meanFormScore'] as num?)?.toDouble(),
      schemaVersion: (json['schemaVersion'] as num?)?.toInt() ?? SCHEMA_VERSION,
      createdAt:
          (json['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (json['updatedAt'] as Timestamp?)?.toDate(),
    );
  }

  factory WorkoutSessionModel.fromEntity(WorkoutSession w) {
    return WorkoutSessionModel(
      workoutId: w.workoutId,
      uid: w.uid,
      name: w.name,
      status: w.status,
      startedAt: w.startedAt,
      scheduledFor: w.scheduledFor,
      endedAt: w.endedAt,
      avgHr: w.avgHr,
      currentIndex: w.currentIndex,
      maxHr: w.maxHr,
      meanFormScore: w.meanFormScore,
      schemaVersion: w.schemaVersion,
      createdAt: w.createdAt,
      updatedAt: w.updatedAt,
    );
  }

  Map<String, dynamic> toJson({bool isCreating = false}) {
    return {
      'workoutId': workoutId,
      'uid': uid,
      'name': name,
      'status': status.name,
      'startedAt': startedAt != null ? Timestamp.fromDate(startedAt!) : null,
      'scheduledFor': scheduledFor != null
          ? Timestamp.fromDate(scheduledFor!)
          : null,
      'endedAt': endedAt != null ? Timestamp.fromDate(endedAt!) : null,
      'avgHr': avgHr,
      'currentIndex': currentIndex,
      'maxHr': maxHr,
      'meanFormScore': meanFormScore,
      'createdAt': isCreating ? FieldValue.serverTimestamp() : createdAt,
      'updatedAt': FieldValue.serverTimestamp(),
      'schemaVersion': SCHEMA_VERSION,
    };
  }
}
