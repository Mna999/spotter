import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:spotter/core/error/exception.dart';
import 'package:spotter/features/auth/data/models/user_account_model.dart';

abstract class AuthRemoteDataSource {
  Future<UserAccountModel> register({
    required String email,
    required String password,
    required String name,
  });
  Future<UserAccountModel> signIn({
    required String email,
    required String password,
  });

  Future<UserAccountModel> signInWithGoogle();

  Future<void> sendPasswordReset({required String email});

  Future<UserAccountModel?> currentSession();

  Future<void> signOut();

  Future<void> deleteAccount();
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  FirebaseAuth firebaseAuth;
  FirebaseFirestore firebaseFirestore;
  GoogleSignIn googleSignIn;

  AuthRemoteDataSourceImpl({
    required this.firebaseAuth,
    required this.firebaseFirestore,
    required this.googleSignIn,
  });

  @override
  Future<UserAccountModel?> currentSession() async {
    User? user = firebaseAuth.currentUser;
    if (user != null) {
      return UserAccountModel.fromFirebaseUser(user);
    }
    return null;
  }

  @override
  Future<void> deleteAccount() async {
    User? user = firebaseAuth.currentUser;
    if (user == null) throw AuthException(code: 'user-not-found');
    try {
      await user.delete();
      await firebaseFirestore.collection('users').doc(user.uid).delete();
    } on FirebaseAuthException catch (e) {
      throw AuthException(code: e.code);
    }
  }

  @override
  Future<UserAccountModel> register({
    required String email,
    required String password,
    required String name,
  }) async {
    UserCredential? cred;
    try {
      cred = await firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      User authUser = cred.user!;
      UserAccountModel user = UserAccountModel(
        createdAt: authUser.metadata.creationTime ?? DateTime.now(),
        displayName: name,
        email: email,
        uid: authUser.uid,
      );
      await firebaseFirestore
          .collection('users')
          .doc(user.uid)
          .set(user.toJson());

      return user;
    } on FirebaseAuthException catch (e) {
      throw AuthException(code: e.code);
    } on FirebaseException catch (e) {
      try {
        await cred?.user?.delete();
      } on FirebaseAuthException catch (_) {
        throw AuthException(code: e.code);
      }
      throw ServerException(code: e.code);
    }
  }

  @override
  Future<void> sendPasswordReset({required String email}) async {
    try {
      await firebaseAuth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      throw AuthException(code: e.code);
    }
  }

  @override
  Future<UserAccountModel> signIn({
    required String email,
    required String password,
  }) async {
    try {
      await firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      UserAccountModel user = UserAccountModel.fromFirebaseUser(
        firebaseAuth.currentUser!,
      );
      return user;
    } on FirebaseAuthException catch (e) {
      throw AuthException(code: e.code);
    }
  }

  @override
  Future<UserAccountModel> signInWithGoogle() async {
    User? newAuthUser; // set only if this sign-in created the account
    try {
      // 1. Google account picker (throws on cancel, unlike v6)
      final googleUser = await googleSignIn.authenticate();

      // 2. v7: `authentication` is synchronous and only carries the idToken,
      //    which is all Firebase needs
      final idToken = googleUser.authentication.idToken;
      if (idToken == null) {
        throw AuthException(code: 'google-missing-id-token');
      }

      // 3. Exchange it for a Firebase session
      final credential = GoogleAuthProvider.credential(idToken: idToken);
      final cred = await firebaseAuth.signInWithCredential(credential);
      final authUser = cred.user;
      if (authUser == null) throw AuthException(code: 'user-not-found');

      final user = UserAccountModel.fromFirebaseUser(authUser);

      // 4. First Google sign-in: create users/{uid} (FR-AUTH-01)
      if (cred.additionalUserInfo?.isNewUser ?? false) {
        newAuthUser = authUser;
        await firebaseFirestore
            .collection('users')
            .doc(user.uid)
            .set(user.toJson());
      }

      return user;
    } on GoogleSignInException catch (e) {
      if (e.code == GoogleSignInExceptionCode.canceled) {
        throw AuthException(code: 'google-sign-in-canceled');
      }
      // clientConfigurationError, interrupted, unknownError, ...
      throw AuthException(code: 'google-${e.code.name}');
    } on FirebaseAuthException catch (e) {
      // account-exists-with-different-credential, invalid-credential,
      // user-disabled, operation-not-allowed, network-request-failed, ...
      throw AuthException(code: e.code);
    } on FirebaseException catch (e) {
      // Firestore write failed: roll back the brand-new Auth account
      // so the user can try again cleanly
      try {
        await newAuthUser?.delete();
        await googleSignIn.signOut();
      } catch (_) {}
      throw ServerException(code: e.code);
    }
  }

  @override
  Future<void> signOut() async {
    try {
      await firebaseAuth.signOut();
      await googleSignIn.signOut();
    } on FirebaseAuthException catch (e) {
      throw AuthException(code: e.code);
    }
  }
}
