import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:version1/services/api_service.dart';
import 'package:version1/services/app_state.dart';

class AuthResult {
  final bool success;
  final bool cancelled;
  final bool isProfileCompleted;
  final String? displayName;
  final String? email;
  final String? errorMessage;

  const AuthResult({
    this.success = false,
    this.cancelled = false,
    this.isProfileCompleted = false,
    this.displayName,
    this.email,
    this.errorMessage,
  });
}

class AuthService {
  AuthService._internal();
  static final AuthService instance = AuthService._internal();

  static const String _webClientId =
      '675437277662-rpqvkgpfa9oruutealq8c65hhjqpg62t.apps.googleusercontent.com';

  final GoogleSignIn _googleSignIn = GoogleSignIn(
    serverClientId: _webClientId,
    scopes: const ['email', 'profile'],
  );

  /// Google OAuth Sign-In with automatic Firebase Web OAuth fallback for OEM devices
  Future<AuthResult> signInWithGoogle() async {
    User? fbUser;

    // 1. Try native Google Sign-In dialog first
    try {
      try {
        await _googleSignIn.signOut();
      } catch (_) {}

      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        return const AuthResult(cancelled: true);
      }

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      if (googleAuth.idToken == null && googleAuth.accessToken == null) {
        throw PlatformException(
          code: 'missing_tokens',
          message: 'Google Sign-In did not return authentication tokens.',
        );
      }

      final OAuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final userCred = await FirebaseAuth.instance.signInWithCredential(credential);
      fbUser = userCred.user;
    } on PlatformException catch (e) {
      debugPrint('[AuthService] Native GoogleSignIn failed (${e.code}: ${e.message}). Falling back to Firebase OAuth provider...');
      final fallbackResult = await _signInWithGoogleProviderFallback();
      if (fallbackResult.cancelled || !fallbackResult.success) {
        return fallbackResult;
      }
      return fallbackResult;
    } on FirebaseAuthException catch (e) {
      return AuthResult(errorMessage: _friendlyFirebaseError(e));
    } catch (e) {
      debugPrint('[AuthService] Native GoogleSignIn unexpected error ($e). Trying Firebase OAuth fallback...');
      final fallbackResult = await _signInWithGoogleProviderFallback();
      if (fallbackResult.cancelled || fallbackResult.success) {
        return fallbackResult;
      }
      return AuthResult(errorMessage: 'Google Sign-In failed: $e');
    }

    if (fbUser == null || fbUser.email == null || fbUser.email!.isEmpty) {
      return const AuthResult(errorMessage: 'Unable to retrieve Google account email.');
    }

