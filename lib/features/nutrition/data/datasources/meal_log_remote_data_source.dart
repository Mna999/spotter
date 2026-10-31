import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:spotter/core/error/exception.dart';
import 'package:spotter/features/nutrition/data/models/meal_log_model.dart';
import 'package:spotter/features/nutrition/domain/entities/meal_log.dart';

abstract class MealLogRemoteDataSource {
  /// Save a meal log
  Future<MealLog> save({required String uid, required MealLog log});

  /// Get a meal log by ID
  Future<MealLog?> get({required String uid, required String mealLogId});

  /// Get meal logs for a specific date
  Future<List<MealLog>> listForDate({
    required String uid,
    required DateTime date,
  });

  /// Get meal logs within a date range
  Future<List<MealLog>> inRange({
    required String uid,
    required DateTime start,
    required DateTime end,
  });

  /// Update partial meal log fields
  Future<MealLog> update({
    required String uid,
    required String mealLogId,
    required Map<String, dynamic> partial,
  });

  /// Delete a meal log
  Future<void> delete({required String uid, required String mealLogId});
}

class MealLogRemoteDataSourceImpl implements MealLogRemoteDataSource {
  final FirebaseFirestore _firestore;

  MealLogRemoteDataSourceImpl({required this._firestore});

  @override
  Future<void> delete({required String uid, required String mealLogId}) async {
    try {
      await _firestore.collection('mealLogs').doc(mealLogId).delete();
    } on FirebaseException catch (e) {
      throw ServerException(code: e.code);
    }
  }

  @override
  Future<MealLog?> get({required String uid, required String mealLogId}) async {
    try {
      final doc = await _firestore.collection('mealLogs').doc(mealLogId).get();

      final data = doc.data();

      if (data == null || data.isEmpty) return null;

      final model = MealLogModel.fromJson(data);
      return model.toEntity();
    } on FirebaseException catch (e) {
      throw ServerException(code: e.code);
    }
  }

  @override
  Future<List<MealLog>> inRange({
    required String uid,
    required DateTime start,
    required DateTime end,
  }) async {
    try {
      // Create date range filters
      final startOfDay = DateTime(start.year, start.month, start.day);
      final endOfDay = DateTime(end.year, end.month, end.day, 23, 59, 59);

      final snapshot = await _firestore
          .collection('mealLogs')
          .where('uid', isEqualTo: uid)
          .where('loggedAt', isGreaterThanOrEqualTo: startOfDay)
          .where('loggedAt', isLessThanOrEqualTo: endOfDay)
          .orderBy('loggedAt', descending: true)
          .get();

      return snapshot.docs
          .map((doc) => MealLogModel.fromJson(doc.data()).toEntity())
          .toList();
    } on FirebaseException catch (e) {
      throw ServerException(code: e.code);
    }
  }

  @override
  Future<List<MealLog>> listForDate({
    required String uid,
    required DateTime date,
  }) async {
    try {
      // Create start and end of day
      final startOfDay = DateTime(date.year, date.month, date.day);
      final endOfDay = DateTime(date.year, date.month, date.day, 23, 59, 59);

      final snapshot = await _firestore
          .collection('mealLogs')
          .where('uid', isEqualTo: uid)
          .where('loggedAt', isGreaterThanOrEqualTo: startOfDay)
          .where('loggedAt', isLessThanOrEqualTo: endOfDay)
          .orderBy('loggedAt', descending: true)
          .get();

      return snapshot.docs
          .map((doc) => MealLogModel.fromJson(doc.data()).toEntity())
          .toList();
    } on FirebaseException catch (e) {
      throw ServerException(code: e.code);
    }
  }

  @override
  Future<MealLog> save({required String uid, required MealLog log}) async {
    try {
      final model = MealLogModel.fromEntity(log);

      await _firestore
          .collection('mealLogs')
          .doc(log.mealLogId)
          .set(model.toJson());

      return log;
    } on FirebaseException catch (e) {
      throw ServerException(code: e.code);
    }
  }

  @override
  Future<MealLog> update({
    required String uid,
    required String mealLogId,
    required Map<String, dynamic> partial,
  }) async {
    try {
      final docRef = _firestore.collection('mealLogs').doc(mealLogId);

      // Add timestamp for update
      partial['updatedAt'] = FieldValue.serverTimestamp();

      await docRef.update(partial);

      // Get updated document
      final doc = await docRef.get();
      final model = MealLogModel.fromJson(doc.data()!);
      return model.toEntity();
    } on FirebaseException catch (e) {
      throw ServerException(code: e.code);
    }
  }
}
