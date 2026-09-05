import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/auth_service.dart';
import '../services/firestore_service.dart';
import '../models/user_model.dart';

class AuthRepository {
  final AuthService _authService;
  final FirestoreService _firestoreService;

  AuthRepository({
    AuthService? authService,
    FirestoreService? firestoreService,
  })  : _authService = authService ?? AuthService(),
        _firestoreService = firestoreService ?? FirestoreService();

  User? get currentUser => _authService.currentUser;

  Stream<User?> get authStateChanges => _authService.authStateChanges;

  Future<UserModel> signIn({
    required String email,
    required String password,
  }) async {
    final credential = await _authService.signInWithEmailAndPassword(
      email: email,
      password: password,
    );

    final uid = credential.user!.uid;
    debugPrint('[LOGIN DEBUG] 7. AuthRepository reading Firestore user profile for UID: $uid');

    UserModel? userModel;
    try {
      userModel = await _firestoreService.getUserProfile(uid);
    } catch (e) {
      debugPrint('[LOGIN DEBUG] Firestore getUserProfile exception caught: $e');
    }

    debugPrint('[LOGIN DEBUG] 8. Firestore user profile exists: ${userModel != null}');

    if (userModel == null) {
      userModel = UserModel(
        uid: uid,
        email: email,
        displayName: credential.user?.displayName ?? email.split('@')[0],
      );
      try {
        await _firestoreService.createUserProfile(userModel);
        debugPrint('[LOGIN DEBUG] Created Firestore user profile for UID: $uid');
      } catch (e) {
        debugPrint('[LOGIN DEBUG] Firestore createUserProfile exception caught: $e');
      }
    }

    return userModel;
  }

  Future<UserModel> signUp({
    required String name,
    required String email,
    required String password,
  }) async {
    final credential = await _authService.signUpWithEmailAndPassword(
      email: email,
      password: password,
    );

    final uid = credential.user!.uid;
    final userModel = UserModel(
      uid: uid,
      email: email,
      displayName: name,
    );

    try {
      await _firestoreService.createUserProfile(userModel);
      debugPrint('[REGISTER DEBUG] Created Firestore user profile for UID: $uid');
    } catch (e) {
      debugPrint('[REGISTER DEBUG] Firestore createUserProfile exception caught: $e');
    }

    return userModel;
  }

  Future<UserModel?> fetchUserProfile(String uid) async {
    try {
      return await _firestoreService.getUserProfile(uid);
    } catch (e) {
      debugPrint('[AUTH DEBUG] fetchUserProfile failed for UID $uid: $e');
      return null;
    }
  }

  Future<void> signOut() async {
    await _authService.signOut();
  }
}
