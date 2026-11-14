import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:spotter/core/error/exception.dart';
import 'package:spotter/core/firestore_local_write.dart';
import 'package:spotter/features/nutrition/data/models/dietary_preferences_model.dart';
import 'package:spotter/features/nutrition/domain/entities/dietary_preferences.dart';

abstract class NutritionPreferencesRemoteDataSource {
  /// Get dietary preferences for a user
  Future<DietaryPreferences?> get({
    required String uid,
    required String prefsId,
    bool isLocal = false,
  });

  /// Save dietary preferences for a user
  Future<DietaryPreferences> save({
    required String uid,
    required DietaryPreferences prefs,
    bool isLocal = false,
  });

  /// Update excluded food IDs
  Future<DietaryPreferences> updateExclusions({
    required String uid,
    required Set<String> excludedFoodIds,
    required String prefsId,
    Set<String>? excludedCategories,
    bool isLocal = false,
  });

  /// Update partial preferences
  Future<DietaryPreferences> update({
    required String uid,
    required Map<String, dynamic> partial,
    required String prefsId,
    bool isLocal = false,
  });
}

class NutritionPreferencesRemoteDataSourceImpl
    implements NutritionPreferencesRemoteDataSource {
  final FirebaseFirestore _firestore;

  NutritionPreferencesRemoteDataSourceImpl({required this._firestore});

  /// There is exactly one preferences document per user, stored as
  /// `users/{uid}/dietaryPreferences/{uid}`. Callers that do not know the id
  /// yet pass an empty string, so fall back to the uid instead of asking
  /// Firestore for a document with an empty id (which throws).
  String _docId({required String uid, required String prefsId}) =>
      prefsId.trim().isEmpty ? uid : prefsId.trim();

  @override
  Future<DietaryPreferences?> get({
    required String uid,
    required String prefsId,
    bool isLocal = false,
  }) async {
    try {
      final doc = await _firestore
          .collection('users')
          .doc(uid)
          .collection('dietaryPreferences')
          .doc(_docId(uid: uid, prefsId: prefsId))
          .get(
            GetOptions(source: isLocal ? Source.cache : Source.serverAndCache),
          );

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
    bool isLocal = false,
  }) async {
    try {
      final docId = _docId(uid: uid, prefsId: prefs.prefsId);
      final model = DietaryPreferencesModel.fromEntity(prefs).withId(docId);

      final docRef = _firestore
          .collection('users')
          .doc(uid)
          .collection('dietaryPreferences')
          .doc(docId);

      await applyFirestoreWrite(
        docRef.set(model.toJson()),
        document: docRef,
        isLocal: isLocal,
      );

      return model.toEntity();
    } on FirebaseException catch (e) {
      throw ServerException(code: e.code);
    }
  }

  @override
  Future<DietaryPreferences> updateExclusions({
    required String uid,
    required String prefsId,
    required Set<String> excludedFoodIds,
    Set<String>? excludedCategories,
    bool isLocal = false,
  }) async {
    try {
      final docRef = _firestore
          .collection('users')
          .doc(uid)
          .collection('dietaryPreferences')
          .doc(_docId(uid: uid, prefsId: prefsId));

      final partial = <String, dynamic>{
        'excludedFoodIds': excludedFoodIds.toList(),
        'updatedAt': FieldValue.serverTimestamp(),
      };
      if (excludedCategories != null) {
        partial['excludedCategories'] = excludedCategories.toList();
      }

      await applyFirestoreWrite(
        docRef.set(partial, SetOptions(merge: true)),
        document: docRef,
        isLocal: isLocal,
      );

      // Get updated document
      final doc = await docRef.get(
        GetOptions(source: isLocal ? Source.cache : Source.serverAndCache),
      );
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
    bool isLocal = false,
  }) async {
    try {
      final docRef = _firestore
          .collection('users')
          .doc(uid)
          .collection('dietaryPreferences')
          .doc(_docId(uid: uid, prefsId: prefsId));

      // Add timestamp for update
      partial['updatedAt'] = FieldValue.serverTimestamp();

      // Merge so a partial update also creates the document the first time.
      await applyFirestoreWrite(
        docRef.set(partial, SetOptions(merge: true)),
        document: docRef,
        isLocal: isLocal,
      );

      // Get updated document
      final doc = await docRef.get(
        GetOptions(source: isLocal ? Source.cache : Source.serverAndCache),
      );
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
