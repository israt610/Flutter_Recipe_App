import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../repositories/auth_repository.dart';
import '../models/user_model.dart';

enum AuthStatus { uninitialized, authenticated, unauthenticated, loading }

class AuthProvider extends ChangeNotifier {
  final AuthRepository _authRepository;

  AuthStatus _status = AuthStatus.uninitialized;
  UserModel? _userModel;
  String? _errorMessage;

  AuthProvider({AuthRepository? authRepository})
      : _authRepository = authRepository ?? AuthRepository() {
    _init();
  }

  AuthStatus get status => _status;
  UserModel? get userModel => _userModel;
  String? get currentUserId => _userModel?.uid ?? _authRepository.currentUser?.uid;
  String? get errorMessage => _errorMessage;
  bool get isAuthenticated => _status == AuthStatus.authenticated;
  bool get isLoading => _status == AuthStatus.loading;

  void _init() {
    _authRepository.authStateChanges.listen((User? user) async {
      if (user == null) {
        _status = AuthStatus.unauthenticated;
        _userModel = null;
      } else {
        try {
          _userModel = await _authRepository.fetchUserProfile(user.uid);
          _status = AuthStatus.authenticated;
        } catch (e) {
          debugPrint('[AUTH DEBUG] Exception during auth state change profile fetch: $e');
          _status = AuthStatus.authenticated;
        }
      }
      notifyListeners();
    });
  }

  Future<bool> login(String email, String password) async {
    debugPrint('[LOGIN DEBUG] 1. Login button pressed');
    debugPrint('[LOGIN DEBUG] 2. Email being used: $email');
    _setLoading(true);
    _clearError();
    try {
      _userModel = await _authRepository.signIn(
        email: email,
        password: password,
      );
      debugPrint('[LOGIN DEBUG] 4. Firebase Authentication succeeds for UID: ${_userModel?.uid}');
      _status = AuthStatus.authenticated;
      _setLoading(false);
      debugPrint('[LOGIN DEBUG] 9. Navigation to HomeScreen will occur: true');
      return true;
    } on FirebaseAuthException catch (e, stack) {
      debugPrint('[LOGIN DEBUG] 4. Firebase Authentication fails');
      debugPrint('[LOGIN DEBUG] 5. FirebaseException code: ${e.code}');
      debugPrint('[LOGIN DEBUG] 6. FirebaseException message: ${e.message}');
      debugPrint('[LOGIN DEBUG] StackTrace: $stack');
      _errorMessage = _getAuthErrorMessage(e.code);
      _status = AuthStatus.unauthenticated;
      _setLoading(false);
      return false;
    } on FirebaseException catch (e, stack) {
      debugPrint('[LOGIN DEBUG] FirebaseException (non-Auth) caught');
      debugPrint('[LOGIN DEBUG] 5. FirebaseException code: ${e.code}');
      debugPrint('[LOGIN DEBUG] 6. FirebaseException message: ${e.message}');
      debugPrint('[LOGIN DEBUG] StackTrace: $stack');
      _errorMessage = 'Firebase error (${e.code}): ${e.message ?? e.toString()}';
      _status = AuthStatus.unauthenticated;
      _setLoading(false);
      return false;
    } catch (e, stack) {
      debugPrint('[LOGIN DEBUG] Unhandled Exception caught: ${e.runtimeType}');
      debugPrint('[LOGIN DEBUG] Exception details: $e');
      debugPrint('[LOGIN DEBUG] StackTrace: $stack');
      _errorMessage = 'Error (${e.runtimeType}): $e';
      _status = AuthStatus.unauthenticated;
      _setLoading(false);
      return false;
    }
  }

  Future<bool> register(String name, String email, String password) async {
    debugPrint('[REGISTER DEBUG] 1. Register button pressed');
    debugPrint('[REGISTER DEBUG] 2. Email being used: $email');
    _setLoading(true);
    _clearError();
    try {
      _userModel = await _authRepository.signUp(
        name: name,
        email: email,
        password: password,
      );
      debugPrint('[REGISTER DEBUG] 4. Firebase Auth signUp succeeds. UID: ${_userModel?.uid}');
      _status = AuthStatus.authenticated;
      _setLoading(false);
      return true;
    } on FirebaseAuthException catch (e, stack) {
      debugPrint('[REGISTER DEBUG] Firebase Auth registration fails');
      debugPrint('[REGISTER DEBUG] FirebaseException code: ${e.code}');
      debugPrint('[REGISTER DEBUG] FirebaseException message: ${e.message}');
      debugPrint('[REGISTER DEBUG] StackTrace: $stack');
      _errorMessage = _getAuthErrorMessage(e.code);
      _status = AuthStatus.unauthenticated;
      _setLoading(false);
      return false;
    } on FirebaseException catch (e, stack) {
      debugPrint('[REGISTER DEBUG] FirebaseException (non-Auth) caught');
      debugPrint('[REGISTER DEBUG] FirebaseException code: ${e.code}');
      debugPrint('[REGISTER DEBUG] FirebaseException message: ${e.message}');
      debugPrint('[REGISTER DEBUG] StackTrace: $stack');
      _errorMessage = 'Firebase error (${e.code}): ${e.message ?? e.toString()}';
      _status = AuthStatus.unauthenticated;
      _setLoading(false);
      return false;
    } catch (e, stack) {
      debugPrint('[REGISTER DEBUG] Exception caught: ${e.runtimeType}');
      debugPrint('[REGISTER DEBUG] Exception details: $e');
      debugPrint('[REGISTER DEBUG] StackTrace: $stack');
      _errorMessage = 'Error (${e.runtimeType}): $e';
      _status = AuthStatus.unauthenticated;
      _setLoading(false);
      return false;
    }
  }

  Future<void> logout() async {
    await _authRepository.signOut();
    _userModel = null;
    _status = AuthStatus.unauthenticated;
    notifyListeners();
  }

  void _setLoading(bool loading) {
    if (loading) {
      _status = AuthStatus.loading;
    }
    notifyListeners();
  }

  void _clearError() {
    _errorMessage = null;
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  String _getAuthErrorMessage(String code) {
    switch (code) {
      case 'user-not-found':
        return 'No user account found with this email.';
      case 'wrong-password':
        return 'Incorrect password entered.';
      case 'invalid-credential':
        return 'Invalid email or password. Please check your credentials.';
      case 'invalid-email':
        return 'The email address format is invalid.';
      case 'user-disabled':
        return 'This user account has been disabled.';
      case 'too-many-requests':
        return 'Too many failed attempts. Please try again later.';
      case 'network-request-failed':
        return 'Network error. Please check your internet connection.';
      case 'operation-not-allowed':
        return 'Email/password sign-in is not enabled in Firebase Console.';
      case 'email-already-in-use':
        return 'An account already exists for this email.';
      case 'weak-password':
        return 'The password provided is too weak.';
      default:
        return 'Authentication failed ($code). Please check your credentials.';
    }
  }
}
