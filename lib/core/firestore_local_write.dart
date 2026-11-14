import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';

/// Applies [write] and completes once Firestore's local cache reflects it.
///
/// The future returned by `set`, `update` and `delete` only completes when the
/// backend acknowledges the write. While offline that never happens, so
/// awaiting it leaves the caller (and the screen's loading state) stuck until
/// the device reconnects.
///
/// Firestore still applies the write to its local cache immediately, which is
/// what reads use while offline. Waiting for the first snapshot that contains
/// the write gives callers a point where the cache reads that follow are
/// guaranteed to see the change, without requiring a connection.
///
/// Pass [isLocal] when the device is offline so the backend acknowledgement is
/// not awaited, and [isApplied] when the write does not leave a pending write
/// on the document, for example a delete ([DocumentSnapshot.exists] turns
/// false).
Future<void> applyFirestoreWrite(
  Future<void> write, {
  required DocumentReference<Map<String, dynamic>> document,
  required bool isLocal,
  bool Function(DocumentSnapshot<Map<String, dynamic>> snapshot)? isApplied,
  Duration localTimeout = const Duration(seconds: 3),
  Duration backendTimeout = const Duration(seconds: 10),
}) async {
  if (!isLocal) {
    try {
      await write.timeout(backendTimeout);
      return;
    } on TimeoutException {
      // The connection looked available but the backend never acknowledged the
      // write. It is still queued in the local cache, so fall through to the
      // local barrier rather than blocking the caller indefinitely.
    }
  } else {
    // The write is queued in the local cache; its backend acknowledgement may
    // only arrive after the device reconnects, so it must not block the caller.
    unawaited(write.catchError((Object _) {}));
  }

  // Wait for the first snapshot that already contains the write, so the cache
  // reads that follow are guaranteed to see the change.
  final predicate =
      isApplied ?? (snapshot) => snapshot.metadata.hasPendingWrites;
  final applied = Completer<void>();
  final subscription = document.snapshots().listen(
    (snapshot) {
      if (!applied.isCompleted && predicate(snapshot)) applied.complete();
    },
    onError: (Object error, StackTrace stackTrace) {
      if (!applied.isCompleted) applied.completeError(error, stackTrace);
    },
  );

  try {
    await applied.future.timeout(localTimeout);
  } on TimeoutException {
    // The cache never reported the write. Continue with what is cached rather
    // than leaving the UI blocked forever.
  } finally {
    await subscription.cancel();
  }
}
