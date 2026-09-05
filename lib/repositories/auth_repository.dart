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
    UserModel? userModel = await _firestoreService.getUserProfile(uid);

    if (userModel == null) {
      userModel = UserModel(
        uid: uid,
        email: email,
        displayName: credential.user?.displayName ?? email.split('@')[0],
      );
      await _firestoreService.createUserProfile(userModel);
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

    await _firestoreService.createUserProfile(userModel);
    return userModel;
  }

  Future<UserModel?> fetchUserProfile(String uid) async {
    return await _firestoreService.getUserProfile(uid);
  }

  Future<void> signOut() async {
    await _authService.signOut();
  }
}
