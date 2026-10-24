import 'package:equatable/equatable.dart';

import 'session_status.dart';

class WorkoutSession extends Equatable {
  String workoutId;

  String uid;

  DateTime? startedAt;

  DateTime? scheduledFor;

  DateTime? endedAt;

  SessionStatus status;

  int? avgHr;

  int? maxHr;

  double? meanFormScore;

  int currentIndex;

  int schemaVersion;

  DateTime createdAt;

  DateTime? updatedAt;

  WorkoutSession({
    required this.workoutId,
    required this.uid,
    this.startedAt,
    this.scheduledFor,
    this.endedAt,
    required this.status,
    this.avgHr,
    this.maxHr,
    this.meanFormScore,

    this.currentIndex = 0,
    required this.schemaVersion,
    required this.createdAt,
    this.updatedAt,
  });

  WorkoutSession copyWith({
    String? workoutId,
    String? uid,
    DateTime? startedAt,
    DateTime? scheduledFor,
    DateTime? endedAt,
    SessionStatus? status,
    int? avgHr,
    int? maxHr,
    double? meanFormScore,
    int? schemaVersion,
    DateTime? createdAt,
    DateTime? updatedAt,
    int? currentIndex,
  }) => WorkoutSession(
    workoutId: workoutId ?? this.workoutId,
    uid: uid ?? this.uid,
    startedAt: startedAt ?? this.startedAt,
    scheduledFor: scheduledFor ?? this.scheduledFor,
    endedAt: endedAt ?? this.endedAt,
    status: status ?? this.status,
    avgHr: avgHr ?? this.avgHr,
    maxHr: maxHr ?? this.maxHr,
    meanFormScore: meanFormScore ?? this.meanFormScore,

    currentIndex: currentIndex ?? this.currentIndex,
    schemaVersion: schemaVersion ?? this.schemaVersion,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );

  @override
  List<Object?> get props => [
    workoutId,
    uid,
    startedAt,
    scheduledFor,
    endedAt,
    status,
    avgHr,
    maxHr,
    meanFormScore,

    currentIndex,
    schemaVersion,
    createdAt,
    updatedAt,
  ];
}
