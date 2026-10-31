import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:spotter/core/error/exception.dart';
import 'package:spotter/features/nutrition/data/models/dietary_preferences_model.dart';
import 'package:spotter/features/nutrition/domain/entities/dietary_preferences.dart';

abstract class NutritionPreferencesRemoteDataSource {
  /// Get dietary preferences for a user
  Future<DietaryPreferences?> get({
    required String uid,
    required String prefsId,
  });

  /// Save dietary preferences for a user
  Future<DietaryPreferences> save({
    required String uid,
    required DietaryPreferences prefs,
  });

  /// Update excluded food IDs
  Future<DietaryPreferences> updateExclusions({
    required String uid,
    required Set<String> excludedFoodIds,
    required String prefsId,
  });

  /// Update partial preferences
  Future<DietaryPreferences> update({
    required String uid,
    required Map<String, dynamic> partial,
    required String prefsId,
  });
}

class NutritionPreferencesRemoteDataSourceImpl
    implements NutritionPreferencesRemoteDataSource {
  final FirebaseFirestore _firestore;

  NutritionPreferencesRemoteDataSourceImpl({required this._firestore});

  @override
  Future<DietaryPreferences?> get({
    required String uid,
    required String prefsId,
  }) async {
    try {
      final doc = await _firestore
          .collection('users')
          .doc(uid)
          .collection('dietaryPreferences')
          .doc(prefsId)
          .get();

      final data = doc.data();
      if (data == null || data.isEmpty) return null;
      final model = DietaryPreferencesModel.fromJson(data, docId: doc.id);
      return model.toEntity();
    } on FirebaseException catch (e) {
      throw ServerException(code: e.code);
    }
  }

  @override
  Future<DietaryPreferences> save({
    required String uid,
    required DietaryPreferences prefs,
  }) async {
    try {
      final model = DietaryPreferencesModel.fromEntity(prefs);

      await _firestore
          .collection('users')
          .doc(uid)
          .collection('dietaryPreferences')
          .doc(prefs.prefsId)
          .set(model.toJson());

      return prefs;
    } on FirebaseException catch (e) {
      throw ServerException(code: e.code);
    }
  }

  @override
  Future<DietaryPreferences> updateExclusions({
    required String uid,
    required String prefsId,
    required Set<String> excludedFoodIds,
  }) async {
    try {
      final docRef = _firestore
          .collection('users')
          .doc(uid)
          .collection('dietaryPreferences')
          .doc(prefsId);

      await docRef.set({
        'excludedFoodIds': excludedFoodIds.toList(),
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      // Get updated document
      final doc = await docRef.get();
      final model = DietaryPreferencesModel.fromJson(
        doc.data()!,
        docId: doc.id,
      );
      return model.toEntity();
    } on FirebaseException catch (e) {
      throw ServerException(code: e.code);
    }
  }

  @override
  Future<DietaryPreferences> update({
    required String uid,
    required String prefsId,
    required Map<String, dynamic> partial,
  }) async {
    try {
      final docRef = _firestore
          .collection('users')
          .doc(uid)
          .collection('dietaryPreferences')
          .doc(prefsId);

      // Add timestamp for update
      partial['updatedAt'] = FieldValue.serverTimestamp();

      await docRef.update(partial);

      // Get updated document
      final doc = await docRef.get();
      final model = DietaryPreferencesModel.fromJson(
        doc.data()!,
        docId: doc.id,
      );
      return model.toEntity();
    } on FirebaseException catch (e) {
      throw ServerException(code: e.code);
    }
  }
}
