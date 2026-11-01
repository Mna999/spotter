import 'package:cloud_firestore/cloud_firestore.dart';

/// Deletes [document] and every descendant described by [subcollectionPaths],
/// deepest level first, so Firestore leaves no orphaned subcollection
/// documents behind (Firestore itself never cascades deletes).
///
/// [subcollectionPaths] are slash-separated chains relative to [document],
/// for example `workouts/plannedExercises/sets`. The client SDK cannot
/// enumerate subcollections, so each known schema path is spelled out.
///
/// This needs a network connection: cached documents cannot be listed.
Future<void> deleteDocumentRecursively(
  DocumentReference<Map<String, dynamic>> document, {
  required List<String> subcollectionPaths,
}) async {
  await _deleteSubcollections(document, subcollectionPaths);
  await document.delete();
}

/// Groups [paths] by their first segment, then deletes those collections.
Future<void> _deleteSubcollections(
  DocumentReference<Map<String, dynamic>> document,
  List<String> paths,
) async {
  final byCollection = <String, List<String>>{};
  for (final path in paths) {
    final segments = path.split('/');
    byCollection
        .putIfAbsent(segments.first, () => <String>[])
        .add(segments.skip(1).join('/'));
  }

  for (final entry in byCollection.entries) {
    await _deleteCollection(
      document.collection(entry.key),
      childPaths: entry.value,
    );
  }
}

/// Deletes every document in [collection], plus the nested subcollections
/// described by [childPaths]. Paging keeps memory flat for large collections.
Future<void> _deleteCollection(
  CollectionReference<Map<String, dynamic>> collection, {
  required List<String> childPaths,
}) async {
  const pageSize = 100;
  final nestedPaths = childPaths.where((path) => path.isNotEmpty).toList();

  while (true) {
    final page = await collection.limit(pageSize).get();
    if (page.docs.isEmpty) return;

    for (final doc in page.docs) {
      if (nestedPaths.isNotEmpty) {
        await _deleteSubcollections(doc.reference, nestedPaths);
      }
      await doc.reference.delete();
    }

    // A short page means the collection is drained.
    if (page.docs.length < pageSize) return;
  }
}