    return _syncFirebaseUserWithBackend(fbUser);
  }

  /// Hosted Firebase Google OAuth flow (works even if Play Services / Credential Manager has OEM issues)
  Future<AuthResult> _signInWithGoogleProviderFallback() async {
    try {
      final provider = GoogleAuthProvider();
      provider.setCustomParameters({'prompt': 'select_account'});
      final userCred = await FirebaseAuth.instance.signInWithProvider(provider);
      final fbUser = userCred.user;
      if (fbUser == null || fbUser.email == null || fbUser.email!.isEmpty) {
        return const AuthResult(errorMessage: 'Unable to retrieve Google account email.');
      }
      return _syncFirebaseUserWithBackend(fbUser);
    } on FirebaseAuthException catch (e) {
      if (e.code == 'web-context-canceled' ||
          e.code == 'canceled' ||
          e.code == 'user-cancelled') {
        return const AuthResult(cancelled: true);
      }
      return AuthResult(errorMessage: _friendlyFirebaseError(e));
    } catch (e) {
      return AuthResult(errorMessage: 'Google OAuth error: $e');
    }
  }

  /// Direct Email & Password Sign-In via Firebase + Supabase Sync
  Future<AuthResult> signInWithEmail({
    required String email,
    required String password,
  }) async {
    final cleanEmail = email.trim().toLowerCase();
    try {
      final userCred = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: cleanEmail,
        password: password,
      );
      final fbUser = userCred.user;
      if (fbUser == null || fbUser.email == null) {
        return const AuthResult(errorMessage: 'Account not found in Firebase.');
      }
      return _syncFirebaseUserWithBackend(fbUser);
    } on FirebaseAuthException catch (fbErr) {
      debugPrint('[AuthService] Firebase email login error: ${fbErr.code}');
      // Allow legacy pre-Firebase users stored directly in PostgreSQL to sign in cleanly
      if (fbErr.code == 'user-not-found' || fbErr.code == 'invalid-credential') {
        final legacyRes = await ApiService.instance.loginEmail(
          email: cleanEmail,
          password: password,
        );
        if (legacyRes['success'] == true && legacyRes['token'] != null) {
          return _saveBackendSession(legacyRes, fallbackEmail: cleanEmail);
        }
      }
      return AuthResult(errorMessage: _friendlyFirebaseError(fbErr));
    } catch (e) {
      return AuthResult(errorMessage: 'Login failed: $e');
    }
  }

  /// Direct Email & Password Sign-Up via Firebase + Supabase Sync (atomic rollback on backend failure)
  Future<AuthResult> signUpWithEmail({
    required String email,
    required String password,
    String? name,
  }) async {
    final cleanEmail = email.trim().toLowerCase();
    final cleanName = name?.trim() ?? '';
    User? createdUser;

    try {
      final cred = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: cleanEmail,
        password: password,
      );
      createdUser = cred.user;
      if (createdUser != null && cleanName.isNotEmpty) {
        await createdUser.updateDisplayName(cleanName);
      }

      if (createdUser == null) {
        return const AuthResult(errorMessage: 'Failed to create Firebase account.');
      }

      final result = await _syncFirebaseUserWithBackend(
        createdUser,
        overrideName: cleanName.isNotEmpty ? cleanName : null,
      );

      // Prevent orphaned Firebase user if Supabase/Render creation fails
      if (!result.success) {
        try {
          await createdUser.delete();
        } catch (_) {}
      }

      return result;
    } on FirebaseAuthException catch (e) {
      return AuthResult(errorMessage: _friendlyFirebaseError(e));
    } catch (e) {
      if (createdUser != null) {
        try {
          await createdUser.delete();
        } catch (_) {}
      }
      return AuthResult(errorMessage: 'Sign up failed: $e');
    }
  }

  Future<String?> sendPasswordReset(String email) async {
    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email.trim());
      return null;
    } on FirebaseAuthException catch (e) {
      return _friendlyFirebaseError(e);
    } catch (e) {
      return 'Failed to send reset link: $e';
    }
  }

  Future<void> signOut() async {
    try {
      await FirebaseAuth.instance.signOut();
    } catch (_) {}
    try {
      await _googleSignIn.signOut();
    } catch (_) {}
  }

  Future<AuthResult> _syncFirebaseUserWithBackend(
    User fbUser, {
    String? overrideName,
  }) async {
    String? idToken;
    try {
      idToken = await fbUser.getIdToken();
    } catch (_) {}

    final res = await ApiService.instance.syncFirebaseUser(
      email: fbUser.email!,
      name: overrideName ?? fbUser.displayName,
      avatarUrl: fbUser.photoURL,
      idToken: idToken,
    );

    if (res['success'] != true || res['token'] == null) {
      return AuthResult(
        errorMessage: res['error']?.toString() ?? 'Failed to sync user with server.',
      );
    }

    return _saveBackendSession(
      res,
      fallbackEmail: fbUser.email!,
      fallbackName: overrideName ?? fbUser.displayName,
    );
  }

  Future<AuthResult> _saveBackendSession(
    Map<String, dynamic> res, {
    required String fallbackEmail,
    String? fallbackName,
  }) async {
    final token = res['token'].toString();
    final userId = res['user']?['id']?.toString() ?? '';
    final profile = res['user']?['profile'] as Map<String, dynamic>?;
    final bool isProfileCompleted = res['isProfileCompleted'] == true ||
        (profile != null && profile['isCompleted'] == true);
    final name = profile?['name']?.toString() ?? fallbackName;

    await AppState.instance.saveUserSession(
      token: token,
      userId: userId,
      isProfileCompleted: isProfileCompleted,
      email: res['user']?['email']?.toString() ?? fallbackEmail,
      name: name,
      phone: res['user']?['phone']?.toString(),
      profile: profile,
    );

    return AuthResult(
      success: true,
      isProfileCompleted: isProfileCompleted,
      displayName: name,
      email: res['user']?['email']?.toString() ?? fallbackEmail,
    );
  }

  String _friendlyFirebaseError(FirebaseAuthException e) {
    switch (e.code) {
      case 'invalid-email':
        return 'Please enter a valid email address.';
      case 'user-not-found':
        return 'No account found with this email. Please sign up first.';
      case 'wrong-password':
      case 'invalid-credential':
        return 'Incorrect email or password. Please try again.';
      case 'email-already-in-use':
        return 'An account with this email already exists. Please sign in.';
      case 'weak-password':
        return 'Password is too weak. Please use at least 6 characters.';
      case 'user-disabled':
        return 'This account has been disabled.';
      case 'too-many-requests':
        return 'Too many attempts. Please wait a moment and try again.';
      case 'network-request-failed':
        return 'Network error. Please check your internet connection.';
      default:
        return e.message ?? 'Authentication failed (${e.code}).';
    }
  }
}

